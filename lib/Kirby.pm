package Kirby;

use strict;
use warnings;

use Mojo::Base 'Mojolicious';
#use Data::Dumper;

#use Kirby::Scraper::SimpleScraper;

our $VERSION = "0.01";

sub startup {
    my $self = shift;

    my $r = $self->routes;

    # Static boring stuff
    $r->any('/')->to(controller => 'static', action => 'index');
    $r->any('/about')->to(controller => 'static', action => 'about');

    # Displaying db items
    my $show = $r->route('/show')->to(controller => 'show');
        $show->route('/issue/:id')->to(action => 'issue');
        $show->route('/series/:title')->to(action => 'series');
        $show->route('/results')->to(action => 'results');
        $show->route('/all')->to(action => 'all');

    # configuration shit
    my $conf = $r->route('/config')->to(controller => 'config');
        $conf->route('/')->to(action => 'dump');
        $conf->route('/dump')->to(action => 'dump');
        $conf->route('/load')->to(action => 'reload');
        $conf->route('/load')->via('POST')->to(action => 'insert');

    # backend things.
    # 'search' is a ui for backend/dbQuery
    $r->any('/search' => 'search');
    my $backend = $r->route('/backend')->to(controller => 'backend');
        $backend->route('/rss')->via('GET')->to(action => 'rssDump');
        $backend->route('/rss')->via('POST')->to(action => 'rssRefresh');
        $backend->route('/add')->via('GET')->to(action => 'lastAddState');
        $backend->route('/add')->via('POST')->to(action => 'add');
        $backend->route('/dbQuery')->via('GET')->to(action => 'dbQuery');

    $self->secret('Kirby Default');
    $self->defaults(config => $self->plugin(JSONConfig => {file => 'data/config.json'}) );
    $self->defaults(navbar => undef );
    $self->defaults(tabs => undef );
}

1;
