#!/usr/bin/env perl
use strict;
use warnings;

use Mojolicious::Lite;
use DBI;
use FindBin;
use Data::Dumper;
use LWP::Simple ();
use XML::Parser;

use lib::Kirby;

my $db = "./test.db";

my $dbh = DBI->connect( "dbi:SQLite:dbname=$db", "", "", { RaiseError => 1, AutoCommit => 1 } );
my $rss = XML::Parser->new(Style => 'Tree', ErrorContext => 2);

$dbh->do(
    "CREATE TABLE IF NOT EXISTS kirby (
        id INTEGER PRIMARY KEY,
        series TEXT,
        volume INT,
        issue INT,
        title TEXT,
        description TEXT
    );"
);

get '/' => sub {
    my $self = shift;
    my $kirbObject = Kirby->new{ db => $db, comicsDir => '/export/Comics/', };
    $self->render(
        text => "Kirby\n<pre>".$kirbObject->getRSS."</pre>",
    );
};

get '/dump' => sub {
    my $self = shift;
    my $sth = $dbh->prepare("SELECT * FROM kirby;");
    my $result;
    $sth->execute();
    while (my @row = $sth->fetchrow_array()) {
        $result .= join(", ",@row)."\n";
    };
    $self->render(
        text => "<pre>$result</pre>",
    );
};

get '/add'  => sub {
    $dbh->do(
        "INSERT INTO kirby (
            series,
            volume,
            issue,
            title,
            description
        )
        VALUES (
            'Iron Man',
            '1',
            '1',
            'test',
            'test'
        );"
    );
};

app->start;
