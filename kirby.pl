#!/usr/bin/env perl
use strict;
use warnings;

use lib 'lib';
use Mojolicious::Commands;

$ENV{MOJO_APP} = 'Kirby';
$ENV{MOJO_MODE} = 'debug';

Mojolicious::Commands->start;
