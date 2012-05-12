Bootstrap
=========

Bootstrap from twitter is used for most of the HTML/CSS/JS.

The Navbar and Tabs have been modularized can can easily be changed in
the action function. An example from `Kirby::Static`:


    sub index {
        my $self = shift;

        # The tabs stash varible is an array that contains arrays to build tabs
        #   out of. The zeroth element is the text to display, the next is the
        #   link to use, and then there is an optional element that is a class
        #   to apply to the 'a' tag.
        $self->stash(tabs => [
                ["Welcome", "#1"],
                ["New Scene Releases", "#usenet", "scene"],
                ["New Comics", "#rss", "rss"],
            ]);

        $self->render('index');
    }

    sub about {
        my $self = shift;

        # The Navbar is controlled through these two stash variables.
        # navbarName is exactly what it sounds like.
        $self->stash(navbarName => "This project uses:");
        # The 'navbar' stash variable is an array of arrays, each containing an
        #   array that contains the text to use and a link.
        $self->stash(navbar => [
                ["Bootstrap", "http://twitter.github.com/bootstrap"],
                ["Comicvine", "http://api.comicvine.com/"],
                ["Mojolicious", "http://mojolicio.us"],
                ["Perl", "http://www.perl.org"],
            ]);

        $self->render('about');
    }
