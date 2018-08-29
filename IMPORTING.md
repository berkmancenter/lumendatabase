Importing from Mysql
====================

The ingestor can now import directly from the legacy MySQL lumen database.

This presupposes a few conditions:

1) The process can CD into a `BASE_DIRECTORY` that contains all the possible files, and
2) The MySQL connection is correctly configured via environment variables.

It records errors into the NoticeImportError model, which allows for more
flexible searching and viewing of errors. Below is a list of relevant
environment variables.

* `MYSQL_HOST`
* `MYSQL_USERNAME`
* `MYSQL_PASSWORD`
* `MYSQL_PORT`
* `MYSQL_DATABASE`
* `BASE_DIRECTORY` - The directory that contains the original source files

See `lib/tasks/lumen.rake` for examples.

Please be sure to have a large `net_read_timeout` value in your MySQL server,
as we stream results and MySQL queries will abort if they don't see a read
before `net_read_timeout` expires. This is crucial. Some individual records may
take longer than `net_read_timeout` to import, as this value is normally set
very low.

Incremental imports from MySQL
==============================

The rake task `lumen:import_new_notices_via_mysql` will look for the
maximum `original_notice_id`, and then import notices from the legacy system
with a NoticeID higher than that value.  This allow us to import periodically
via a cron job, and works very similarly to how importing is described above

Custom legacy imports
=====================

The rake task `lumen:import_notices_via_mysql` accepts a "WHERE"
fragment via ENV that is used in the class
`Ingestor::Legacy::RecordSource::Mysql` to define a set of notices to import
from the legacy system.  You can customize and re-run imports by creating
relevant WHERE fragments, and then running the importer in a persistent
terminal session (say, screen or tmux). An example:

    BASE_DIRECTORY=/path/to/chill/docs/images/notices/ IMPORT_NAME=youtube-reimport WHERE="tNotice.NoticeID > 1500000 and tNotice.NoticeID < 1538474" rake lumen:import_notices_via_mysql

will import notices with NoticeID > 1500000 and less than 1538474. Remember
that the importer will skip legacy notice IDs that it's already seen, so if you
want to re-import notices you should delete them from the new system first.

WHERE fragments passed to this rake task should allow you to easily.

Writing new legacy file importers
=================================

Please see [this
commit](https://github.com/berkmancenter/lumendatabase/commit/bf8db0515173c40336ab6e4e9c90b7fe618e5a47),
which wraps up all the necessary steps that're required to create a new
importer that can recover additional metadata from the legacy system.

To summarize:

* Add a row to `spec/support/example_files/example_notice_export.csv` that includes redacted data matching what's in the mysql tNotice table.
* Determine the data you want to extract from the file by parsing it by eye, deanonymizing it as appropriate.
* Write a test to define what and how the new `Ingestor::Importer::*` class will parse from a given file format.
* Add an integration spec to `spec/integration/imports_existing_data_as_csv_spec.rb` for the data you're parsing above.
* Register your importer in `lib/ingestor.rb`
* Ensure that your importer defines what files it "handles" by giving it a regex pattern that will allow you to find the file format uniquely.
* An importer needs to implement the `parse_works`, `notice_type`, `sender` and optionally `principal` and `parse_registration_mark_number`.

See the various specs for more information. Probably the easiest way to
understand importing is to walk through the `Ingester::Legacy#import` method,
which will bring you into the `Ingester::Legacy#import_row` method.  Attributes
are assigned through the `Ingestor::Legacy::AttributeMapper` class, which also
determines which importer to use through the `Ingester::ImportDispatcher` class.

Blog Imports
============

Export the blog table as a CSV file from MySQL, and then run the rake task
`lumen::import_blog_entries`. Set the blog entry CSV file via
ENV['FILE_NAME'], and it probably makes sense to clear out the seed blog
entries before running this. See `spec/support/example_files/blog_export.csv`
for an example export file, which should be directly from MySQL.

Question to Notice relations
============================

These can be imported by exporting the lumen legacy table that links
notices and questions as CSV from mysql.  Then, pass that CSV file to the rake
task `lumen::import_questions` via ENV['FILE_NAME']. See the
QuestionImporter specs for information on the file format.
