# Release process

Maintenance windows are Wednesday and Saturday nights (after 5pm Eastern).

## Special instructions
If any deploys have special instructions, write them here, with a date and PR number. When that PR has been deployed, you can erase the special instructions.

* 16 August 2018/PR #470: requires cron job update (see https://github.com/berkmancenter/lumendatabase/pull/470)
* 29 August 2018/PR #482: crontabs on enyos, percy, and flutie will need to be edited so to run rake lumen:* tasks rather than rake chillingeffects:* tasks. https://github.com/berkmancenter/lumendatabase/pull/482

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
* Log in to the relevant server
* `sudo -su chill-prod` (enyos) or `sudo -su chill-dev` (flutie) or `sudo -su chill-api` (percy)
* cd into the directory where chill files live (look under `/web/<servername>`)
* `git pull origin <branch>`
  * Servers have correct default branches set so this is just `git pull` unless you need a different branch
* `bundle install`
* `source bin/init-env.sh`
* `rake db:migrate`
  - The order of source and db:migrate is important!
* `touch tmp/restart.txt`
  * This tells Passenger to restart its listener
