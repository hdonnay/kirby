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
 * Interoperabliity with large nzb indexing sites.

Dependencies
------------

Kirby requires the following things to run, as best as I can remember:

 * [Mojolicious](http://mojolicio.us/)
 * [ORLite](http://search.cpan.org/perldoc?ORLite)
 * [XML::FeedPP](http://search.cpan.org/perldoc?XML::FeedPP)

And for development, these are probably also required:

 * Data::Dumper

Development is done on a Debian stable box, and all packages are from the repos, save Mojolicious, which was installed via one-liner.
This means any version you can get your hands on should be new enough.

Installation
------------

I assume you're installing this for development, because of the early stage this is in. The process should go something like this:

    % sudo aptitude install liborlite-perl libxml-feedpp-perl
    % sudo sh -c "curl -L cpanmin.us | perl - Mojolicious"
    % git clone https://github.com/hdonnay/kirby.git

Then,

    % cd kirby
    % morbo script/kirby

Copyright
---------

    Copyright (C) 2011 by Henry Donnay

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    All copies or substantial portions of the Software are used for
    non-commercial purposes.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
