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
use Kirby::SABnzbd;

my %dateTranslate = (
    'Sun' => '0',
    'Mon' => '1',
    'Tue' => '2',
    'Wed' => '3',
    'Thu' => '4',
    'Fri' => '5',
    'Sat' => '6',
    'Jan' => '01',
    'Feb' => '02',
    'Mar' => '03',
    'Apr' => '04',
    'May' => '05',
    'Jun' => '06',
    'Jul' => '07',
    'Aug' => '08',
    'Sep' => '09',
    'Oct' => '10',
    'Nov' => '11',
    'Dec' => '12',
);
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
            my @record = Kirby::Database::Nzb->select('where url = ?', $_->enclosure->{'url'});
            unless (@record) {
                my @dateArray = split(/[ ,:]+/, $_->pubDate->text);
                my $pubDate = "$dateArray[3]-$dateTranslate{$dateArray[2]}-$dateArray[1]T$dateArray[4]:$dateArray[5]:$dateArray[6]";
                my ($rawDate, $rawTitle) = $_->title->text =~ m/0-day \(([0-9\-]+)\) w\/ PARs \[\d+\/\d+\] - \"?(.+)\.cb[rz]\"?.*/;
                my $issue;
                my $origYear;
                my $rlsDate = $rawDate;
                my @tags = split(/ *\( *|\) *\(| *\) */, $rawTitle);
                my @titleTok = split(' ', shift @tags);
                if ($titleTok[-1] =~ m/\d/ ) {$issue = pop @titleTok};
                my $series = join(' ', @titleTok);
                #catch various naming conventions
                if ($tags[0] =~ m/[0-9]{4}/) { $origYear = shift @tags; }
                elsif($tags[0] =~ /of \d+/) { shift @tags; $origYear = shift @tags; }
                elsif($tags[0] eq "c2c") { $origYear = $tags[1]; delete $tags[1]; }
                #Thu, 03 May 2012 05:22:29 +0200
                #YYYY-MM-DDTHH:MM:SS
                print("releaseDate => ".$rlsDate."\n");
                print("pubDate => ".$pubDate."\n");
                print("origYear => ".$origYear."\n");
                print("tags => ".join(',',@tags)."\n");
                print("series => ".$series."\n");
                print("issue => ".$issue."\n");
                print("url => ".$_->enclosure->{'url'}."\n");
                Kirby::Database::Nzb->create(
                    time => $pubDate,
                    releaseDate => $rlsDate,
                    origYear => $origYear,
                    tags => join(',',@tags),
                    series => $series,
                    issue => $issue,
                    url => $_->enclosure->{'url'},
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

    my $offset = $self->param('offset');
    my $returnResults = 14; #meaning 15

    Kirby::Database::Nzb->iterate(
        'ORDER BY time ASC LIMIT ? OFFSET ?', $returnResults, (($offset || 0)* $returnResults),
        sub {
            #print Dumper \$_;
            my @tags = split(',', $_->tags);
            push(@returnList, {
                    time => $_->time,
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

    my $q = $self->param('q');
}

sub cover {
    my $self = shift;

    $self->render(data => Kirby::Database::Comics->select('cover WHERE id = ?', $self->param('id')), format => 'image/jpeg');
}

sub download {
    my $self = shift;

    my $SABcfg = $self->stash->{'config'}->{'sabnzbd'};
    my $SAB = Kirby::SABnzbd->new(
        baseUrl => $SABcfg->{'host'}.':'.($SABcfg->{'port'} || 80),
        api     => $SABcfg->{'apikey'},
    );
    $self->render(text => $SAB->send($self->param('q')));
    my @dbRes = Kirby::Database::Nzb->select('WHERE url = ?', $self->param('q'));
    my %book = $dbRes[0];
    print Dumper \%book;
    Kirby::Database::History->create(
        time => time,
        name => $book{'series'},
        issue => $book{'issue'},
        action => "Sent to SABnzbd.",
    );
}

sub postProcessing {
    my $self = shift;

    if (not $self->param('success')) { return $self->render(json => (res => 200, status => 'failed')); }

    my $cv = Kirby::Comicvine->new( api => $self->stash->comicvine->apikey );
    my @dbRes = Kirby::Database::Nzb->select('WHERE url = ?', $self->param('success'));
    my %book = $dbRes[0];

    my @res = $cv->search(
        query => "$book{'series'} $book{'issue'}",
        filters => ["issue"],
    );
    print Dumper \@res;
    return $self->render(json => (res => 200, status => 'success'));
}

1;
