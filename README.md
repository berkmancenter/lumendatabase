[![Build Status](https://travis-ci.org/berkmancenter/lumendatabase.svg?branch=master)](https://travis-ci.org/berkmancenter/lumendatabase)
[![Coverage Status](https://coveralls.io/repos/github/berkmancenter/lumendatabase/badge.svg?branch=master)](https://coveralls.io/github/berkmancenter/lumendatabase?branch=master)
[![Code Climate](https://codeclimate.com/github/codeclimate/codeclimate/badges/gpa.svg)](https://codeclimate.com/github/berkmancenter/lumendatabase)

Lumen Database
================

The Lumen Database collects and analyzes legal complaints and requests for removal of online materials, helping Internet users to know their rights and understand the law. These data enable us to study the prevalence of legal threats and let Internet users see the source of content removals.

Automated Submissions and Search Using the API
===========
The main [Lumen Database instance](https://www.lumendatabase.org/) has an API that allows individuals and organizations that receive large numbers of notices to submit them without using the web interface. The API also provides an easy way for researchers to search the database. Members of the public can test the database, but will likely need to request an API key from the [Lumen team](mailto:team@lumendatabase.org) in order to receive a token that provides full acess. To learn about the capabilities of the API you can consult the [API documentation](https://github.com/berkmancenter/lumendatabase/wiki/Lumen-API-Documentation).

Development
===========

Requirements:

* ruby 2.3.3
* PostgreSQL 9.6
* Elasticsearch 5.6.x
* Java Runtime Environment (OpenJDK works fine)
* Piwik Tracking
* phantomjs (used only by test runner)

Setup:

    $ bundle install
    $ cp config/database.yml.example config/database.yml
      (edit database.yml as you wish)
      (ensure PostgreSQL and Elasticsearch are running)
    $ rake db:setup

Running the app:

    $ rails s

Viewing the app:

    $BROWSER 'http://localhost:3000'

You can customize behavior during seeding (db:setup) with a couple environment variables:

* `NOTICE_COUNT=10` will generate 10 (or any number you pass it) notices
  instead of the default 500
* `SKIP_FAKE_DATA=1` will skip generating fake seed data entirely.

Admin login:

    Username: admin@chillingeffects.org
    Password: password

Running Tests:

    $ bundle exec rspec spec/

The integration tests are quite slow; for some development purposes you may
find it more convenient to `bundle exec rspec spec/ --exclude-pattern="spec/integration/*"`.

If `elasticsearch` isn't on your $PATH, set `ENV['TEST_CLUSTER_COMMAND']=/path/to/elasticsearch`, and make sure permissions are set correctly for your test suite to run it.

Linting:

Use rubocop and leave the code at least as clean as you found it. If you make
linting-only changes, it's considerate to your code reviewer to keep them in
their own commit.

Ephemera
========

The `/blog_entries` page contains a google custom search engine that's supposed
to search the Lumen blog. To enable, create a custom search engine
[here](https://www.google.com/cse/create/new) restricted to the path the blog
lives at, for instance `https://www.lumendatabase.org/blog_entries/*`. Extract
the "cx" id from the javascript embed code and put it in the
`GOOGLE_CUSTOM_BLOG_SEARCH_ID` environment variable. The blog search will
appear after this variable has been configured.

Lumen API
=========
You can search the database and, if you have a contributer token, add to the database using our API.

The Lumen API is documented in our GitHub Wiki: https://github.com/berkmancenter/lumendatabase/wiki/Lumen-API-Documentation

License
=======

Lumen Database is licensed under GPLv2. See LICENSE.txt for more information.

Copyright
=========

Copyright (c) 2016 President and Fellows of Harvard College


Performance Monitoring
======================

[![View performance data on Skylight](https://badges.skylight.io/status/utm46ElcSDtw.svg?token=PR5TfNu3JYQ6v9QPg-HUzY-a8E2F9wNnd1ukGU70T7M)](https://www.skylight.io/app/applications/utm46ElcSDtw)
