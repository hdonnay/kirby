package Kirby;

use LWP::Simple ();
use XML::FeedPP;
use FindBin;
use Data::Dumper;

sub new {
    my %defaults = {
        db => "./test.db",
        rss => ("http://findnzb.net/rss/?q=alt.binaries.comics.dcp&sort=newest",),
        comicsDir => "/export/Comics",
        feedContents => [],
    };
    my %params = %defaults;
    return bless \%params, shift;
}

sub getRSS {
    $self = shift;
    # print Dumper $self;
    # foreach my $source ($self->{'rss'}) {
    #     print "URL: ", $source, "\n";
        my $feed = XML::FeedPP->new( "http://findnzb.net/rss/?q=alt.binaries.comics.dcp&sort=newest" );
        foreach ($feed->get_item()) {
            push @{$self->{'feedContents'}}, "Title: ".$_->title();
        };
        # };
}

1;
