# Elasticsearch Indexing

## Incremental

Elasticsearch indexing happens out-of-process, meaning you must keep the index
up to date by periodically running `ReindexRun.index_changed_model_instances`.
This method looks for models (currently Entity and Notice (and its subclasses))
with an `updated_at` value greater than the last time we reindexed.  It will
then retrieve these model instances in batches (controlled by the value of
ENV['BATCH_SIZE'], with a default of 100) and send each of them to
elasticsearch.

The easiest way to reindex is to run the rails task
`lumen:index_changed_model_instances` via cron. Every five minutes
would probably be a good starting point.

Please see the ReindexRun part of the admin for information about indexing
activity. We count how many entities and notices we index each run, and keep
timing information that you can parse by comparing the `updated_at` and
`created_at` timestamps.

You should ensure that no more than one of the incremental indexers tasks is
running at once via a `lockrun`-like cron harness.

## Recreating the elasticsearch index

You can either remove all ReindexRun rows, or - preferably - use the
`lumen:recreate_elasticsearch_index` rails task after disabling the
cron job you set up to run the incremental indexing. This also uses
ENV['BATCH_SIZE'] to set how many items will be indexed per loop, ensuring we
don't use too much RAM at once.

It should only be necessary to recreate the elasticsearch index when:

* There's a problem with elasticsearch and you've got a corrupted index
* You change the index mapping
* You're setting things up for the first time

## Customizing the index names

`app/models/entity.rb` and `app/models/searchability.rb` define the index names for `Entity` and `Notice` respectively. You do not need to do anything about this.

However, if you would like to customize index names (e.g. to allow for multiple instances or zero-downtime upgrades), you can set the environment variable `ES_INDEX_SUFFIX`. Your specified string will be added to the end of the index name.
