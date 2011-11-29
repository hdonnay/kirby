# Part of Kirby.
# See the COPYING file that should have been distributed with this software.
# https://raw.github.com/hdonnay/kirby/master/COPYING
package Kirby::Show;

use strict;
use warnings;

use Mojo::Base 'Mojolicious::Controller';
use Kirby::Database;

sub issue {
    my $self = shift;

    if (my $id = $self->stack('$id')) {
        $self->stack(issue => Kirby::Database::Kirby->load($id),);
        return $self->render('show/issue');
    }
    else {
        return $self->redirect_to('/search');
    };
}

sub series {
    my $self = shift;

    if (my $series = $self->stash('series')) {
        $self->stack(series => Kirby::Database::Kirby->select('where series = ?', $series),);
        return $self->render('show/series');
    }
    else {
        return $self->redirect_to('/search');
    };
}

sub dump {
    my $self = shift;

    $self->stash(results => \@{Kirby::Database::Kirby->select()},);
    return $self->render('show/dump');
}

1;
