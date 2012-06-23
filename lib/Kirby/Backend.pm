# Part of Kirby.
# See the COPYING file that should have been distributed with this software.
# https://raw.github.com/hdonnay/kirby/master/COPYING
package Kirby::Backend;

use strict;
use warnings;

use Mojo::Base 'Mojolicious::Controller';
use Switch;
use Data::Dumper;
use Mojo::UserAgent;
use Kirby::Database;

sub rssToJSON {
    my $self = shift;

    my $ua = Mojo::UserAgent->new;
    my $res = $ua->get( $self->stash('comicsRSS') )->res;

    $self->render(json => [$res->dom('item')->map(sub {
                my $desc;
                # Fix for ComicVine, which uses relative URLs
                if ($self->stash('comicsRSS') eq "http://feeds.feedburner.com/NewComicBooks") {
                    ($desc = $_->description->text) =~ s/a href=\"/a href=\"http:\/\/www.comicvine.com/g;
                } else {
                     $desc = $_->description->text;
                };
                return [ $_->title->text, $_->link->text, undef, $desc ];
            })->each, undef] );
}

sub usenetFetchAndStore {
    #$dbh->do('CREATE TABLE nzb ( id INTEGER PRIMARY KEY, releaseDate TEXT, origYear TEXT, tags TEXT, series TEXT, issue INT, url TEXT );');
    my $self = shift;
    my $rowsAdded = 0;
    my $SQLhits = 0;
    my $fmt = 0;
    my $i = 1;
    my $ua = Mojo::UserAgent->new;
    my @regex = [
        qr/0-day \(([0-9\-]+)\) w\/ PARs \[\d+\/\d+\] - \"?(.+)\.cb[rz]\"?.*/,
        qr/Grab Bag ([0-9\.]+) \[\d+\/\d+\] - \"(.+)\.cb[rz]\".*/,
    ];

    my $res = $ua->get( $self->stash('usenetRSS') )->res;
    if ($? != 0) {
        $self->app->log->debug("Unable to fetch RSS feed.");
        return $self->render(json => {status => 404});
    }

    $res->dom('item')->map(sub {
            my $item = shift;
            my @record = Kirby::Database::Nzb->select('where url = ?', $_->link->text);
            print "item link:  ".$_->link->text."\n";
            print "record url: ".$record[0]->url."\n";
            unless ( (@record) and ($record[0]->url eq $_->link->text) ) {
                my %attrs = ();
                foreach (@regex) {
                    if ($item->title->text =~ $_) { $fmt = $i }
                    $i++;
                }
                # in these cases, you have the match variables from the regex that sets $fmt
                # only using a goto because fucking switches wouldn't work
                if ($fmt == 2) { $1 =~ s/\./-/g; $fmt--; }
                if ($fmt == 1) {
                    $attrs{'rlsDate'} = $1;
                    @{\$attrs{'tags'}} = split(/ *\( *|\) *\(| *\) */, $2);
                    my @titleTok = split(' ', shift @{\$attrs{'tags'}});
                    if ($titleTok[-1] =~ m/\d/ ) {$attrs{'issue'} = pop @titleTok};
                    $attrs{'series'} = join(' ', @titleTok);
                    #catch various naming conventions
                    if ($attrs{'tags'}[0] =~ m/[0-9]{4}/) { $attrs{'origYear'} = shift @{\$attrs{'tags'}}; }
                    elsif($attrs{'tags'}[0] =~ /of \d+/) { shift @{\$attrs{'tags'}}; $attrs{'origYear'} = shift @{\$attrs{'tags'}}; }
                    elsif($attrs{'tags'}[0] eq "c2c") { $attrs{'origYear'} = $attrs{'tags'}[1]; delete $attrs{'tags'}[1]; }
                }
                $self->app->log->debug("time => ".localtime(time));
                $self->app->log->debug("releaseDate => $attrs{'rlsDate'}");
                $self->app->log->debug("origYear => $attrs{'origYear'}");
                $self->app->log->debug("tags => ".join(',',$attrs{'tags'}));
                $self->app->log->debug("series => $attrs{'series'}");
                $self->app->log->debug("issue => $attrs{'issue'}");
                $self->app->log->debug("url => $_->link->text");
                Kirby::Database::Nzb->create(
                    time => localtime(time),
                    releaseDate => $attrs{'rlsDate'},
                    origYear => $attrs{'origYear'},
                    tags => join(',',$attrs{'tags'}),
                    series => $attrs{'series'},
                    issue => $attrs{'issue'},
                    url => $_->link->text,
                );
                $rowsAdded++;
            } else {$SQLhits++}
        })->each;

    $self->app->log->debug("SQL hits: $SQLhits, SQL Additions: $rowsAdded");
    if ($rowsAdded == 0) { return $self->render(json => {status => 304}); }
    else { return $self->render(json => {status => 200, changes => $rowsAdded}); };
}

sub usenetToJSON {
    my $self = shift;
    my @returnList;

    my $offset = $self->param('offset') or 0;
    my $returnResults = 14; #meaning 15

    Kirby::Database::Nzb->iterate(
        'ORDER BY time ASC LIMIT ? OFFSET ?', $returnResults, ($offset * $returnResults),
        sub {
            my @tags = split(',', $_->tags);
            push(@returnList, {
                    time => time,
                    releaseDate => $_->releaseDate,
                    year => $_->origYear,
                    series => $_->series,
                    issue => $_->issue,
                    tags => \@tags,
                    link => $_->url,
                });
        }
    );
    push(@returnList, undef);

    $self->render(json => \@returnList);
};

sub historyToJSON {
    #CREATE TABLE history ( id INTEGER PRIMARY KEY, time TEXT, name TEXT, issue INT, action TEXT );
    my $self = shift;
    my @returnList;

    my $maxID = Kirby::Database::History->count;
    my $minID = $maxID - ($self->param('num') or 25);

    Kirby::Database::History->iterate(
        'WHERE id > ? AND id <= ? ORDER BY id DESC', $minID, $maxID,
        sub {
            my @time = localtime($_->time);
            push(@returnList, {
                    time => sprintf("%02d",$time[2]).":".sprintf("%02d",$time[1])." ".($time[4]+1)."/$time[3]",
                    name => $_->name,
                    issue => $_->issue,
                    action => $_->action,
                });
        }
    );
    push(@returnList, undef);

    $self->render(json => \@returnList);
};

sub dbQuery {
    my $self = shift;

    my $q = $self->params('q');
}

sub cover {
    my $self = shift;

    $self->render(data => Kirby::Database::Comics->select('cover WHERE id = ?', $self->param('id')), format => 'image/jpeg');
}
1;
