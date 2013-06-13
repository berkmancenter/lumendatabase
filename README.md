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

The order of these commands is important, as we need a running elasticsearch
before adding seed data. foreman starts up a web server on port 5000 by
default, available at http://localhost:5000/

    bundle install
    rake db:create
    # foreman will install elasticsearch under tmp/ the first time you start
    foreman start -f Procfile.dev
    # Run this next command after foreman has started elasticsearch
    rake db:migrate db:seed db:test:prepare

If you need to reset your database and seed data, then run:

    rake db:drop db:create

before proceeding with the rest of the commmands.

During seeding, you can customize behavior with a couple environment variables:

* `NOTICE_COUNT=10` will generate 10 (or any number you pass it) notices
  instead of the default 500
* `SKIP_FAKE_DATA=1` will skip generating fake seed data entirely.

License
=======

Chilling Effects is licensed under the MIT License, the same terms as Rails
itself. See LICENSE.txt for more information

Copyright
=========

Copyright (c) 2013 President and Fellows of Harvard College
