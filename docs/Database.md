Kirby::Database
===============

The Database module is a plugin that handles interactions with the
SQLite database behind Kirby.

This package provides the follwing helpers:

fetchBook
---------

    <%== fetchBook $id %>

The fetchBook helper takes in a row id and returns a block of html
populated with information from the database.

Thsi package provides the following methods:

search
------

    my @results = search( q => "query" );

The search method queries the database for a string and returns a list
of row ids. It currently only searches the 'series' column.

It returns a list of ids instead of a list of row hashes to reduce the
amount of data stashed.

fetch
-----

    my %book = fetch( id => $id );

The fetch method returns a hash populated with the following keys:

 * pic
  * A local URL to where the cover should be stored.
 * series
  * Series name.
 * issue
  * Issue number.
 * title
  * Title of the Issue
 * description
  * Description of the Issue

