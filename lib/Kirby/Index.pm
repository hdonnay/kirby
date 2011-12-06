# Part of Kirby.
# See the COPYING file that should have been distributed with this software.
# https://raw.github.com/hdonnay/kirby/master/COPYING
package Kirby::Index;

use strict;
use warnings;

use Mojo::Base 'Mojolicious::Controller';
use XML::FeedPP;

my $rssFeed = 'http://www.comicvine.com/feeds/new_comics/';

sub index {
    my $self = shift;

    $self->render('index');
}

sub updateRSS{
    my $self = shift;

    my $feed = XML::FeedPP->new($rssFeed);
    $self->app->log->debug($feed);

}

1;
