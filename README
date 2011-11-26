Kirby
=====

Kirby is a usenet comics downloader in the vein of [SickBeard](http://sickbeard.com) or [CouchPotato](http://couchpotatoapp.com/).

Basics
------

Kirby is written in perl, based on the [Mojolicious](http://mojolicio.us/) framework.

Wishlist
--------

 * Hopefully someone more talented than I will step up to help with the design of the web interface.
 * The RSS interface needs to be constructed.
 * The Scraper needs to be constructed.
 * Configurability needs to be added.
 * Interoperabliity with large nzb indexing sites.

Dependencies
------------

Kirby requires the following things to run, as best as I can remember:

 * [Mojolicious](http://mojolicio.us/)
 * [ORLite](http://search.cpan.org/perldoc?ORLite)
 * [LWP::Simple](http://search.cpan.org/perldoc?LWP::Simple)
 * [XML::FeedPP](http://search.cpan.org/perldoc?XML::FeedPP)

And for development, these are probably also required:
 * Data::Dumper
 * [sass](http://sass-lang.com/)

Development is done on a Debian stable box, and all packages are from the repos, save Mojolicious, which was installed via one-liner.
This means any version you can get your hands on should be new enough.

Installation
------------

I assume you're installing this for development, because of the early stage this is in. The process should go something like this:

    % sudo aptitude install liborlite-perl liblwp-simple-perl libxml-feedpp-perl
    % sudo sh -c "curl -L cpanmin.us | perl - Mojolicious"
    % git clone https://hdonnay@github.com/hdonnay/kirby.git

Then,

    % morbo ./kirby/kirby.pl &
