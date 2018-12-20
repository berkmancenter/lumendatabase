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

By default the app will try to connect to Elasticsearch on `http://localhost:9200`. If you want to use a different host set the `ELASTICSEARCH_URL` environment variable.

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

    Username: admin@lumendatabase.org
    Password: password

If you seeded your database with an older version of `seeds.rb`, your username may be admin@chillingeffects.org.

Running Tests:

    $ bundle exec rspec spec/

The integration tests are quite slow; for some development purposes you may
find it more convenient to `bundle exec rspec spec/ --exclude-pattern="spec/integration/*"`.

If `elasticsearch` isn't on your $PATH, set `ENV['TEST_CLUSTER_COMMAND']=/path/to/elasticsearch`, and make sure permissions are set correctly for your test suite to run it.

Linting:

Use rubocop and leave the code at least as clean as you found it. If you make
linting-only changes, it's considerate to your code reviewer to keep them in
their own commit.

Profiling:
* [Skylight](https://www.skylight.io/app/applications/utm46ElcSDtw/recent/5m/endpoints)
  * track page rendering time, count allocations, find possibly dodgy SQL
  * analytics to help you find the problem areas
  * login required
  * runs in prod
* [bullet](https://github.com/flyerhzm/bullet)
  * find N+1 queries and unused eager loading
  * runs in dev
  * logs to `log/bullet.log`
* [oink](https://github.com/noahd1/oink)
  * memory usage, allocations
  * more specific than Skylight as to which objects are being created where
  * runs in dev by default; can run anywhere by setting `ENV[LUMEN_USE_OINK]` (ok to run in production)
  * logs to `log/oink.log`

## Environment variables

- `RAILS_LOG_LEVEL` - logging level
- `WEB_CONCURRENCY` - number of Unicorn workers
- `WEB_TIMEOUT` - Unicorn timeout
- `MAILER_DELIVERY_METHOD` - mailer delivery method
- `DEFAULT_SENDER` - default mailer sender
- `RETURN_PATH` - default mailer return path
- `SITE_HOST` - site host, used in mailer templates
- `SMTP_ADDRESS` - SMTP server address
- `SMTP_DOMAIN` - SMTP server domain
- `SMTP_USERNAME` - SMTP server username
- `SMTP_PASSWORD` - SMTP server password
- `SMTP_PORT` - SMTP server port
- `TWITTER_CONSUMER_KEY`  - Twitter integration public key
- `TWITTER_CONSUMER_SECRET`  - Twitter integration private key
- `TWITTER_OAUTH_TOKEN` - Twitter integration OAuth token
- `TWITTER_OAUTH_TOKEN_SECRET` - Twitter integration OAuth token secret key
- `RECAPTCHA_SITE_KEY` - reCAPTCHA public key
- `RECAPTCHA_SECRET_KEY` - reCAPTCHA private key
- `BROWSER_VALIDATIONS` - enable user browser form validations
- `BATCH_SIZE` - batch size of model items indexed during each run of Elasticsearch re-indexing
- `SEARCH_SLEEP` - used in specs only, time out of Elasticsearch searches
- `RACK_ENV` - Rack environment

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

[View performance data on Skylight](https://oss.skylight.io/app/applications/utm46ElcSDtw/recent/6h/endpoints)
