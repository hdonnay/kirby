# Part of Kirby.
# See the COPYING file that should have been distributed with this software.
# https://raw.github.com/hdonnay/kirby/master/COPYING
package Kirby::Backend;

use strict;
use warnings;

use Mojo::Base 'Mojolicious::Controller';
use Digest::MD5;
use Data::Dumper;
use Mojo::UserAgent;
use Kirby::Database;

sub rssToJSON {
    my $self = shift;

    my $ua = Mojo::UserAgent->new(max_redirects => 4);
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
    my $ua = Mojo::UserAgent->new(max_redirects => 4);

    my $res = $ua->get( $self->stash('usenetRSS') )->res;
    $res->dom('item')->map(sub {
            $_->title->text =~ m/0-day \(([0-9\-]+)\) w\/ PARs \[\d+\/\d+\] - \"?(.+).cb[rz]\"?.*/;
            if (defined $2) {
                my $hash = Digest::MD5->new->add($_->link->text)->hexdigest;
                my @record = Kirby::Database::Nzb->select('where hash = ?', $hash);
                if ( (not defined @record) or ($record[0]->hash ne $hash) ){
                    print "SQL Miss\n";
                    my @tokens = split(/ *\( *|\) *\(| *\) */, $2);
                    my @titleTok = split(' ', shift @tokens);
                    my $origYear = shift @tokens;

                   Kirby::Database::Nzb->create(
                        releaseDate => $1,
                        origYear => $origYear,
                        tags => join(',', @tokens),
                        series => join(' ',@titleTok[0 .. $#titleTok-1]),
                        issue => $titleTok[-1],
                        hash => $hash,
                        url => $_->link->text,
                    );
                    $rowsAdded++;
                    print "SQL Insertion\n";
                } else{
                    print "SQL Hit\n";
                };
            };
        })->each;

    if ($rowsAdded == 0) {
       $self->render(json => {status => 304});
    } else {
        $self->render(json => {status => 200, changes => $rowsAdded});
    };
}

sub usenetFetchFromDB {
    my $self = shift;
    my @returnList;

    my $maxID = (Kirby::Database::Nzb->count) - 1;
    my $minID = $maxID - 25;

    Kirby::Database::Nzb->iterate(
        'WHERE id >= ? AND id <= ?', $minID, $maxID,
        sub {
            my @tags = split(',', $_->tags);
            push(@returnList, {
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

sub dbQuery {
    my $self = shift;

}

sub cover {
    my $self = shift;

    my $id = $self->param('id');
    $self->render(data => Kirby::Database::Comics->select('cover WHERE id = ?', $id), format => 'image/jpeg');
}
1;
