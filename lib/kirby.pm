package kirby;

use strict;
use warnings;

use base 'Mojo';

sub handler {
    my ($self, $tx) = @_;

    # Hello world!
    $tx->res->headers->content_type('text/plain');
    $tx->res->body('Hello Mojo!');
}

1;
