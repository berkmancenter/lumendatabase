Importing from Mysql
====================

The ingestor can now import directly from the legacy MySQL chillingeffects datastore.

This presupposes a few conditions:

1) The process can CD into a `BASE_DIRECTORY` that contains all the possible files, and
2) The MySQL connection is correctly configured via environment variables

It also has the ability to write failures as CSV (including the relevant files)
into a separate directory, configured, again, via ENV. Below is a list of
relevant environment variables.

* `MYSQL_HOST`
* `MYSQL_USERNAME`
* `MYSQL_PASSWORD`
* `MYSQL_PORT`
* `MYSQL_DATABASE`
* `BASE_DIRECTORY` - The directory that contains the original source files
* `IMPORT_ERRORS_DIRECTORY` - The directory that will store the error CSV reports and source file copies. It needs to be writeable by the user the importer runs as.

The importer can import from CSV and MySQL. See
`lib/tasks/chillingeffects.rake` for examples.
