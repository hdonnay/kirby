# Part of Kirby.
# See the COPYING file that should have been distributed with this software.
# https://raw.github.com/hdonnay/kirby/master/COPYING
package Kirby::Comicvine;

use strict;
use warnings;

use Mojo::UserAgent;
use Mojo::Util qw/url_escape/;
use Mojo::JSON;
use Data::Dumper;

sub new {
    my $self = shift;
    my %args = @_;
    my %defaults = (
        api     => '',
        url     => 'http://api.comicvine.com',
    );
    my %object = (%defaults, %args);

    $object{'ua'} = Mojo::UserAgent->new();
    $object{'req'} = "$object{'url'}/?api_key=$object{'api'}";
    return bless \%object, $self;
}

sub search {
    my $self = shift;
    my $json = Mojo::JSON->new();
    my %args = @_;
    my %defaults = (
        query => '',
        # blank query seems acceptable to the API
        filter => ["issue", "volume"],
        # searching for issue and volume seems like a sane default
    );
    my %object = (%defaults, %args);

    my $req = "$self{'req'}&query=".url_escape($object{'query'});
    $req .="&resources=".join(',', $object{'filter'});
    $req .= "&format=json";

    my $res = $self{'ua'}->get($req)->res->body;
    print Dumper \$res;
    return $json->decode($res);
}

1;
