# Part of Kirby.
# See the COPYING file that should have been distributed with this software.
# https://raw.github.com/hdonnay/kirby/master/COPYING
package Kirby::Config;

use strict;
use warnings;

use Mojo::Base 'Mojolicious::Controller';

sub dump {
    my $self = shift;

    return $self->render('config/dump');
}

sub reload {
    my $self = shift;

    $self->app->defaults(config => $self->app->plugin('JSONConfig', (file => 'kirby.json',)));
    return $self->flash(message => "Config Reloaded",)->redirect_to('/config/dump');
}

sub insert {
    my $self = shift;

    return $self->render('config/dump');
}

1;
