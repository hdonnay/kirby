# Part of Kirby.
# See the COPYING file that should have been distributed with this software.
# https://raw.github.com/hdonnay/kirby/master/COPYING
package Kirby::Index;

use strict;
use warnings;

use Mojo::Base 'Mojolicious::Controller';

sub index {
    my $self = shift;

    $self->app->log->debug($feed);

    $self->stash(feed => { title => "Title" });
    $self->stash(feed => { date => "today" });

    $self->render('index');
}

1;
