#!/usr/bin/env sh

set -e

ENV_NAME=$(echo "$RAILS_ENV" | tr '[:lower:]' '[:upper:]')

export DATABASE_HOST=$(printenv DATABASE_${ENV_NAME}_HOST)
export DATABASE_PORT=$(printenv DATABASE_${ENV_NAME}_PORT)
export DATABASE_DB_NAME=$(printenv DATABASE_${ENV_NAME}_DB_NAME)
export DATABASE_USERNAME=$(printenv DATABASE_${ENV_NAME}_USERNAME)
export DATABASE_PASSWORD=$(printenv DATABASE_${ENV_NAME}_PASSWORD)

exec logstash --path.settings /app/script/search_indexing/
