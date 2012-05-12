package Kirby::Database;

use strict;
use warnings;

use ORLite {
    file         => "data/test.db",
    user_version => 7,
    create       => sub {
        #my $dbh = shift;
        #$dbh->do('PRAGMA user_version = 6;');
        #$dbh->do('CREATE TABLE comics ( id INTEGER PRIMARY KEY, cover BLOB, series TEXT, volume INT, issue INT, title TEXT, description TEXT );');
        #$dbh->do('CREATE TABLE nzb ( id INTEGER PRIMARY KEY, releaseDate TEXT, origYear TEXT, tags TEXT, series TEXT, issue INT, url TEXT );');
        #$dbh->do('CREATE TABLE history ( id INTEGER PRIMARY KEY, time TEXT, name TEXT, issue INT, action TEXT );');
        #$dbh->do('CREATE TABLE meta ( id INTEGER PRIMARY KEY, time TEXT, asset TEXT, hash TEXT );');
        system('`which sqlite3`', 'data/test.db', '<', 'docs/db.sql');
    },
};

1;
