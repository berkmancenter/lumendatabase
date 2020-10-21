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

However, if you would like to customize index names (e.g. to allow for multiple instances or zero-downtime upgrades, via reindexing in the background and then repointing an alias), you can set the environment variable `ES_INDEX_SUFFIX`. Your specified string will be added to the end of the index name.

## Upgrading elasticsearch

This covers what we did to upgrade from ES 5 to ES 7. It's preserved here in hopes of streamlining future ES upgrades. The specific commands we used are in our [Redmine instance](https://cyber.harvard.edu/projectmanagement/issues/17194)

1. Stand up a cluster on the target version.
2. Upgrade your codebase to the matching `elasticsearch-rails` gem version.
3. Optional: create indices with the appropriate mappings for `Notice` and `Entity`.
  * The indexes created automatically by the reindex API will have the mapping of the original indexes.
  * This is fine if you're not changing mappings.
  * However, you may want to change mappings for various reasons (e.g. dropping fields to avoid accidentally exposing redacted data; changing analyzers to enable different search options).
4. Reindex from the source index (probably production) into the newly created index in the upgraded cluster.
  * Do _not_ use the index name that Rails will expect -- use something with more descriptive metadata, like a datestamp.
  * Do _not_ reindex from the database -- it's ten times slower. (Reindexing from our ES 5 cluster took ~2 days; reindex-from-database would have taken weeks.)
  * You may need to tweak the `size` parameter:
    * The default batch size of 1000 may overwhelm the available memory when you get into large notices.
    * There isn't a way to determine a priori what the largest notice is (without installing a plugin that indexes by size, and the doing a full reindex), so determine experimentally what batch size will let you reindex to completion.
    * Setting the index command to restart itself with a smaller batch size on failure is the best way we found to do this. Our magic number was `67` (but this may differ in future if there are larger notices).
  * The reindex command will return a task ID you can use to check task status.
5. Create (or repoint) aliases which points the names Rails uses to your target notice/entity indexes.
  * This will allow you to upgrade with near-zero downtime, by reindexing in the background and cutting over when ready.
6. You can now do your Rails deploy (with the upgraded elasticsearch gems) and it should just work.
   * If the Rails server is already running a correct version and you just want to update the elasticsearch index, there's nothing (!) you need to do on the Rails side -- repointing the index will take care of it for you.

## What we index

Earlier versions of Elasticsearch had an `_all` field. By default all the fields were copied to `_all`, which was analyzed as text. This was also the default search field.

As of Elasticsearch 7.x, `_all` no longer exists. The documentation says you should specify particular fields you want to search. It also says that searching a large number of fields creates performance problems.

In our original ES 7.x deploy, we did search a large number of fields. This was fast for relatively small result sets (e.g. 'batman', which has more than 10K hits, but is still small compared to some of our users' searches). However, it timed out for large searches (like "DMCA").

A subsequent reindex + deploy copied some fields to `base_search` and `preferred_search`, such that we can boost `preferred_search` when searching. (See `app/models/elasticsearch/searchability.rb`.) This made small searches slower, but made it possible for large searches to complete at all.

Additional tweaking would be better.
