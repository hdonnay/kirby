package Kirby::SQL;

use strict;
use warnings;

use ORLite {
    file         => "./test.db",
    #user_version => 1,
    create       => sub {
                        my $dbh = shift;
                        #$dbh->pragma( user_version => 1 );
                        $dbh->do('CREATE TABLE kirby ( id INTEGER PRIMARY KEY,
                                                       series TEXT,
                                                       volume INT,
                                                       issue INT,
                                                       title TEXT,
                                                       description TEXT );');
                    },

};

1;
