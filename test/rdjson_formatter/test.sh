#!/bin/bash
# Expected to run from the root repository.
set -eux
CWD=$(pwd)

compare_json() {
  diff -u <(jq -S -c . "$1") <(jq -S -c . "$2")
}

cd ./test/rdjson_formatter/testdata

yarn audit --json 2>/dev/null \
  | ruby "${CWD}/rdjson_formatter/rdjson_formatter.rb" yarn.lock \
  | jq . \
  | sed -e "s!${CWD}/!!g" \
  > result.out

cd "${CWD}"
compare_json ./test/rdjson_formatter/testdata/result.ok ./test/rdjson_formatter/testdata/result.out

ruby "${CWD}/rdjson_formatter/rdjson_formatter.rb" ./test/rdjson_formatter/testdata/yarn.lock \
  < ./test/rdjson_formatter/testdata/advisory_without_cve.jsonl \
  | jq . \
  | sed -e "s!${CWD}/!!g" \
  > ./test/rdjson_formatter/testdata/advisory_without_cve.out

compare_json ./test/rdjson_formatter/testdata/advisory_without_cve.ok ./test/rdjson_formatter/testdata/advisory_without_cve.out
