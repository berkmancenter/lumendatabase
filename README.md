Chilling Effects
================

Description here.

Development
===========

Requirements:

* ruby 2.0
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

License
=======

Chilling Effects is licensed under GPLv2. See LICENSE.txt for more information.

Copyright
=========

Copyright (c) 2013 President and Fellows of Harvard College
