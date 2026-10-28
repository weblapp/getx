#!/bin/sh
# Compares the failed tests of a `flutter test --file-reporter json:<file>` run with the
# known-failures list. Exits 1 when a test fails that is not on the list, or when the run
# produced no results; prints a notice when a listed test passes again.
#
# Usage: check-known-failures.sh <results.json> <known-failures.txt>
set -eu

results="$1"
known_list="$2"

if [ ! -s "$results" ]; then
  echo "::error::no test results in $results (did flutter test run?)"
  exit 1
fi

failed=$(mktemp)
known=$(mktemp)
trap 'rm -f "$failed" "$known"' EXIT

# One line per failed test: "<path under test/> :: <name>". A file that does not compile
# shows up as its "loading <path>" test, so it counts as a new failure.
jq -rs '
  (map(select(.type == "suite")) | map({key: (.suite.id | tostring), value: .suite.path}) | from_entries) as $suites
  | (map(select(.type == "testStart")) | map({key: (.test.id | tostring), value: .test}) | from_entries) as $tests
  | map(select(.type == "testDone" and .result != "success" and (.skipped | not)))
  | map($tests[(.testID | tostring)] | "\(($suites[(.suiteID | tostring)] // "?") | sub(".*/test/"; "test/")) :: \(.name)")
  | unique | .[]
' "$results" | sort -u > "$failed"

grep -v '^[[:space:]]*#' "$known_list" | sed '/^[[:space:]]*$/d' | sort -u > "$known"

new_failures=$(comm -23 "$failed" "$known")
passing_again=$(comm -13 "$failed" "$known")

echo "failed: $(wc -l < "$failed" | tr -d ' '), known: $(wc -l < "$known" | tr -d ' ')"

if [ -n "$passing_again" ]; then
  echo "$passing_again" | while IFS= read -r line; do
    echo "::notice::listed but did not fail in this run (remove it once it passes in a full run): $line"
  done
fi

if [ -n "$new_failures" ]; then
  echo "$new_failures" | while IFS= read -r line; do
    echo "::error::new failure: $line"
  done
  exit 1
fi

echo "no new failures"
