package Kirby;

use strict;
use warnings;

use Mojo::Base 'Mojolicious';
use FindBin;
use Data::Dumper;

use Kirby::Database;
use Kirby::Scraper::SimpleScraper;

our $VERSION = "0.01";

sub startup {
    my $self = shift;

    $self->secret('Kirby Default');

    my $r = $self->routes;

    my $show = $r->route('/show')->to(controller => 'show');
    $show->route('/issue/:id')->to(action => 'issue');
    $show->route('/series/:title')->to(action => 'series');

    $r->any('/' => sub {
        my $self = shift;
        $self->stash(
            head => "Kirby",
        );
        $self->render('index');
    } => 'index');

    $r->any('/dump' => sub {
        my $self = shift;

        $self->stash(results => \@{Kirby::Database::Kirby->select()},);
        return $self->render('dump');
    });

    $r->any('/search' => sub {
        my $self = shift;
        my $q = $self->param('q') || undef;
        if ( defined $q ) {
            my $scrape = Kirby::Scraper::SimpleScraper->new( directory => '/export/Comics', );
            my @result = $scrape->search( q => $q, );
            $self->app->log->debug(Dumper @result);
            $self->flash(
                results => [ @result ],
                message => "sucessful query to SimpleScraper"
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
            my $comicID = Kirby::Database::Kirby->create(
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

    $r->any('/info' => 'info');
}

1;
