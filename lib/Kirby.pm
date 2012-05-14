package Kirby;

use strict;
use warnings;

use Mojo::Base 'Mojolicious';
#use AnyEvent::Loop;
use AnyEvent;
use Kirby::Backend;

our $VERSION = "0.01";

sub startup {
    my $self = shift;

    $self->secret('Kirby Default');
    $self->defaults(config => $self->plugin(JSONConfig => {file => 'data/config.json'}) );
    #$self->plugin('digest_auth', allow => { 'Kirby' => $self->plugin(JSONConfig => {file => 'data/users.json'})});
    $self->defaults(navbar => [ ["Manage", "manage"], ["History", "history"], ["Config", "config"] ]);
    $self->defaults(navbarName => "Choose Your Destiny...");
    $self->defaults(tabs => undef );
    $self->defaults(usenetRSS => 'http://www.nzbindex.nl/rss/?q=0-day&g[]=41&g[]=775&sort=agedesc&max=250&more=1' );
    $self->defaults(comicsRSS => 'http://feeds.feedburner.com/NewComicBooks' );

    my $fetch = AnyEvent->timer(
        after => 5,
        interval => 360,
        cb => sub {
            Kirby::Backend->usenetFetchAndStore;
        },
    );

    my $r = $self->routes;

    # Static boring stuff
    my $static = $r->route('/')->to(controller => 'static');
        $static->any('/')->to(action => 'index');
        $static->any('/about')->to(action => 'about');

    # Displaying db items
    my $manage = $r->route('/manage')->to(controller => 'manage');
        $manage->route('/')->to(action => 'index');
        $manage->route('/issue/:id')->to(action => 'issue');
        $manage->route('/series/:title')->to(action => 'series');
        $manage->route('/all')->to(action => 'all');

    # History
    my $history = $r->route('/history')->to(controller => 'history');
        $history->route('/')->to(action => 'index');

    # configuration shit
    my $conf = $r->route('/config')->to(controller => 'config');
        $conf->route('/')->to(action => 'index');
        $conf->route('/dump')->to(action => 'dump');
        $conf->route('/load')->to(action => 'reload');
        $conf->route('/load')->via('POST')->to(action => 'insert');

    $r->route('/search')->to(controller => 'search', action => 'search');

    # backend things.
    my $backend = $r->route('/backend')->to(controller => 'backend');
        #JSON stuff
        $backend->route('/rss.json')->via('GET')->to(action => 'rssToJSON');
        $backend->route('/history.json')->via('GET')->to(action => 'historyToJSON');
        $backend->route('/usenetDB.json')->via('GET')->to(action => 'usenetToJSON');
        #Talk back
        $backend->route('/usenetDB')->via('POST')->to(action => 'usenetFetchAndStore');
        $backend->route('/history/insert')->via('POST')->to(controller => 'history', action => 'insert');
        #misc GET
        $backend->route('/cover.jpg')->via('GET')->to(action => 'cover');
        #unimplemented
        $backend->route('/add')->via('GET')->to(action => 'lastAddState');
        $backend->route('/add')->via('POST')->to(action => 'add');
        $backend->route('/dbQuery')->via('GET')->to(action => 'dbQuery');
}

1;
