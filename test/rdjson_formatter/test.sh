#!/bin/bash
# Expected to run from the root repository.
set -eux
CWD=$(pwd)

compare_json() {
  diff -u <(jq -S . "$1") <(jq -S . "$2")
}

cd ./test/rdjson_formatter/testdata

yarn audit --json 2>/dev/null \
  | ruby "${CWD}/rdjson_formatter/rdjson_formatter.rb" yarn.lock \
  | jq . \
  | sed -e "s!${CWD}/!!g" \
  > result.out

cd "${CWD}"
compare_json ./test/rdjson_formatter/testdata/result.ok ./test/rdjson_formatter/testdata/result.out

cd ./test/rdjson_formatter/testdata

ruby "${CWD}/rdjson_formatter/rdjson_formatter.rb" yarn.lock \
  < advisory_without_cve.jsonl \
  | jq . \
  | sed -e "s!${CWD}/!!g" \
  > advisory_without_cve.out

cd "${CWD}"
compare_json ./test/rdjson_formatter/testdata/advisory_without_cve.ok ./test/rdjson_formatter/testdata/advisory_without_cve.out
