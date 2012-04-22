package Kirby::Database;

use strict;
use warnings;

use ORLite {
    file         => "data/test.db",
    #user_version => 1,
    create       => sub {
        my $dbh = shift;
        $dbh->do('PRAGMA user_version = 3;');
        $dbh->do('CREATE TABLE comics ( id INTEGER PRIMARY KEY, cover BLOB, series TEXT, volume INT, issue INT, title TEXT, description TEXT );');
        $dbh->do('CREATE TABLE nzb ( id INTEGER PRIMARY KEY, release_date TEXT, series TEXT, issue INT, url TEXT );');
        $dbh->do('CREATE TABLE history ( id INTEGER PRIMARY KEY, time TEXT, name TEXT, issue INT, action TEXT );');
    },
};

1;
