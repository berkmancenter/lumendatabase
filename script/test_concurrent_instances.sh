#!/usr/bin/env bash
set -euo pipefail

compose_file="${COMPOSE_FILE:-docker-compose.concurrent.yml}"
base_url="${CONCURRENT_TEST_URL:-http://127.0.0.1:8282}"
keep_stack="${KEEP_CONCURRENT_STACK:-0}"

compose=(docker compose -f "$compose_file")

cleanup() {
  if [[ "$keep_stack" == "1" ]]; then
    echo "Leaving concurrent test stack running: ${compose[*]}"
  else
    "${compose[@]}" down --volumes
  fi
}

request_headers() {
  local path="$1"
  local headers_file="$2"

  curl -q --silent --show-error \
    --output /dev/null \
    --dump-header "$headers_file" \
    --max-redirs 0 \
    --max-time 10 \
    "$base_url$path"
}

header_value() {
  local header_name="$1"
  local headers_file="$2"

  awk -v wanted="$header_name" '
    BEGIN { IGNORECASE = 1 }
    $1 == wanted ":" {
      value = $0
      sub("^[^:]+:[[:space:]]*", "", value)
      gsub("\r", "", value)
      print value
    }
  ' "$headers_file" | tail -n 1
}

assert_pool() {
  local path="$1"
  local expected_pool="$2"
  local headers_file
  local actual_pool

  headers_file="$(mktemp)"
  request_headers "$path" "$headers_file"
  actual_pool="$(header_value X-Lumen-Upstream-Pool "$headers_file")"
  rm -f "$headers_file"

  if [[ "$actual_pool" != "$expected_pool" ]]; then
    echo "Expected $path to route to $expected_pool, got ${actual_pool:-<missing>}" >&2
    return 1
  fi

  echo "ok route $path -> $expected_pool"
}

assert_pool_fans_out() {
  local path="$1"
  local expected_pool="$2"
  local expected_count="${3:-2}"
  local upstreams_file
  local headers_file
  local actual_pool
  local upstream_addr
  local instance_name
  local distinct_count

  upstreams_file="$(mktemp)"

  for _ in $(seq 1 15); do
    headers_file="$(mktemp)"
    request_headers "$path" "$headers_file"
    actual_pool="$(header_value X-Lumen-Upstream-Pool "$headers_file")"
    upstream_addr="$(header_value X-Lumen-Upstream-Addr "$headers_file")"
    instance_name="$(header_value X-Lumen-Instance-Name "$headers_file")"
    rm -f "$headers_file"

    if [[ "$actual_pool" != "$expected_pool" ]]; then
      rm -f "$upstreams_file"
      echo "Expected $path to route to $expected_pool, got ${actual_pool:-<missing>}" >&2
      return 1
    fi

    if [[ -n "$instance_name" ]]; then
      echo "$instance_name" >> "$upstreams_file"
    elif [[ -n "$upstream_addr" ]]; then
      echo "$upstream_addr" >> "$upstreams_file"
    fi
  done

  distinct_count="$(sort -u "$upstreams_file" | wc -l | tr -d ' ')"
  if [[ "$distinct_count" -lt "$expected_count" ]]; then
    echo "Expected $expected_pool to fan out to $expected_count upstreams for $path, saw $distinct_count" >&2
    sort -u "$upstreams_file" >&2
    rm -f "$upstreams_file"
    return 1
  fi

  rm -f "$upstreams_file"
  echo "ok fanout $expected_pool uses $distinct_count upstreams"
}

wait_for_router() {
  local headers_file

  for _ in $(seq 1 90); do
    headers_file="$(mktemp)"
    if request_headers /admin "$headers_file"; then
      if [[ "$(header_value X-Lumen-Upstream-Pool "$headers_file")" == "admin" ]]; then
        rm -f "$headers_file"
        return 0
      fi
    fi
    rm -f "$headers_file"
    sleep 2
  done

  echo "Timed out waiting for the concurrent router at $base_url" >&2
  return 1
}

assert_shared_redis_cache() {
  "${compose[@]}" exec -T notices-1 bash -c \
    "bundle exec rails runner \"abort Rails.cache.class.name unless Rails.cache.class.name == 'ActiveSupport::Cache::RedisCacheStore'; Rails.cache.write('concurrent-cache-probe', 'ok')\""

  "${compose[@]}" exec -T search-1 bash -c \
    "bundle exec rails runner \"abort 'cache miss across instances' unless Rails.cache.read('concurrent-cache-probe') == 'ok'\""

  echo "ok Redis cache is shared across app instances"
}

trap cleanup EXIT

"${compose[@]}" up --build --detach

wait_for_router
assert_shared_redis_cache

assert_pool /admin admin
assert_pool /admin/ admin
assert_pool /notices/search search
assert_pool /enterprise/notices/search search
assert_pool /entities/search search
assert_pool /media_mentions/search search
assert_pool /faceted_search search
assert_pool /search/probe search
assert_pool /notices/1 notices
assert_pool /notices/new notices
assert_pool /n/1 notices
assert_pool /N/1 notices
assert_pool /file_uploads/files/1/000/000/001/original/missing.txt notices

assert_pool_fans_out /admin admin
assert_pool_fans_out /notices/search search
assert_pool_fans_out /notices/1 notices

echo "Concurrent instance routing test passed."
