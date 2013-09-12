#!/bin/zsh
#

if [ "$FILE_NAME" = "" ]; then
  echo "Please provide a path to the CSV in the FILE_NAME ENV variable"
  exit
fi

echo 'Kill foreman and hit enter'
read

rm -Rf public/system/file_uploads
rm -f log/development.log

bundle exec rake db:drop db:create db:migrate

echo "start foreman and hit enter"
read

SKIP_FAKE_DATA=1 bundle exec rake db:seed db:test:prepare

echo "starting import"
date

# Not necessary, but I wanted to make it obvious that FILE_NAME is being used
# here.

time DEBUG=1 FILE_NAME="$FILE_NAME" bundle exec rake chillingeffects:import_legacy_data

echo "import complete"
date
