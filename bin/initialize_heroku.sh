#!/bin/sh

read -p 'This will delete *everything* and start from seed data. Enter "yes" to continue: ' answer

if [ "$answer" = "yes" ]
then
  heroku pg:reset DATABASE_URL --remote staging --confirm chillingeffects
  heroku run rake db:migrate chillingeffects:delete_search_index db:seed --remote staging
fi
