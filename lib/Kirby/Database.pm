# Part of Kirby.
# See the COPYING file that should have been distributed with this software.
# https://raw.github.com/hdonnay/kirby/master/COPYING
package Kirby::Database;

use strict;
use warnings;

use Mojo::Base 'Mojolicious::Plugin';
use Kirby::SQL;
use Data::Dumper;
use Digest::SHA;

sub register {
    my ($self, $app) = @_;

    $app->helper( displayBook => sub {
            my $self = shift;

            my $id = shift || undef;
            my %item = Kirby::Database->fetch(id => $id);

            print "===\n".Dumper(%item)."\n===\n";
            if (defined $item{'failed'}) {
                return "<h3 class='popup'>%$item{'failed'}</h3>";
            }
            else {
                return "<div id='book'><img src='$item{'pic'}' /><h4>$item{'series'}&nbsp;#$item{'issue'}</h4><h5>$item{'title'}</h5><br /><p>$item{'description'}</p></div>";
            };
        }
    );
}

sub search {
    my $self = shift;

    my @results;
    my %args = @_;
    my %defaults = (
        q => "",
    );
    my %params = (%defaults, %args);

    Kirby::SQL::Kirby->iterate('where series = ? order by id', $params{'q'}, sub {
            print "$params{'q'}\n";
            push @results, $_->id;
        }
    );

    return @results;
}

sub fetch {
    my $self = shift;

    my %args = @_;
    if (not defined $args{'id'}) {
        return ( failed => "No ID" );
    }
    else {
        my $book = Kirby::SQL::Kirby->load($args{'id'});
        my $digest = Digest::SHA->new(256)->add($book->id.$book->series)->hexdigest;
        my %hash = (
            pic => "/covers/".substr($digest,0,2)."/".substr($digest,3),
            series => $book->series,
            issue => $book->issue,
            title  => $book->title,
            description => $book->description,
        );
        return %hash;
    };
}

1;
