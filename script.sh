#!/usr/bin/env bash

set -e
set -o pipefail

cd "${GITHUB_WORKSPACE}/${INPUT_WORKDIR}" || exit

TEMP_PATH="$(mktemp -d)"
PATH="${TEMP_PATH}:$PATH"

echo '::group::🐶 Installing reviewdog ... https://github.com/reviewdog/reviewdog'
curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/fd59714416d6d9a1c0692d872e38e7f8448df4fc/install.sh | sh -s -- -b "${TEMP_PATH}" "${REVIEWDOG_VERSION}" 2>&1
echo '::endgroup::'

if [ "${INPUT_SKIP_INSTALL}" = "false" ]; then
  echo '::group:: Installing yarn ...'
  npm install -g yarn
  echo '::endgroup::'
fi

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

echo "::group:: Running yarn audit with reviewdog 🐶..."

# NOTE: yarn audit exits with non-zero code when vulnerabilities are found,
# so we suppress its exit code to let reviewdog determine the final result.
# shellcheck disable=SC2086
(yarn audit --json || true) \
  | ruby "${GITHUB_ACTION_PATH}/rdjson_formatter/rdjson_formatter.rb" \
  | reviewdog -f=rdjson \
      -name="${INPUT_TOOL_NAME}" \
      -reporter="${INPUT_REPORTER}" \
      -filter-mode="${INPUT_FILTER_MODE}" \
      -fail-level="${INPUT_FAIL_LEVEL}" \
      -level="${INPUT_LEVEL}" \
      ${INPUT_REVIEWDOG_FLAGS}

reviewdog_rc=$?
echo '::endgroup::'
exit $reviewdog_rc
