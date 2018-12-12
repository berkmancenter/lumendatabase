# Release process

Maintenance windows are Wednesday and Saturday nights (after 5pm Eastern).

## Special instructions
If any deploys have special instructions, write them here, with a date and PR number. When that PR has been deployed, you can erase the special instructions.

PR #512 - add cron job for work redaction rake task, running every 2 hours with lockrun to avoid duplicating db queries.

## Hotfix
* Write code, code-review, and merge into `dev` via the normal process.
* Give Adam a heads-up: what you're doing, what it fixes, why it needs to be pushed out ASAP.
* Identify the commits needed for the hotfix.
* Rectify `master`:
  * Make a hotfix branch off of `master`
  * Cherry-pick the required commits into this hotfix branch
  * Run tests
  * Merge hotfix branch back into `master`, `dev`, `dev-legacy`, `master-legacy`
* Make a tagged release on the relevant commit
* Deploy `master-legacy` to the dev server (flutie) and api-beta server (percy)
  * If anything fails at this stage, fix it before moving on! And ensure that fixes end up in `dev`, `dev-legacy`, `master`, and `master-legacy`, with tests passing.
  * http://flutie.law.harvard.edu:8000/, ask Adam for credentials
* Deploy `master-legacy` to the prod server (enyos)
* Make sure you can load lumendatabase.org and skylight hasn't blown up

## Major
* Before a major release, contact Adam and make plans for any testing and stakeholder communication that need to happen. Follow those plans before following anything below.
* Rectify `dev-legacy`:
  * Merge `dev` into `dev-legacy`
  * Make sure the tests pass
* Rectify `master`:
  * Merge `dev` into `master`
  * Make sure the tests pass
* Rectify `master-legacy`:
  * Merge `master` into `master-legacy`
  * Make sure the tests pass
* Deploy `master-legacy` to the dev server (flutie)
  * If anything fails at this stage, fix it before moving on! And ensure that fixes end up in `dev`, `dev-legacy`, and `master-legacy`, with tests passing.
* Deploy `master-legacy` to the prod server (enyos)
* Make sure you can load lumendatabase.org and skylight hasn't blown up

## What "deploy" means
* Log in to the relevant server (`psh <servername>`)
* `sudo -su chill-prod` (enyos) or `sudo -su chill-dev` (flutie) or `sudo -su chill-api` (percy)
* cd into the directory where chill files live (look under `/web/<servername>`)
* `cp .env ../` (as a precaution)
* `git checkout db/schema.rb`
* `git checkout <branch>`
  * This will differ from the version-controlled one as running db:migrate will change its datestamp
  * You don't want merge conflicts
* `git pull`
* `bundle install`
  * This will throw an error if the user doesn't have write permissions on the home directory inferred by bundler (probably the one specified in /etc/passwd/), but it probably works anyway.
* `cp ../.env .`
* `rake db:migrate`
  - If this throws a `PG::ConnectionBad:` and asks something like "Is the server running locally and accepting connections on Unix domain socket "/var/run/postgresql/.s.PGSQL.5432"?", use `RAILS_ENV=production rake db:migrate`
* `rake assets:clobber`
* `rake assets:precompile`
* `touch tmp/restart.txt`
  * This tells Passenger to restart its listener
