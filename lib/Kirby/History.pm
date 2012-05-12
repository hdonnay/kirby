# Part of Kirby.
# See the COPYING file that should have been distributed with this software.
# https://raw.github.com/hdonnay/kirby/master/COPYING
package Kirby::History;

use strict;
use warnings;

use Mojo::Base 'Mojolicious::Controller';
use Kirby::Database;
#CREATE TABLE history ( id INTEGER PRIMARY KEY, time INTEGER, name TEXT, issue INT, action TEXT );

sub index {
    my $self = shift;

    $self->stash(tabs => [
            ["Recent Activity", "#ra"],
            ["Make History", "#mh"],
        ]);

    return $self->render('history/index');
}

sub insert {
    my $self = shift;

    Kirby::Database::History->create(
        time => time,
        name => $self->param('name'),
        issue => $self->param('issue'),
        action => $self->param('action'),
    );

    return $self->render(json => {status => 200} );
}
1;
