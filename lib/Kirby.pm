package Kirby;

use strict;
use warnings;

use Mojo::Base 'Mojolicious';
use Mojo::UserAgent;
use FindBin;
use Data::Dumper;

use Kirby::Scraper::SimpleScraper;
#use Kirby::Database;

our $VERSION = "0.01";

sub startup {
    my $self = shift;

    my $r = $self->routes;
    $self->plugin('Kirby::Database');

    my $show = $r->route('/show')->to(controller => 'show');
        $show->route('/issue/:id')->to(action => 'issue');
        $show->route('/series/:title')->to(action => 'series');
    $r->route('/dump')->to(controller => 'show', action => 'dump');

    my $conf = $r->route('/config')->to(controller => 'config');
        $conf->route('/load')->to(action => 'reload');
        $conf->route('/dump')->to(action => 'dump');
        $conf->route('/load')->via('POST')->to(action => 'insert');

    $r->any('/')->to('index#index');

    $r->any('/search' => sub {
        my $self = shift;
        my $q = $self->param('q') || undef;
        if ( defined $q ) {
            my @results = Kirby::Database->search(q => $q);

            $self->flash(
                message => "Results:",
                results => \@results,
            );
            $self->redirect_to('search');
        }
        elsif ( defined 'flash' ) {
            $self->render();
        }
        else {
            $self->flash(message => "unsuccessful query",);
            $self->redirect_to('search');
        };
    } => 'search');

    $r->any('/add'  => sub {
        my $self = shift;
        my $series = $self->param('series') || undef;
        my $volume = $self->param('vol') || undef;
        my $issue = $self->param('issue') || undef;
        my $title = $self->param('title') || 'N/A';
        my $description = $self->param('desc') || 'N/A';
        if ( (defined $series) and (defined $volume) and (defined $issue) ) {
            my $comicID = Kirby::SQL::Kirby->create(
                series => $series,
                volume => $volume,
                issue  => $issue,
                title  => $title,
                description => $description,
            );
            $self->render(
                text => "Inserted $series $volume $issue",
            );
        }
        else {
            $self->render(
                text => "Missing required fields",
            );
        };
    });

    $r->any('/about' => 'about');


    $r->websocket('/ws/rss' => sub {
        my $self = shift;

        my $ua = Mojo::UserAgent->new;
        my $tx = $ua->get('http://www.comicvine.com/feeds/new_comics');

        $self->on(message => sub {
            $self->send($tx->res->rss);
        });
    });

    $self->secret('Kirby Default');
    $self->defaults(config => $self->plugin('JSONConfig'), );
}

1;
