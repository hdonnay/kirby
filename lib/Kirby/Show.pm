# Part of Kirby.
# See the COPYING file that should have been distributed with this software.
# https://raw.github.com/hdonnay/kirby/master/COPYING
package Kirby::Show;

use strict;
use warnings;

use Kirby::Database;

my $db = Kirby::Database::Kirby;

sub issue {
    my $self = shift;

    if (defined $id) {
        $self->stack(issue => $db->load($id),);
        return $self->render('show/issue');
    }
    else {
        return $self->redirect_to('/search');
    };
}

sub series {
    my $self = shift;

    if (defined $series) {
        $self->stack(series => $db->select('where series = ?', $series),);
        return $self->render('show/series');
    }
    else {
        return $self->redirect_to('/search');
    };
}

1;
