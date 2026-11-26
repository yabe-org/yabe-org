#!/usr/bin/env bash
# Runs the given command, retrying it only when it failed because a Maven
# repository answered 429 Too Many Requests, which happens to GitHub-hosted
# runners while Gradle resolves dependencies.
#
# Usage: retry-on-maven-rate-limit.sh <command> [args...]
set -uo pipefail

attempts=3
log="$(mktemp)"
trap 'rm -f "$log"' EXIT

for attempt in $(seq 1 "$attempts"); do
  "$@" 2>&1 | tee "$log"
  status=$?
  if [ "$status" -eq 0 ] || [ "$attempt" -eq "$attempts" ] ||
    ! grep -q "Received status code 429" "$log"; then
    exit "$status"
  fi
  echo "Maven repository rate limit (attempt $attempt/$attempts)" >&2
  sleep $((attempt * 120))
done
