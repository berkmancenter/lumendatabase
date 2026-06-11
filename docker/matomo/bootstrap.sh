#!/bin/sh
set -eu

MATOMO_URL="${MATOMO_URL:-http://matomo}"
MATOMO_DATABASE_HOST="${MATOMO_DATABASE_HOST:-matomo_db}"
MATOMO_DATABASE_ADAPTER="${MATOMO_DATABASE_ADAPTER:-PDO\\MYSQL}"
MATOMO_DATABASE_TABLES_PREFIX="${MATOMO_DATABASE_TABLES_PREFIX:-matomo_}"
MATOMO_DATABASE_USERNAME="${MATOMO_DATABASE_USERNAME:-matomo}"
MATOMO_DATABASE_PASSWORD="${MATOMO_DATABASE_PASSWORD:-matomo-secret}"
MATOMO_DATABASE_DBNAME="${MATOMO_DATABASE_DBNAME:-matomo}"
MATOMO_DATABASE_SCHEMA="${MATOMO_DATABASE_SCHEMA:-Mariadb}"
MATOMO_ADMIN_USERNAME="${MATOMO_ADMIN_USERNAME:-admin}"
MATOMO_ADMIN_PASSWORD="${MATOMO_ADMIN_PASSWORD:-matomo-admin}"
MATOMO_ADMIN_EMAIL="${MATOMO_ADMIN_EMAIL:-admin@example.test}"
MATOMO_SITE_ID="${MATOMO_SITE_ID:-1}"
MATOMO_SITE_NAME="${MATOMO_SITE_NAME:-Lumen development}"
MATOMO_SITE_URL="${MATOMO_SITE_URL:-http://localhost:8282}"
MATOMO_SITE_TIMEZONE="${MATOMO_SITE_TIMEZONE:-UTC}"
MATOMO_SITE_ECOMMERCE="${MATOMO_SITE_ECOMMERCE:-0}"
MATOMO_TRUSTED_HOST_INTERNAL="${MATOMO_TRUSTED_HOST_INTERNAL:-matomo}"
MATOMO_TRUSTED_HOST_EXTERNAL="${MATOMO_TRUSTED_HOST_EXTERNAL:-localhost:8283}"
# Keep this order in sync with CreateMatomoDimensionIdSettings defaults.
MATOMO_USAGE_DIMENSIONS="credential_status auth_method surface authenticated_user_email"

COOKIE_JAR="$(mktemp)"
LAST_RESPONSE="/tmp/matomo-bootstrap-response.html"

cleanup() {
  rm -f "$COOKIE_JAR"
}
trap cleanup EXIT

get() {
  curl -fsS -L -c "$COOKIE_JAR" -b "$COOKIE_JAR" -o "$LAST_RESPONSE" "$1"
}

post() {
  curl -fsS -L -c "$COOKIE_JAR" -b "$COOKIE_JAR" -o "$LAST_RESPONSE" -X POST "$@"
}

wait_for_matomo() {
  i=0
  until curl -fsS -o /dev/null "$MATOMO_URL/index.php" 2>/dev/null; do
    i=$((i + 1))
    if [ "$i" -ge 60 ]; then
      echo "Matomo did not become reachable at $MATOMO_URL" >&2
      exit 1
    fi
    sleep 2
  done
}

is_installed() {
  response="$(curl -fsS "$MATOMO_URL/matomo.php?idsite=$MATOMO_SITE_ID&rec=0&send_image=0" 2>/dev/null)" || return 1
  ! printf '%s' "$response" | grep -q "not installed yet"
}

configure_trusted_hosts() {
  if [ ! -f /var/www/html/config/config.ini.php ]; then
    return
  fi

  php /var/www/html/console config:set \
    'General.trusted_hosts=[]' \
    "General.trusted_hosts[]=\"$MATOMO_TRUSTED_HOST_INTERNAL\"" \
    "General.trusted_hosts[]=\"$MATOMO_TRUSTED_HOST_EXTERNAL\"" \
    --matomo-domain="$MATOMO_URL"
}

# Development-only: make "today" reports recompute from the raw logs on every
# view (TTL 0) instead of caching them, so freshly tracked hits show up in the
# UI/Reporting API immediately. Browser-triggered archiving is enabled too in
# case the global default ever changes. Never set this in production.
configure_dev_archiving() {
  php /var/www/html/console config:set \
    'General.time_before_today_archive_considered_outdated=0' \
    'General.enable_browser_archiving_triggering=1' \
    --matomo-domain="$MATOMO_URL"
}

matomo_api_request() {
  php /var/www/html/console climulti:request \
    --superuser \
    --matomo-domain="$MATOMO_URL" \
    "$1"
}

configured_action_dimensions() {
  matomo_api_request "module=API&method=CustomDimensions.getConfiguredCustomDimensionsHavingScope&idSite=$MATOMO_SITE_ID&scope=action&format=json"
}

ensure_usage_dimension() {
  name="$1"

  if configured_action_dimensions | grep -q "\"name\":\"$name\""; then
    echo "Matomo action custom dimension '$name' is already configured."
    return
  fi

  echo "Creating Matomo action custom dimension '$name'."
  matomo_api_request "module=API&method=CustomDimensions.configureNewCustomDimension&idSite=$MATOMO_SITE_ID&name=$name&scope=action&active=1&format=json" >/dev/null
}

configure_usage_dimensions() {
  for dimension in $MATOMO_USAGE_DIMENSIONS; do
    ensure_usage_dimension "$dimension"
  done
}

wait_for_matomo

if is_installed; then
  echo "Matomo is already installed; ensuring trusted hosts, usage dimensions and dev archiving are configured."
  configure_trusted_hosts
  configure_dev_archiving
  configure_usage_dimensions
  exit 0
fi

echo "Installing Matomo development instance."

get "$MATOMO_URL/index.php?action=systemCheck"

# Matomo's installer forms are HTML_QuickForm2 forms created with
# trackSubmit=false (see core/QuickForm2.php), so a form is only processed when
# the POST mirrors what the browser sends: every visible field PLUS the form's
# submit button. Omitting the submit button (and the hidden "type" field here)
# makes the form silently re-render without saving, which previously left
# config.ini.php without a [database] section and made tablesCreation fail with
# "SQLSTATE[HY000] [2002] No such file or directory".
post "$MATOMO_URL/index.php?action=databaseSetup" \
  --data-urlencode "type=InnoDB" \
  --data-urlencode "host=$MATOMO_DATABASE_HOST" \
  --data-urlencode "username=$MATOMO_DATABASE_USERNAME" \
  --data-urlencode "password=$MATOMO_DATABASE_PASSWORD" \
  --data-urlencode "dbname=$MATOMO_DATABASE_DBNAME" \
  --data-urlencode "tables_prefix=$MATOMO_DATABASE_TABLES_PREFIX" \
  --data-urlencode "adapter=$MATOMO_DATABASE_ADAPTER" \
  --data-urlencode "schema=$MATOMO_DATABASE_SCHEMA" \
  --data-urlencode "submit=Next »"

get "$MATOMO_URL/index.php?action=tablesCreation&module=Installation"
get "$MATOMO_URL/index.php?action=setupSuperUser&module=Installation"

post "$MATOMO_URL/index.php?action=setupSuperUser&module=Installation" \
  --data-urlencode "login=$MATOMO_ADMIN_USERNAME" \
  --data-urlencode "password=$MATOMO_ADMIN_PASSWORD" \
  --data-urlencode "password_bis=$MATOMO_ADMIN_PASSWORD" \
  --data-urlencode "email=$MATOMO_ADMIN_EMAIL" \
  --data-urlencode "subscribe_newsletter_piwikorg=0" \
  --data-urlencode "subscribe_newsletter_professionalservices=0" \
  --data-urlencode "submit=Next »"

get "$MATOMO_URL/index.php?action=firstWebsiteSetup&module=Installation"

post "$MATOMO_URL/index.php?action=firstWebsiteSetup&module=Installation" \
  --data-urlencode "siteName=$MATOMO_SITE_NAME" \
  --data-urlencode "url=$MATOMO_SITE_URL" \
  --data-urlencode "timezone=$MATOMO_SITE_TIMEZONE" \
  --data-urlencode "ecommerce=$MATOMO_SITE_ECOMMERCE" \
  --data-urlencode "submit=Next »"

get "$MATOMO_URL/index.php?action=finished&module=Installation"

post "$MATOMO_URL/index.php?action=finished&module=Installation" \
  --data-urlencode "submit=Continue to Matomo »"

if ! is_installed; then
  echo "Matomo installer did not complete successfully." >&2
  exit 1
fi

configure_trusted_hosts
configure_dev_archiving
configure_usage_dimensions

echo "Matomo development instance is ready."
