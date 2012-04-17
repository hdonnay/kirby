package Kirby::Database;

use strict;
use warnings;

use ORLite {
    file         => "data/test.db",
    #user_version => 1,
    create       => sub {
        my $dbh = shift;
        $dbh->do('CREATE TABLE comics ( id INTEGER PRIMARY KEY, cover BLOB, series TEXT, volume INT, issue INT, title TEXT, description TEXT ); CREATE TABLE nzb ( id INTEGER PRIMARY KEY, release_date TEXT, series TEXT, issue INT, url TEXT ); PRAGMA user_version = 2;');
    },
};

1;
