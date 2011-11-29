package Kirby::Scraper::SimpleScraper;

use strict;
use warnings;

use Mojo::JSON;
use Mojo::UserAgent;
use Data::Dumper;

my $ua = Mojo::UserAgent->new;
my $json = Mojo::JSON->new;

my $APIkey = '?api_key=fda89ace04f5226217fb61f7d4658a2d728e9e08';
my $APIurl = 'http://api.comicvine.com/';
my $APIfomat = '&format=json';

sub new {
    my $self = shift;
    my %args = @_;
    my %defaults = (
        directory => ".",
    );
    my %params = (%defaults, %args);

    return bless \%params, $self;
}

sub search {
    my $self = shift;

    my %args = @_;
    my $qURL = $APIurl.'search/'.$APIkey.'&field_list=volume&query='.$args{q}.$APIfomat;
    my @results;
    print $qURL."\n";

    foreach (@{$ua->get($qURL)->res->json->{'volume'}}) {
        push @results, $_;
    }
    print Dumper @results;
    return @results;
    # my $response = get( $qURL );
    # my $results = $json->decode($response);
}

1;
