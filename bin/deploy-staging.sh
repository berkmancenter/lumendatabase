#!/bin/bash

set_up_environment() {
  . ~/.profile
  export RAILS_ENV=production
  cd $APP_ROOT
  . $RVM_ENV_LOADER
}

start_fresh() {
  git pull
  bundle

  # No createdb rights for the user, so this is necessary.
  psql -h $DATABASE_HOST -U $DATABASE_USERNAME $DATABASE_NAME -t -c "\
    select 'drop table \"' || tablename || '\" cascade;' from pg_tables \
      where schemaname = 'public'" | \
      psql -h $DATABASE_HOST -U $DATABASE_USERNAME $DATABASE_NAME
}

seed_and_restart() {
  NOTICE_COUNT=1000 rake db:migrate db:seed
  rake assets:precompile
  touch tmp/restart.txt
}

set_up_environment
start_fresh
seed_and_restart

echo "Deploy from master finished. You may disconnect if it doesn't happen automatically."
