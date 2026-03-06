#!/bin/bash
# Expected to run from the root repository.
set -eux
CWD=$(pwd)

cd ./test/rdjson_formatter/testdata

yarn audit --json 2>/dev/null \
  | ruby "${CWD}/rdjson_formatter/rdjson_formatter.rb" yarn.lock \
  | jq . \
  | sed -e "s!${CWD}/!!g" \
  > result.out

cd "${CWD}"
diff -u ./test/rdjson_formatter/testdata/result.ok ./test/rdjson_formatter/testdata/result.out
