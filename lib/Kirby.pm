package Kirby;

use strict;
use warnings;

use Mojo::Base 'Mojolicious';
#use Mojo::UserAgent;
#use FindBin;
#use Data::Dumper;

#use Kirby::Scraper::SimpleScraper;

our $VERSION = "0.01";

sub startup {
    my $self = shift;


    my $r = $self->routes;
    #$self->plugin('Kirby::Database');

    my $show = $r->route('/show')->to(controller => 'show');
        $show->route('/issue/:id')->to(action => 'issue');
        $show->route('/series/:title')->to(action => 'series');
        $show->route('/all')->to(action => 'all');

    my $conf = $r->route('/config')->to(controller => 'config');
        $conf->route('/')->to(action => 'dump');
        $conf->route('/dump')->to(action => 'dump');
        $conf->route('/load')->to(action => 'reload');
        $conf->route('/load')->via('POST')->to(action => 'insert');

    $r->any('/')->to('static#index');
    $r->any('/about')->to('static#about');

    $r->any('/search' => sub {
        my $self = shift;

        $self->stash(navbar => {
            name => "Kirby",
            index => "/",
            search => "/search", },
            action => 'search'
        );

        my $q = $self->param('q') || undef;
        if ( defined $q ) {
            my @results = Kirby::Database->search(q => $q);

            $self->flash(
                notice => "Results:",
                results => \@results,
            );
            $self->redirect_to('search');
        }
        elsif ( defined 'flash' ) {
            $self->render();
        }
        else {
            $self->flash(alert => "unsuccessful query",);
            $self->redirect_to('search');
        };
    } => 'search');

#    $r->any('/add'  => sub {
#        my $self = shift;
#        my $series = $self->param('series') || undef;
#        my $volume = $self->param('vol') || undef;
#        my $issue = $self->param('issue') || undef;
#        my $title = $self->param('title') || 'N/A';
#        my $description = $self->param('desc') || 'N/A';
#        if ( (defined $series) and (defined $volume) and (defined $issue) ) {
#            my $comicID = Kirby::SQL::Kirby->create(
#                series => $series,
#                volume => $volume,
#                issue  => $issue,
#                title  => $title,
#                description => $description,
#            );
#            $self->render(
#                text => "Inserted $series $volume $issue",
#            );
#        }
#        else {
#            $self->render(
#                text => "Missing required fields",
#            );
#        };
#    });

    my $backend = $r->route('/backend')->to(controller => 'backend');
        $backend->route('/rss')->via('GET')->to(action => 'rssDump');
        $backend->route('/rss')->via('POST')->to(action => 'rssRefresh');
        $backend->route('/add')->via('GET')->to(action => 'lastAddState');
        $backend->route('/add')->via('POST')->to(action => 'add');

    $self->secret('Kirby Default');
    $self->defaults(config => $self->plugin('JSONConfig'), );
    $self->defaults(navbar => undef );
    $self->defaults(tabs => undef );
}

1;
