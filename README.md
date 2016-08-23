Lumen Database
================

The Lumen Database collects and analyzes legal complaints and requests for removal of online materials, helping Internet users to know their rights and understand the law. These data enable us to study the prevalence of legal threats and let Internet users see the source of content removals.

Development
===========

Requirements:

* ruby 2.1.9
* modern postgres
* A jre (openjdk works fine)

Setup:

    ./bin/setup

Running the app:

    foreman start -f Procfile.dev

Viewing the app:

    $BROWSER 'http://localhost:5000'

Resetting the database:

    DB_RESET=1 ./bin/setup

*Note*: foreman cannot be running during a db-reset.

During seeding, you can customize behavior with a couple environment variables:

* `NOTICE_COUNT=10` will generate 10 (or any number you pass it) notices
  instead of the default 500
* `SKIP_FAKE_DATA=1` will skip generating fake seed data entirely.

Admin login:

    Username: admin@chillingeffects.org
    Password: password

Running Tests:

    A headless webkit is used but it requires X11 to function.
    If you are connecting remotely (i.e. SSH), ensure that you have X11 Forwarding enabled.

Ephemera
========

The `/blog_entries` page contains a google custom search engine that's supposed
to search the Lumen blog. To enable, create a custom search engine
[here](https://www.google.com/cse/create/new) restricted to the path the blog
lives at, for instance `http://www.lumendatabase.org/blog_entries/*`. Extract
the "cx" id from the javascript embed code and put it in the
`GOOGLE_CUSTOM_BLOG_SEARCH_ID` environment variable. The blog search will
appear after this variable has been configured.

License
=======

Lumen Database is licensed under GPLv2. See LICENSE.txt for more information.

Copyright
=========

Copyright (c) 2016 President and Fellows of Harvard College
