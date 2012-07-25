Kirby::SABnzbd
==============

TODO
----
 * Make this module stand-alone. I can't find any other perl sabnzbd
   modules.

USAGE
-----

Make a SABnzbd object by using `new()`, send a url to be grabbed with
`send()`.

###sub `new`
####Needed Arguments:
 * `baseUrl`
   * usually "$host:$port", perhaps "$host/sabnzbd"
 * `api`
   * API key for SABnzbd. (Needed since API version 0.4.9)
####Optional Arguments:
 * `auth`
   * expected in the form "$user:$pass", as in basic HTTP Auth
####Example
    my $sab = Kirby::SABnzbd->new(
        baseUrl => "http://localhost:8080",
        api => "thisisanmd5hash",
        auth => "me:mypassword"
    );

###sub `send`
####Needed Arguments:
 * `nzb`
   * Url to an nzb
####Optional Arguments:
 * None
####Example
    $sab->send('http://localhost/file.nzb');
