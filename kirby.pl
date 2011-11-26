#!/usr/bin/env perl
use strict;
use warnings;

use Text::Sass;
use lib 'lib';
use Mojolicious::Commands;

$ENV{MOJO_APP} = 'Kirby';

Mojolicious::Commands->start;
