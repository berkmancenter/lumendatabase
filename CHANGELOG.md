The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/). It uses [CalVer](https://calver.org/) as of May 2019.

## [21.05b](https://github.com/berkmancenter/lumendatabase/releases/tag/2021.05b) - 2021-05-18
### Changed
* Bumped Rails to `5.2.6`.

### Fixed
* Fixed the advanced search toggler.

## [21.05a](https://github.com/berkmancenter/lumendatabase/releases/tag/2021.05a) - 2021-05-17
### Fixed
* Updated the token url confirmation email body.

## [21.05](https://github.com/berkmancenter/lumendatabase/releases/tag/2021.05) - 2021-05-17
### Changed
* Allowed to set a custom token urls interval value and archive old token urls.
* Cleaned up the admin interface.

## [21.04c](https://github.com/berkmancenter/lumendatabase/releases/tag/2021.04b) - 2021-04-28
### Changed
* Allowed to set selected users to create permanent token urls for sensitive notices.

## [21.04b](https://github.com/berkmancenter/lumendatabase/releases/tag/2021.04b) - 2021-04-21
### Changed
* Allowed any role with the `can_generate_permanent_notice_token_urls` setting be able to generate permanent token urls.

## [21.04a](https://github.com/berkmancenter/lumendatabase/releases/tag/2021.04a) - 2021-04-19
### Added
* Added basic notice viewing stats.

## [21.04](https://github.com/berkmancenter/lumendatabase/releases/tag/2021.04) - 2021-04-14
### Fixed
* Made the notice view show all available notice entity roles.

## [21.02](https://github.com/berkmancenter/lumendatabase/releases/tag/2021.02) - 2021-02-27
### Added
* Add a new functionality that allows to show sensitive notice URLs only to researchers.

## [20.11b](https://github.com/berkmancenter/lumendatabase/releases/tag/2020.11b) - 2020-11-24
### Changed
* Fix the test suite.

## [20.11a](https://github.com/berkmancenter/lumendatabase/releases/tag/2020.11a) - 2020-11-21
### Changed
* Clean up the production log.

## [20.11](https://github.com/berkmancenter/lumendatabase/releases/tag/2020.11) - 2020-11-11
### Changed
* Allow to customize the search index name during the `run_catchup_es_indexing` task.

## [20.10a](https://github.com/berkmancenter/lumendatabase/releases/tag/2020.10a) - 2020-10-20
* [#628](https://github.com/berkmancenter/lumendatabase/pull/628) Tweaks Elasticsearch options so that high-volume searches resolve before timeout.

## [20.10](https://github.com/berkmancenter/lumendatabase/releases/tag/2020.10) - 2020-10-05
### Changed
* [#612](https://github.com/berkmancenter/lumendatabase/pull/612) Elasticsearch updated from 5.x to 7.x.
  * This includes a major refactor of the Elasticsearch-handling components to promote maintainability.
* [#624](https://github.com/berkmancenter/lumendatabase/pull/624) Migrate phantomjs (no longer maintained) to selenium.
* [#623](https://github.com/berkmancenter/lumendatabase/pull/623) Migrate from Travis (stopped working) to CircleCI.

### Added
* [#626](https://github.com/berkmancenter/lumendatabase/pull/626) Documentation of elasticsearch upgrade process.

### Security
* [#625](https://github.com/berkmancenter/lumendatabase/pull/625) Patch update to rails version.

## [20.09](https://github.com/berkmancenter/lumendatabase/releases/tag/2020.09) - 2020-09-02
### Fixed
* [#621](https://github.com/berkmancenter/lumendatabase/pull/621) Don't offer a 'click here to request access' option when there is nothing further to be requested
* [#622](https://github.com/berkmancenter/lumendatabase/pull/622) Display date_sent even when sender name is hidden
* [#622](https://github.com/berkmancenter/lumendatabase/pull/622) Don't display ",,," when sender/recipient address is empty

## [20.08a](https://github.com/berkmancenter/lumendatabase/releases/tag/2020.08a) - 2020-08-25
### Removed
* [#620](https://github.com/berkmancenter/lumendatabase/pull/620) Stop sending `url_original` with serialized URL objects

### Added
* [#619](https://github.com/berkmancenter/lumendatabase/pull/619) Prefill submitter and recipient information on notice creation web form when the submitting user has a linked entity

### Fixed
* [#618](https://github.com/berkmancenter/lumendatabase/pull/618) Improve communication around deep pagination

## [20.08](https://github.com/berkmancenter/lumendatabase/releases/tag/2020.08) - 2020-08-03
### Added
* [#617](https://github.com/berkmancenter/lumendatabase/pull/617) Placeholder notice type

### Fixed
* [#615](https://github.com/berkmancenter/lumendatabase/pull/615) Fix ReindexRun metadata creation.
* [#616](https://github.com/berkmancenter/lumendatabase/pull/616) Fixes bug in redirect behavior after notice submission through web form.

## [20.07a](https://github.com/berkmancenter/lumendatabase/releases/tag/2020.07a) - 2020-07-30
### Added
* [#614](https://github.com/berkmancenter/lumendatabase/pull/614) Counternotice is now in the list of creatable notice types at `/notices/new/`.

## [20.07](https://github.com/berkmancenter/lumendatabase/releases/tag/2020.07) - 2020-07-17
### Fixed
* [#611](https://github.com/berkmancenter/lumendatabase/pull/611) Fix bug whereby people with access tokens could not download attached documents
* [#610](https://github.com/berkmancenter/lumendatabase/pull/610) Improve docs for new devs (thanks, @siaw23 !)
* [#609](https://github.com/berkmancenter/lumendatabase/pull/609) Bug in URL deconcatenation logic, which erroneously rejected URLs that contained "http" as a substring outside of the protocol indicator.

### Security
* Updated rack version.

## [20.05b](https://github.com/berkmancenter/lumendatabase/releases/tag/2020.05a) - 2020-05-29
### Added
* Counterfeit notice type [#604](https://github.com/berkmancenter/lumendatabase/pull/604)

### Changed
* Update version of acts-as-taggable-on to improve performance
* Override acts-as-taggable-on parser to hardcode some high-allocation calls
* Update rails (patch version) to address vulns

## [20.05a](https://github.com/berkmancenter/lumendatabase/releases/tag/2020.05a) - 2020-05-04
### Fixed
* [#600](https://github.com/berkmancenter/lumendatabase/pull/600) Bug in search result dropdown display introduced in [20.04b](https://github.com/berkmancenter/lumendatabase/releases/tag/2020.04b).

## [20.05](https://github.com/berkmancenter/lumendatabase/releases/tag/2020.05) - 2020-05-01
### Changed
* [Dependency version upgrades](https://github.com/berkmancenter/lumendatabase/commit/ffd65d5f749014db61a675389c76942c1c2955bb).

## [20.04c](https://github.com/berkmancenter/lumendatabase/releases/tag/2020.04b) - 2020-04-30
### Fixed
* [#598](https://github.com/berkmancenter/lumendatabase/pull/598) Fixes a bug introduced in .04a whereby submitting multipart form data through the API failed due to known inconsistencies between form data and JSON data representations, and unknown differences between production and test environments.

## [20.04b](https://github.com/berkmancenter/lumendatabase/releases/tag/2020.04b) - 2020-04-17
### Added
* [#596](https://github.com/berkmancenter/lumendatabase/pull/596) CMS administrators can now manage header/footer links to CMS content through the CMS.

## [20.04a](https://github.com/berkmancenter/lumendatabase/releases/tag/2020.04a) - 2020-04-07
### Changed
* [#595](https://github.com/berkmancenter/lumendatabase/pull/595) Validate bytelength of submitted URLs more aggressively
* Also in #595, remove NoticeSubmissionInitializer and NoticeSubmissionFinalizer in favor of a more rails-y way of handling notice creation and validation, while still preserving the option of backgrounding the slow parts later

### Added
* More Skylight instrumentation to get a more granular view into notice creation slowness

## [20.04](https://github.com/berkmancenter/lumendatabase/releases/tag/2020.04) - 2020-04-01
### Changed
* [#593](https://github.com/berkmancenter/lumendatabase/pull/593) Speed up test suite (~25%)
* [#586](https://github.com/berkmancenter/lumendatabase/pull/586) Upgrade simple_form (4.1 -> 5; thanks dependabot)
* [#594](https://github.com/berkmancenter/lumendatabase/pull/594) Upgrade nokogiri, actionview
* [#594](https://github.com/berkmancenter/lumendatabase/pull/594) Split apart concatenated URLs in notice creation to make separate CopyrightedUrl/InfringingUrl objects

## [20.01b](https://github.com/berkmancenter/lumendatabase/releases/tag/2020.01b) - 2020-01-31
### Changed
* CMS URL promoted to the top level, so that the CMS is now serving blog and static page content
* Maintenance page is now served from a different directory
* Tests of blog and pages functionality updated to ensure same behavior in the CMS
* `high_voltage-pages` CSS class renamed to `static-pages` so as not to baffle future developers

### Removed
* `BlogEntry` and `BlogEntryTopicAssignment` models and associated code
* `OriginalNewsId` controller
  * The content was migrated into the CMS in an intermediate commit, not tagged as a release.
* Rake tasks from 20.01a (no longer usable as `BlogEntry` no longer exists)
* `high_voltage` gem and existing static pages (`app/views/pages` directory)

### Added
* `web-console` gem, for debugging in development
* Testing of RSS feed

## [20.01a](https://github.com/berkmancenter/lumendatabase/releases/tag/2020.01a) - 2020-01-21
### Added
* We have a CMS! (Comfortable-Mexican-Sofa)
* Rake tasks to stand up the CMS and migrate blog content

## [20.01](https://github.com/berkmancenter/lumendatabase/releases/tag/2020.01) - 2020-01-08
### Changed
* Upgrade rails_admin from 1.4 to 2.0
  * This had been blocked by the Rails upgrade
  * Should result in a noticeable speedup.

## [19.11a2](https://github.com/berkmancenter/lumendatabase/releases/tag/2019.11a) - 2019-11-18
### Fixed
* Fixes bug which prevented files from being downloaded
* Updates test suite with regresssion test for this bug

## [19.11a](https://github.com/berkmancenter/lumendatabase/releases/tag/2019.11a) - 2019-11-15
### Changed
* Upgrade to Rails 5.2 (from 4.2) (!!)

## [19.11](https://github.com/berkmancenter/lumendatabase/releases/tag/2019.11) - 2019-11-06
### Changed
* Upgrade to ruby 2.5.5 (from 2.3.3).
* Edits text of static pages.

## [19.10a](https://github.com/berkmancenter/lumendatabase/releases/tag/2019.10a) - 2019-10-10
### Fixed
* Bug in lib/rack-attack/request.rb#token which was preventing data submission.

## [19.10](https://github.com/berkmancenter/lumendatabase/releases/tag/2019.10) - 2019-10-04
### Changed
* Enforced previously soft limits on API token use.

### Yanked
* 19.09 -- something in that was breaking notice submission

## [19.09](https://github.com/berkmancenter/lumendatabase/releases/tag/2019.09) - 2019-09-06
### Added
* Back-end work to support a future statistics dashboard.

## [19.07.a](https://github.com/berkmancenter/lumendatabase/releases/tag/2019.07.a) - 2019-09-04
### Fixed
* Allowed for a configurable list of notices which suppresss "click here to see full URLs" feature (as some placeholder notices have no URLs, so the offer is misleading)
* Updated nokogiri (critical security fix)

## [19.07](https://github.com/berkmancenter/lumendatabase/releases/tag/2019.07) - 2019-07-01
### Added
* Compresses http responses
* `get_approximate_count` method on `Notice` and `InfringingUrl` (uses postgres reltuples)
* Safelists logged-in users using the web interface (if they would not be throttled using the API)

### Changed
* Updates numerous dependencies
* Refactors court order reporting cron job
* Only includes notices of type supporting in this cron job

### Fixed
* Bug with captcha validation in notice requests (pushed out before this release as a hotfix)
* Broken link in admin site
* Strips special characters from cron job filenames to suppress annoying warning emails to admins

## [19.05](https://github.com/berkmancenter/lumendatabase/releases/tag/2019.05) - 2019-05-20

### Added
* Return link to documentation when API users are missing auth token (first PR by our 2019 Google Summer of Code student [shubhscoder](https://github.com/shubhscoder) -- thanks!)

### Changed
* Cache entire topic menu as a single unit rather than individually caching subunits
* Freeze more string literals
* Specify that Elasticsearch should return only the data we actually use, not the whole record (this dramatically cuts the response time of the search action)
* Switched to CalVer, which better fits our actual release pattern.

### Fixed
* Made separate cache keys for truncated and un-truncated versions of notice pages to ensure users see the correct data
* Fix bug whereby so that full notice view requests were validating twice, hence appearing invalid to users
* Handle special characters in filenames, which were preventing file copy during report generation

## [2.2.0](https://github.com/berkmancenter/lumendatabase/releases/tag/2.2.0) - 2019-05-09

### Added
* Truncate URLs:
  * show only domains plus counts to anonymous users
  * show full data to logged-in users
* allow anonymous users to request full access for limited personal use
* Memory profiling (superadmins only)
* Database indexes to speed up some slow queries
* Allow for elasticsearch index names to be customized via ENV
* Show 'submitted to Lumen' date in search results
* Make risk triggers work
* Add turnout back
* Some dependency updates

### Changed
* Asset-pipeline-related gems no longer loaded in prod to save on memory
* Prevent deep pagination on search results, since Elasticsearch doesn't support it
* Much lower throttling limits in rack-attack, coupled with mechanism for safelisting IPs
* Increased cache time-to-live

## [2.1.6.2](https://github.com/berkmancenter/lumendatabase/releases/tag/2.1.6.2) - 2019-02-04

### Fixed
* Fixed bug whereby overly aggressive caching in the notice advanced search functions was causing garbage data to show up.

## [2.1.6.1](https://github.com/berkmancenter/lumendatabase/releases/tag/2.1.6.1) - 2018-12-21

### Fixed
* `apply_metadata` needs to be public, per errors in logs.

## [2.1.6](https://github.com/berkmancenter/lumendatabase/releases/tag/2.1.6) - 2018-12-20

### Added
* "Submitter" field on notice submissions
* VCR dependency for ElasticsearchQuery spec
* Placeholder notice for use in Google Canadian law notice responses
* Auto-redaction of work descriptions for newly added works
* Rake task for redaction of descriptions of existing works (this will be applied slowly over time to redact our existing 203M works)
* Custom message for hidden notices

### Changed/Fixed
* Bug preventing notices submitted via OldChill from being imported into Lumen
* Excessive instantiations on `ElasticsearchQuery#search` leading to slow notice searches and topic/notice display pages; the API for `#search` has been changed to allow its consumers to reduce their data demands
* Excessive db queries on `NoticesController#create`
* Excessive db queries on`RailsAdmin#MainController#edit` (resulting in minor changes to admin interface)
* More extensive caching of expensive fragments
* Improved code style
* Dependencies with security vulnerabilities have been upgraded
* Elasticsearch configuration has been streamlined
* Most intermittent test failures have been eliminated
* Bug whereby supporting documents submitted via the notice submission webform were miscategorized as original
* Bug whereby entity types were not being set properly via the notice submission webform
* Bug whereby admins could not delete notices

### Removed
* Links to related FAQs and blog entries on notice pages
* DMCA counternotice creator

A 2.1.6 prerelease also included a feature to truncate URLs for unauthorized users, but it was [YANKED] pending further testing.

## [2.1.5.2](https://github.com/berkmancenter/lumendatabase/releases/tag/2.1.5.2) - 2018-09-28

### Changed
* Direct remaining stderr to log file in hopes that cron will stop emailing admins

## [2.1.5.1](https://github.com/berkmancenter/lumendatabase/releases/tag/2.1.5.1) - 2018-09-12

### Added
* Submitter fields on government request notice creation web form

### Changed/Fixed
* Cache clearing cron job (no longer tries to delete nonempty directories)

## [2.1.5](https://github.com/berkmancenter/lumendatabase/releases/tag/2.1.5) - 2018-09-05

### Added
* Rake task for indexing added/changed notices after a given date
* Redirect for the frequently accessed `/dmca/counter512.pdf` to a URL which actually exists
* Rubocop and coverage checking in build process
* PR and issue templates

### Changed/Fixed
* Log formats (logs now include timestamps; API keys are logged)
* Opted in to `config.active_record.raise_in_transactional_callbacks` warnings (the prior behavior of setting these to false was deprecated)
* Updated caching strategy to avoid occasional race condition wherein cache keys existed at time of check but cache contents had been deleted by time of use
* Updated http to https links where possible
* Improved handling of forged POSTs to notices (thereby removing an API call error message)
* Fixed error from trying to iterate over empty tweets
* Handled Sass deprecation warnings that had been clogging the logs
* Fixed bug whereby users with a connected entity could not submit web forms despite auth token
* Minor wording updates
* Added timeout to Elasticsearch client
* Removed excess whitespace from notice URL list (which added up to surprisingly much content for notices with many URLs)
* Updated proxy caching strategy
* Updated references to "chillingeffects" to "lumen" where possible
* Switched to postgres UPSERT for infringing URLs in order to speed up notice creation when there are very large numbers of associated URLs
* Switched to `.env` rather than `bin/init-env.sh` for environment variable handling
* Documented the release process
* Improved test isolation, so that the test suite is dramatically more likely to pass
* Linted for consistency with current ruby style guidelines
* Suppressed spurious `to_ary` warning

### Removed
* No longer displaying received date on notices when it is the same as the sent date
* Removed public access to the notice submission form

## [2.1.4.1](https://github.com/berkmancenter/lumendatabase/releases/tag/2.1.4.1) - 2018-08-16

### Changed
Hotfixes the 2.1.4 release by adding an index to `Notice.created_at`. This should help with extremely low load times for the home page (Skylight asserts that the vast majority of the time is spent on an SQL query that sorts  on this unindexed column).
