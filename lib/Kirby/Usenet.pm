# Part of Kirby.
# See the COPYING file that should have been distributed with this software.
# https://raw.github.com/hdonnay/kirby/master/COPYING
package Kirby::Usenet;

use strict;
use warnings;

use Mojo::Base 'Mojolicious::Controller';
use XML::FeedPP;
use Kirby::Database;

sub fetchRSS {
    my $self = shift;

    return unless (defined $self->stash->{'usenetRSS'});

    my $feed = XML::FeedPP->new($self->stash->{'usenetRSS'});

    foreach my $item ($feed->get_item()) {
        if ($item->title =~ m/^0-day\s+\((.*)\).+$/) {
            #insert into table
        }
    }

}

sub submitToSAB {
    my $self = shift;

}

sub submitToBlackhole {
    my $self = shift;

}

1;
