#!/usr/bin/env perl
use strict;
use warnings;

use Mojolicious::Lite;
use FindBin;
use Data::Dumper;
use LWP::Simple ();
use XML::Parser;

use lib 'lib';
use Kirby;
use Kirby::Database;

get '/' => sub {
    my $self = shift;
    my $kirbObject = Kirby->new( omicsDir => '/export/Comics/', );
    $kirbObject->getRSS;
    print Dumper $kirbObject->{'feedContents'};
    $self->stash(
        feed => @{$kirbObject->{'feedContents'}},
        head => "Kirby",
    );
    $self->render();
};

get '/dump' => sub {
    my $self = shift;
    my $result;
    Kirby::Database::Kirby->iterate( sub {
            $result .= $_->series." | ".$_->issue."\n";
        } );
    $self->render(
        text => "<pre>$result</pre>",
    );
};
#
#get '/add'  => sub {
#    $dbh->do(
#        "INSERT INTO kirby (
#            series,
#            volume,
#            issue,
#            title,
#            description
#        )
#        VALUES (
#            'Iron Man',
#            '1',
#            '1',
#            'test',
#            'test'
#        );"
#    );
#};

app->start;

__DATA__

@@ index.html.ep
% layout 'default';
<em><%= $head %></em>
<pre>
% foreach (@$feed) {
    <%= $_ %>
% }
</pre>

@@ layouts/default.html.ep
<!DOCTYPE html>
<html>
  <head><title>Kirby Comic Grabber</title></head>
  <body><%= content %></body>
</html>
