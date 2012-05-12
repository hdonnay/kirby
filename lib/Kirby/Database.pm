package Kirby::Database;

use strict;
use warnings;

use ORLite {
    file         => "data/test.db",
    user_version => 8,
    create       => sub {
        system('`which sqlite3`', 'data/test.db', '<', 'docs/db.sql');
    },
};

1;
