package Kirby;

use LWP::Simple ();
use XML::Parser;
use FindBin;
use Data::Dumper;

sub new {
    my %args = @_;
    my %defaults = {
        db => undef,
        rss => ("http://findnzb.net/rss/?q=alt.binaries.comics.dcp&sort=newest",),
        comicsDir => undef,
    };
    my %params = (%defaults, %args);

    bless \%params, shift;
}

sub getRSS {
    $self = shift;
    my $rss = XML::Parser->new(Style => 'Tree', ErrorContext => 2);
    foreach ($self->{'rss'}) {
        my $content = LWP::Simple::get($_);
        my @tree = $rss->parse($content);
        my @feed = $tree[1];
        Dumper @feed;
    };
}

1;
