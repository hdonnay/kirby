# Part of Kirby.
# See the COPYING file that should have been distributed with this software.
# https://raw.github.com/hdonnay/kirby/master/COPYING
package Kirby::Backend;

use strict;
use warnings;

use Mojo::Base 'Mojolicious::Controller';
use Switch 'Perl6';
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
    $res->dom('item')->map(sub {
            my $item = shift;
            my @record = Kirby::Database::Nzb->select('where url = ?', $_->link->text);
            unless ( (@record) and ($record[0]->url eq $_->link->text) ) {
                my @tags; my $rlsDate; my $origYear; my $series; my $issue; # need these for insertion
                foreach (@regex) {
                    if ($item->title->text =~ $_) { $fmt = $i }
                    $i++;
                }
                # in these cases, you have the match variables from the regex that sets $fmt
                # only using a goto because fucking switches wouldn't work
PROCESSING:     if ($fmt == 2) {
                    $1 =~ s/\./-/g;
                    $fmt = 1;
                    goto PROCESSING;
                } elsif ($fmt == 1 ) {
                    $rlsDate = $1;
                    @tags = split(/ *\( *|\) *\(| *\) */, $2);
                    my @titleTok = split(' ', shift @tags);
                    if ($titleTok[-1] =~ m/\d/ ) {$issue = pop @titleTok};
                    $series = join(' ', @titleTok);
                    #catch various naming conventions
                    if ($tags[0] =~ m/[0-9]{4}/) { $origYear = shift @tags; }
                    elsif($tags[0] =~ /of \d+/) { shift @tags; $origYear = shift @tags; }
                    elsif($tags[0] eq "c2c") { $origYear = $tags[1]; delete $tags[1]; }
                }
                print Dumper {
                    time => localtime(time),
                    releaseDate => $rlsDate,
                    origYear => $origYear,
                    tags => join(',',@tags),
                    series => $series,
                    issue => $issue,
                    url => $_->link->text,
                };
                Kirby::Database::Nzb->create(
                    time => localtime(time),
                    releaseDate => $rlsDate,
                    origYear => $origYear,
                    tags => join(',',@tags),
                    series => $series,
                    issue => $issue,
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
