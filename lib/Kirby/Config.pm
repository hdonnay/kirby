# Part of Kirby.
# See the COPYING file that should have been distributed with this software.
# https://raw.github.com/hdonnay/kirby/master/COPYING
package Kirby::Config;

use strict;
use warnings;

use Mojo::Base 'Mojolicious::Controller';

sub index {
    my $self = shift;

    $self->stash(tabs => [
            ["Main", "#main"],
            ["SABnzbd", "#sabnzbd"],
            ["Scraper", "#scraper"],
            ["Dump", "#dump"],
        ]);

    return $self->render('config/index');
}

sub dump {
    return shift->render('config/dump');
}

sub reload {
    my $self = shift;

    $self->app->defaults(config => $self->app->plugin('JSONConfig', (file => 'data/config.json',)));
    return $self->flash(notice => "Config Reloaded",)->redirect_to('/config/dump');
}

sub insert {
    my $self = shift;

    if ( (defined $self->app->param('name')) and ($self->app->param('value')) ) {
        $self->app->stash('config')->{$self->app->param('name')} = $self->app->param('value');
        return $self->render(json => {code => 200});
    } else {
        return $self->render(json => {code => 400});
    };
}

1;
