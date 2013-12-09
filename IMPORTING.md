Importing from Mysql
====================

The ingestor can now import directly from the legacy MySQL chillingeffects database.

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

See `lib/tasks/chillingeffects.rake` for examples.
