# Part of Kirby.
# See the COPYING file that should have been distributed with this software.
# https://raw.github.com/hdonnay/kirby/master/COPYING
package Kirby::Backend;

use strict;
use warnings;

use Mojo::Base 'Mojolicious::Controller';
#use Mojo::JSON;
use Mojo::UserAgent;
use Kirby::Database;

sub rssToJSON {
    my $self = shift;

    my $ua = Mojo::UserAgent->new(max_redirects => 4);
    my $res = $ua->get( $self->stash('comicsRSS') )->res;

    $self->render(json => [$res->dom('item')->map(sub {
                my $desc;
                if ($self->stash('comicsRSS') eq "http://feeds.feedburner.com/NewComicBooks") {
                    ($desc = $_->description->text) =~ s/a href=\"/a href=\"http:\/\/www.comicvine.com/g;
                } else {
                     $desc = $_->description->text;
                };
                return [ $_->title->text, $_->link->text, undef, $desc ];
            })->each, undef] );
}

sub usenetFetch {
    my $self = shift;

    my $ua = Mojo::UserAgent->new(max_redirects => 4);
    my $res = $ua->get( $self->stash('usenetRSS') )->res;

    $self->render(json => [$res->dom('item')->map(sub {
                $_->title->text =~ m/0-day \(([0-9\-]+)\) w\/ PARs \[\d+\/\d+\] - \"?(.+).cb[rz]\"?.*/;
                my @tokens = split(/ *\(|\) \(|\) */, $2);
                if (defined $2) {
                    return { rlsDate => $1, titleString => shift @tokens, year => shift @tokens, tags => \@tokens, link => $_->link->text };
                } else {
                    return;
                };
            })->each, undef] );
}

sub dbQuery {
    my $self = shift;

}

sub cover {
    my $self = shift;

    my $id = $self->param('id');
    $self->render(data => Kirby::Database::Comics->select('cover WHERE id = ?', $id), format => 'image/jpeg');
}
1;
