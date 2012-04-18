package Kirby::Backend::DisplayCover;

use strict;
use warnings;

use CGI;
use lib "../..";
use Kirby::Database;

my $img = CGI->new;
my $id = $img->param('id');

print "Content-type: image/jpeg\n\n";

print Kirby::Database::Comics->select('cover WHERE id = ?', $id);
