[![Build Status](https://circleci.com/gh/berkmancenter/lumendatabase.svg?style=shield)](https://circleci.com/gh/berkmancenter/lumendatabase)
[![Code Climate](https://codeclimate.com/github/codeclimate/codeclimate/badges/gpa.svg)](https://codeclimate.com/github/berkmancenter/lumendatabase)

# Lumen Database

The Lumen Database collects and analyzes legal complaints and requests for removal of online materials, helping Internet users to know their rights and understand the law. These data enable us to study the prevalence of legal threats and let Internet users see the source of content removals.

## Automated Submissions and Search Using the API

The main [Lumen Database instance](https://www.lumendatabase.org/) has an API that allows individuals and organizations that receive large numbers of notices to submit them without using the web interface. The API also provides an easy way for researchers to search the database. Members of the public can test the database, but will likely need to request an API key from the [Lumen team](mailto:team@lumendatabase.org) to receive a token that provides full access. To learn about the capabilities of the API, you can consult the [API documentation](https://github.com/berkmancenter/lumendatabase/wiki/Lumen-API-Documentation).

## Development

### Stack

* ruby 3.0.6
* PostgreSQL 13.6
* Elasticsearch 7.17.x
* Java Runtime Environment (OpenJDK works fine)
* Piwik Tracking (only used in prod)
* Mail server (SMTP, Sendmail)
* ChromeDriver (used only by test runner)

### Using Docker

The easiest way to start is to use `Docker`. Make sure you have the `Docker Engine` and `docker-compose` installed.

Clone the repository.

```
cp config/database.yml.docker config/database.yml
```

```
cp .env.docker .env
```

```
docker-compose up
```

```
docker-compose exec website bash
```

```
rake db:drop db:create db:migrate
```

```
rake comfy:cms_seeds:import[lumen_cms,lumen_cms]
```

```
rake db:seed
```

```
bundle exec sidekiq &
```

```
rails s -b 0.0.0.0
```

Lumen will be available at `http://localhost:8282`.

### Manual setup

By default, the app will try to connect to Elasticsearch on `http://localhost:9200`. If you want to use a different host set the `ELASTICSEARCH_URL` environment variable.

```
bundle install
```

```
cp config/database.yml.example config/database.yml
```

(edit database.yml as you wish)  
(ensure PostgreSQL and Elasticsearch are running)

```
rails db:setup
```

```
rails lumen:set_up_cms
```

### Running the app

```
rails s
```

### Viewing the app

```
$BROWSER 'http://localhost:3000'
```

You can customize behavior during seeding (db:setup) with a couple of environment variables:

* `NOTICE_COUNT=10` will generate 10 (or any number you pass it) notices
  instead of the default 500
* `SKIP_FAKE_DATA=1` will skip generating fake seed data entirely.

#### Sample user logins

The seed data creates logins of the following form:

    Username: {username}@lumendatabase.org
    Password: password

username is one of {user, submitter, redactor, publisher, admin, super_admin},
with corresponding privileges.

If you seeded your database with an older version of `seeds.rb`, your username
may use chillingeffects.org rather than lumendatabase.org.

### Running Tests

Many of the tests require all of the services that make up the Lumen stack to be running. For that reason, the easiest way to run tests is in a docker-compose environment:

    $ docker-compose -f docker-compose.test.yml --env-file .env.test up
    $ docker-compose exec -e RAILS_ENV=test website bash -c "bundle install && rake db:drop db:create db:migrate && rspec"

The integration tests are quite slow; for some development purposes you may find it more convenient to `...rspec spec/ --exclude-pattern="spec/integration/*"`.

### Parallelizing Tests
You can speed up tests by running them in parallel:
    $ rake parallel:spec

You will need to do some setup before the first time you run this:
- alter `config/database.yml` so that the test database is `yourproject_test<%= ENV['TEST_ENV_NUMBER'] %>`
- run `rake parallel:setup`

It will default to using the number of processors parallel_tests believes to be available, but you can change this by setting `ENV['PARALLEL_TEST_PROCESSORS']` to the desired number.

### Search Indexing

While the Elasticsearch integration with Rails makes indexing objects into the Elasticsearch index easy, it is untenably slow with millions of objects. We avoid this by bypassing Rails and indexing from the database straight into Elasticsearch using Logstash.

To run this indexing process, you'll need [Logstash](https://www.elastic.co/downloads/logstash), and the [PostgreSQL JDBC driver](https://jdbc.postgresql.org/download.html). You'll need to create a Logstash configuration that reads from Postgres and writes to Elasticsearch. There is an example setup in `script/search_indexing/` that includes two pipelines, one that indexes notices and one that indexes entities. Those examples are setup to run in Docker through `docker-compose`. 

Once setup, to run the indexing, simply run the logstash binary and point it to your configuration file, e.g. `bin/logstash -f logstash.conf`.

### Linting

Use rubocop and leave the code at least as clean as you found it. If you make linting-only changes, it's considerate to your code reviewer to keep them in their own commit.

###  Profiling

* [mini-profiler](https://github.com/MiniProfiler/rack-mini-profiler)
  * available in dev by default
  * in use on prod, visible only to super_admins
  * in-depth memory profiling, stacktracing, and SQL queries; good for granular analysis
* [oink](https://github.com/noahd1/oink)
  * memory usage, allocations
  * runs in dev by default; can run anywhere by setting `ENV[USE_OINK]` (ok to run in production)
  * logs to `log/oink.log`

### Environment variables

Here are all the environment variables which Lumen recognizes. Find them in the code for documentation.

Environment variables should be set in `.env` and are managed by the `dotenv` gem. `.env` is not version-controlled so you can safely write secrets to it (but will also need to set these on all servers).

Unless setting an environment variable on the command line in the context of a command-line process, environment variables should ONLY be set in `.env`.

Most of these are optional and have sensible defaults (which may vary by environment).

| Variable name | Description |
| --- | --- |
| `BATCH_SIZE` | Batch size of model items indexed during each run of Elasticsearch re-indexing |
| `BUNDLE_GEMFILE` | Custom Gemfile location |
| `BROWSER_VALIDATIONS` | Enable user HTML5 browser form validations |
| `DEFAULT_SENDER` | Default mailer sender |
| `ELASTICSEARCH_URL` | Elasticsearch host, e.g. https://127.0.0.1:9200 |
| `EMAIL_DOMAIN` | Default email domain in Action Mailer |
| `ES_INDEX_SUFFIX` | Can be used to specify a suffix for the name of Elasticsearch indexes |
| `FILE_NAME` | Name of CSV file to import as blog entries |
| `GOOGLE_CUSTOM_BLOG_SEARCH_ID` | Custom Google search ID used in the CMS |
| `LOG_ELASTICSEARCH` | Enabled logging of Elasticsearch calls, only used in tests |
| `LOG_TO_LOGSTASH_FORMAT` | Set to true if you want to log in the Logstash format |
| `USE_OINK` | Enable the `oink` gem in the production environment |
| `MAILER_DELIVERY_METHOD` | Sets the delivery method for emails sent by the application |
| `NOTICE_COUNT` | How many fake notices to create when seeding the db |
| `PROXY_CACHE_CLEAR_HEADER` | Name of a request header that is used clear cache on a proxy cache server like `Varnish` |
| `PROXY_CACHE_CLEAR_SITE_HOST` | Needed just in `development` to reach the application from a Docker container |
| `RACK_ENV` | Don't use this; it's overridden by `RAILS_ENV` |
| `RAILS_ENV` | Rails environment |
| `RAILS_LOG_LEVEL` | Log level for all the application loggers |
| `RAILS_SERVE_STATIC_FILES` | If present (with any value) will enable Rails to serve static files |
| `RECAPTCHA_SITE_KEY` | reCAPTCHA public key |
| `RECAPTCHA_SECRET_KEY` | reCAPTCHA private key |
| `RETURN_PATH` | Default mailer return path |
| `SEARCH_SLEEP` | Used in specs only, time out of Elasticsearch searches |
| `SECRET_KEY_BASE` | The Rails secret token; _required in prod_ |
| `SERVER_TIME_ZONE` | Name of the server's timezone, e.g. `Eastern Time (US & Canada)` |
| `SIDEKIQ_REDIS_URL` | `Redis` location used by `Sidekiq` |
| `SITE_HOST` | Site host, used in mailer templates |
| `SKIP_FAKE_DATA` | Don't generate fake data when seeding the database |
| `SMTP_ADDRESS` | SMTP server address |
| `SMTP_DOMAIN` | SMTP server domain |
| `SMTP_USERNAME` | SMTP server username |
| `SMTP_PASSWORD` | SMTP server password |
| `SMTP_PORT` | SMTP server port |
| `SMTP_VERIFY_MODE` | Value of the `openssl_verify_mode` option of the SMTP client |
| `USER_CRON_EMAIL` | For use in sending reports of court order files; can be a string or a list (in a JSON.parse-able format) |
| `USER_CRON_MAGIC_DIR` | Directory used in the court order reporter cron job |
| `WEB_CONCURRENCY` | Number of Unicorn workers |
| `WEB_TIMEOUT` | Unicorn timeout |

### Email setup

The application requires a mail server, in development it's best to use a local SMTP server that will catch all outgoing emails. [Mailcatcher](https://mailcatcher.me) is a good option.

## Blog custom search

The `/blog_entries` page can contain a google custom search engine that
searches the Lumen blog. To enable, create a custom search engine
[here](https://www.google.com/cse/create/new) restricted to the path the blog
lives at, for instance `https://www.lumendatabase.org/blog_entries/*`. Extract
the "cx" id from the javascript embed code and put it in the
`GOOGLE_CUSTOM_BLOG_SEARCH_ID` environment variable. The blog search will
appear after this variable has been configured.

## Lumen API

You can search the database and, if you have a contributor token, add to the database using our API.

The Lumen API is documented in our GitHub Wiki: https://github.com/berkmancenter/lumendatabase/wiki/Lumen-API-Documentation

## License

Lumen Database is licensed under GPLv2. See LICENSE.txt for more information.

## Copyright

Copyright (c) 2016 President and Fellows of Harvard College
