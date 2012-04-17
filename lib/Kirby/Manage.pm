# Part of Kirby.
# See the COPYING file that should have been distributed with this software.
# https://raw.github.com/hdonnay/kirby/master/COPYING
package Kirby::Manage;

use strict;
use warnings;

use Mojo::Base 'Mojolicious::Controller';
use Kirby::Database;

sub issue {
    my $self = shift;

    if (my $id = $self->stash('id')) {
        if ($id <= Kirby::Database::Comics->count) {
            $self->stash(result => Kirby::Database::Comics->load($id));
        } else {
            $self->stash(result => undef);
            $self->flash(error => "Issue ID not valid.");
            return $self->redirect_to('/search');
        };
        return $self->render('show/issue');
    }
    else {
        $self->flash(error => "Issue ID not specified.");
        return $self->redirect_to('/search');
    };
}

sub series {
    my $self = shift;

    if (my $series = $self->stash('series')) {
        $self->stash(series => Kirby::Database::Comics->select('where series = ?', $series),);
        return $self->render('show/series');
    }
    else {
        return $self->redirect_to('/search');
    };
}

sub all {
    my $self = shift;

    $self->stash(results => [Kirby::Database::Comics->select('order by id')],);
    $self->render('show/all');
}

1;
