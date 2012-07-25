# Part of Kirby.
# See the COPYING file that should have been distributed with this software.
# https://raw.github.com/hdonnay/kirby/master/COPYING
package Kirby::SABnzbd;

use strict;
use warnings;

use Mojo::UserAgent;
use Mojo::Util qw/url_escape/;
use Mojo::JSON;

sub new {
    my $self = shift;
    my %args = @_;
    my %defaults = (
        baseUrl => '',
        api     => '',
        auth    => '',
        url     => '',
    );
    my %object = (%defaults, %args);

    if ($object{'auth'} ne '') {
        $object{'baseUrl'} =~ s/^(https?:\/\/)//;
        $object{'url'} = "$1$object{'auth'}\@$object{'baseUrl'}/api?apikey=$object{'api'}";
    } else {
        $object{'url'} = "$object{'baseUrl'}/api?apikey=$object{'api'}";
    }

    $object{'ua'} = Mojo::UserAgent->new();
    return bless \%object, $self;
}

sub send {
    my $self = shift;
    my $nzb = shift;

    my $q = "$self->{'url'}&mode=addurl&name=".url_escape($nzb)."&category=Comics&priority=-1";
    return $self->{'ua'}->get($q)->res->body;
}
sub markDownloaded {
}

1;
