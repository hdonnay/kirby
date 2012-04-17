# Part of Kirby.
# See the COPYING file that should have been distributed with this software.
# https://raw.github.com/hdonnay/kirby/master/COPYING
package Kirby::Static;

use strict;
use warnings;

use Mojo::Base 'Mojolicious::Controller';

sub index {
    my $self = shift;

    $self->stash(tabs => [
            ["first tab", "#"],
            ["second tab", "#"],
            ["third tab", "#"],
            ["fourth tab", "#"],
        ]);

    $self->render('index');
}

sub about {
    my $self = shift;

    $self->stash(navbarName => "This project uses:");
    $self->stash(navbar => [
            ["Bootstrap", "http://twitter.github.com/bootstrap"],
            ["Comicvine", "http://api.comicvine.com/"],
            ["Mojolicious", "http://mojolicio.us"],
            ["Perl", "http://www.perl.org"],
        ]);

    $self->render('about');
}

1;
