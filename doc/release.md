# Release process

Maintenance windows are Wednesday and Saturday nights (after 5pm Eastern).

## Special instructions
If any deploys have special instructions, write them here, with a date and PR number. When that PR has been deployed, you can erase the special instructions.

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
  * Bundle install
  * rails db:migrate
  * Make sure the tests pass
* Rectify `master`:
  * Merge `dev` into `master`
  * Bundle install
  * rails db:migrate
  * Make sure the tests pass
* Rectify `master-legacy`:
  * Merge `master` into `master-legacy`
  * Bundle install
  * rails db:migrate
  * Make sure the tests pass
* Push `dev-legacy`, `master`, and `master-legacy` to github
* Deploy `master-legacy` to the dev server (flutie)
  * If anything fails at this stage, fix it before moving on! And ensure that fixes end up in `dev`, `dev-legacy`, and `master-legacy`, with tests passing.
* Deploy `master-legacy` to the prod server (enyos)
* Make sure you can load lumendatabase.org and skylight hasn't blown up

## What "deploy" means
* Log in to the relevant server (`psh <servername>`)
* `sudo -su chill-prod` (enyos) or `sudo -su chill-dev` (flutie) or `sudo -su chill-api` (percy)
* cd into the directory where chill files live (look under `/web/<servername>`)
* `rails lumen:maintenance_start`
* `cp .env ../` (as a precaution)
* `git checkout db/schema.rb`
* `git checkout <branch>`
  * This will differ from the version-controlled one as running db:migrate will change its datestamp
  * You don't want merge conflicts
* `git pull`
* `bundle install`
  * This will throw an error if the user doesn't have write permissions on the home directory inferred by bundler (probably the one specified in /etc/passwd/), but it probably works anyway.
* `cp ../.env .`
* `rails db:migrate`
  - If this throws a `PG::ConnectionBad:` and asks something like "Is the server running locally and accepting connections on Unix domain socket "/var/run/postgresql/.s.PGSQL.5432"?", use `RAILS_ENV=production rails db:migrate`
* `rails assets:clobber`
* `RAILS_ENV=development rails assets:precompile`
  * This MUST specify the development environment, because bourbon is not loaded in production to save on memory.
  * Prod will still be able to find the precompiled assets.
* `rails lumen:maintenance_end`
  * This includes the `touch tmp/restart.txt` command, which tells Passenger to restart its listener.
* Update `CHANGELOG.md` per [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## Rollback
Any rollback should be approached with caution. Write out a specific plan which starts from the below steps but consider whether there are instructions specific to the code being rolled back which need to be added.

This plan assumes you are on production. Other environments require slight modifications.

* Think through whether you need to do database rollbacks
  - Does anything need to be rolled back to revert the code?
  - Does anything need to be rolled forward afterward?
  - Make a database backup if you will be doing a rollback, or verify that a very recent one exists
  - Modify the below plan as needed to ensure your database ends up in a correct state
  - Measure twice, cut once
  - Make sure you have sysadmin support available during the deploy in case your database ends up in a weird state
* On localhost: revert the offending code
* Apply the reversion to `dev`, `master`, and `master-legacy`
* Run tests against the rolled-back branches
* When those tests pass, push up the code
* Follow this modified version of the deploy process for master-legacy:
  - `sudo -su chill-prod`
  - `rake lumen:maintenance_start`
  - `cp .env ../`
  - `rake db:rollback STEP=n`
    - If needed, roll back the db to the point where it will be when you re-pull `master-legacy`
    - Do explicitly specify how many steps you will be rolling back; a bare `rake db:rollback` does not always roll only 1 step
    - DO THIS WITH CAUTION AS IT IS A DESTRUCTIVE OPERATION
    - IF IT DELETES DATA YOU CARE ABOUT, HAVE A PLAN FOR THAT, OR MAKE A DIFFERENT PLAN WHICH DOES NOT DELETE THE DATA
  - `git checkout db/schema.rb`
  - `git pull`
  - `bundle install`
  - `rake db:migrate`
    - should not be necessary given the rollback, and given that you are performing a fast-forward of the branch
    - but think it through
  - `rake assets:clobber`
  - `RAILS_ENV=development rake assets:precompile`
  - `rake lumen:maintenance_end`
