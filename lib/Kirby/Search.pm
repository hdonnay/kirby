# Part of Kirby.
# See the COPYING file that should have been distributed with this software.
# https://raw.github.com/hdonnay/kirby/master/COPYING
package Kirby::Search;

use strict;
use warnings;

use Mojo::Base 'Mojolicious::Controller';
use Kirby::Database;

sub search {
    my $self = shift;

    my $query = $self->param('q');

    $self->stash(desc => [Kirby::Database::Comics->select('id WHERE description LIKE ?', $query)],
                 titles => [Kirby::Database::Comics->select('id WHERE title LIKE ?',$query)],
                 series => [Kirby::Database::Comics->select('id WHERE series LIKE ?',$query)],
                 available => [Kirby::Database::Nzb->select('id WHERE date(release_date) = date(?) or series LIKE ?', $query, $query),],);

    $self->render('show/results');
}

1;
