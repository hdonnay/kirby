# Part of Kirby.
# See the COPYING file that should have been distributed with this software.
# https://raw.github.com/hdonnay/kirby/master/COPYING
package Kirby::Config;

use strict;
use warnings;

use Config::General;

sub new {
    my $self = shift;

    my %args = @_;
    my %defaults = {
        dir => ".",
    };
    my %params = (%defaults, %args);
    my @path = qw(/etc/kirby/ ~/.kirby);
    push @path, %params{'dir'};

    my $conf = Config::General->new(
        -ConfigFile => "kirby.rc",
        -LowerCaseNames => 1,
        -ConfigPath => \@path,
        -MergeDuplicateOptions => 1,
        -AutoTrue => 1,
    );

    my $params{'conf'} = $conf->getall();

    return bless \%params, $self;
}

1;
