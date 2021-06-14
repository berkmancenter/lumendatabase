# cron jobs

Lumen relies on several cron jobs in production. As of October 2020, cron runs:
* `rails lumen:index_changed_model_instances`
  - We use this instead of Elasticsearch callbacks so that (re)indexing happens out-of-band.
* `rails lumen:safer_cache_clear`
  - The FileStore cache must be cleared periodically or it will exhaust system resources.
  - The default cache clearing mechanism is rm -rf, which leads to large spikes in resource usage once per cron interval as the system rebuilds its cache. safer_cache_clear checks for file `atime` before deleting.
  - This runs every 20 minutes, which was empirically determined to be a good balance between cache hit ratios and disk resources. The ideal interval may change as user behavior and available hardware change.
* `rails lumen:publish_embargoed`
* `rails lumen:generate_court_order_report`
  - There's also a cron job which rotates the generated reports.

## Troubleshooting

* something works on staging and not on prod? Check to see that staging and production cron have not drifted out of sync.
* cron job not running successfully? Make sure cron is invoking rails tasks with bash and bundle exec, so that dotenv loads environment variables from `.env`. Writing environment variables directly into the crontab means that eventually they will be out of sync with the app and something will fail.
