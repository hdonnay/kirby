package Kirby::Scraper::SimpleScraper;

use strict;
use warnings;

use JSON;
use LWP::Simple;
use Data::Dumper;

my $APIkey = '?api_key=fda89ace04f5226217fb61f7d4658a2d728e9e08';
my $APIurl = 'http://api.comicvine.com/';
my $APIfomat = '&format=json';

sub new {
    my $self = shift;
    my %args = @_;
    my %defaults = {
        directory => ".",
    };
    my %params = (%defaults, %args);

    return bless \%params, $self;
}

sub search {
    my $self = shift;

    my %args = @_;
    my $qURL = $APIurl.'search/'.$APIkey.'&field_list=volume,character&query='.$args{q}.$APIfomat;
    my $response = get( $qURL );
    my %results = decode_json $response;
}

1;
