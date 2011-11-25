package Kirby;

use LWP::Simple ();
use XML::Parser;
use FindBin;

sub new {
    my %defaults = {
        db => undef,
        rss => ("http://findnzb.net/rss/?q=alt.binaries.comics.dcp&sort=newest",),
        comicsDir => undef,
    };
};

sub getRSS {
    $self = shift;
    my $rss = XML::Parser->new(Style => 'Tree', ErrorContext => 2);
    my $content = LWP::Simple::get("http://findnzb.net/rss/?q=alt.binaries.comics.dcp&sort=newest");
    my @tree = $rss->parse($content);
    my @feed = $tree[1];
    return @feed;
};

1;
