# Part of Kirby.
# See the COPYING file that should have been distributed with this software.
# https://raw.github.com/hdonnay/kirby/master/COPYING
package Kirby::Sockets;

use strict;
use warnings;

use Mojo::Base 'Mojolicious::Controller';
use XML::FeedPP;

sub rss {
    my $self = shift;

    my $feed;

    $self->on(message => sub {
        if ($_[1] eq 'ehlo') {
            $self->send("<h3>".$feed->title()."</h3>");
            foreach my $item ( $feed->get_item() ) {
                $self->send("<li><a href=\"".$item->link()."\">".$item->title()."</a></li>");
            }
        } elsif ($_[1] eq 'fetch') {
            $feed = XML::FeedPP->new('http://www.comicvine.com/feeds/new_comics');
     }
    });
}

1;
