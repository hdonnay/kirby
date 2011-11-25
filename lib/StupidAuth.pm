package StupidAuth;

use strict;
use warnings;

my $users = {
    hank => 'supersecret',
};

sub new {
    bless {}, shift;
}

sub check {
    my ($self, $user, $pass) = @_;

    return 1 if $users->{$user} && $users->{$users} eq $pass;

    return;
}
1;
