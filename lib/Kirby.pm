package Kirby;

use strict;
use warnings;

use Mojo::Base 'Mojolicious';
#use AnyEvent::Loop;
use AnyEvent;

our $VERSION = "0.01";

sub startup {
    my $self = shift;


    $self->secret('Kirby Default');
    $self->defaults(config => $self->plugin(JSONConfig => {file => 'data/config.json'}) );
    #$self->plugin('digest_auth', allow => { 'Kirby' => $self->plugin(JSONConfig => {file => 'data/users.json'})});
    $self->defaults(navbar => [ ["Manage", "manage"], ["History", "history"], ["Config", "config"] ]);
    $self->defaults(navbarName => "Choose Your Destiny...");
    $self->defaults(tabs => undef );
    $self->defaults(usenetRSS => "http://findnzb.net/rss/?group=alt.binaries.pictures.comics.dcp&sort=newest" );

    $self->log->debug("before loop");
    my $loop = AnyEvent->timer(
        after => 5,
        interval => 360,
        cb => sub {
            shift->log->debug("loop\n");
        },
    );
    $self->log->debug("after loop");

    my $r = $self->routes;

    # Static boring stuff
    my $static = $r->route('/')->to(controller => 'static');
        $static->any('/')->to(action => 'index');
        $static->any('/about')->to(action => 'about');

    # Displaying db items
    my $manage = $r->route('/manage')->to(controller => 'manage');
        $manage->route('/')->to(action => 'all');
        $manage->route('/issue/:id')->to(action => 'issue');
        $manage->route('/series/:title')->to(action => 'series');
        #$show->route('/results')->to(action => 'results');
        $manage->route('/all')->to(action => 'all');

    # configuration shit
    my $conf = $r->route('/config')->to(controller => 'config');
        $conf->route('/')->to(action => 'dump');
        $conf->route('/dump')->to(action => 'dump');
        $conf->route('/load')->to(action => 'reload');
        $conf->route('/load')->via('POST')->to(action => 'insert');

    $r->route('/search')->to(controller => 'search', action => 'search');

    # backend things.
    my $backend = $r->route('/backend')->to(controller => 'backend');
        $backend->route('/rss')->via('GET')->to(action => 'rssToJSON');
        $backend->route('/rss')->via('POST')->to(action => 'rssRefresh');
        $backend->route('/add')->via('GET')->to(action => 'lastAddState');
        $backend->route('/add')->via('POST')->to(action => 'add');
        $backend->route('/dbQuery')->via('GET')->to(action => 'dbQuery');
        $backend->route('/cover.jpg')->to(action => 'cover');
}

sub loopEvent {
    my $self = shift;

    $self->log->debug("loopEvent triggered");
}

1;
