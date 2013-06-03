Chilling Effects
================

Description here.

Development
===========

Requirements:

* ruby 2.0, a modern postgres

Setup:

    bundle install
    rake db:create db:migrate db:seed db:test:prepare

If you need to reset your database and seed data, then add "db:drop" to the
front of the command above, thusly:

    rake db:drop db:create db:migrate db:seed db:test:prepare

License
=======

Chilling Effects is licensed under the MIT License, the same terms as Rails
itself. See LICENSE.txt for more information

Copyright
=========

Copyright (c) 2013 President and Fellows of Harvard College
