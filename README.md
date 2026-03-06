# GitHub Action: Run "yarn audit" with reviewdog :dog:

[![Test](https://github.com/codeur/action-yarn-audit/workflows/Test/badge.svg)](https://github.com/codeur/action-yarn-audit/actions?query=workflow%3ATest)
[![reviewdog](https://github.com/codeur/action-yarn-audit/workflows/reviewdog/badge.svg)](https://github.com/codeur/action-yarn-audit/actions?query=workflow%3Areviewdog)
[![depup](https://github.com/codeur/action-yarn-audit/workflows/depup/badge.svg)](https://github.com/codeur/action-yarn-audit/actions?query=workflow%3Adepup)
[![release](https://github.com/codeur/action-yarn-audit/workflows/release/badge.svg)](https://github.com/codeur/action-yarn-audit/actions?query=workflow%3Arelease)
[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/codeur/action-yarn-audit?logo=github&sort=semver)](https://github.com/codeur/action-yarn-audit/releases)
[![action-bumpr supported](https://img.shields.io/badge/bumpr-supported-ff69b4?logo=github&link=https://github.com/haya14busa/action-bumpr)](https://github.com/haya14busa/action-bumpr)

This action runs [yarn audit](https://github.com/yarnpkg/yarn) with
[reviewdog](https://github.com/reviewdog/reviewdog) on pull requests to improve
code review experience.

## Requirements

- **Ruby**: The action uses a Ruby formatter to convert yarn audit output to the reviewdog format. Ruby is typically available on GitHub Actions runners by default, but you may need to install it in custom environments.
- **Node.js**: Required to run yarn audit. Node.js is typically available on GitHub Actions runners by default.

## Examples

### With `github-pr-review`

With `reporter: github-pr-review` a comment is added to the Pull Request Conversation.

## Inputs

### `github_token`

`GITHUB_TOKEN`. Default is `${{ github.token }}`.

### `tool_name`

Optional. Tool name to use for reviewdog reporter. Useful when running multiple
actions with different config.

### `level`

Optional. Report level for reviewdog [`info`, `warning`, `error`].
It's same as `-level` flag of reviewdog.

### `reporter`

Optional. Reporter of reviewdog command [`github-pr-check`, `github-check`, `github-pr-review`].
The default is `github-check`.

### `fail_level`

Optional. If set to `none`, always use exit code 0 for reviewdog. Otherwise, exit code 1 for reviewdog if it finds at least 1 issue with severity greater than or equal to the given level.
Possible values: [`none`, `any`, `info`, `warning`, `error`].
Default is `none`.

### `filter_mode`

Optional. Filtering mode for the reviewdog command [`added`, `diff_context`, `file`, `nofilter`].
Default is `added`.

### `reviewdog_flags`

Optional. Additional reviewdog flags.

### `skip_install`

Optional. Do not install yarn. If set to `true`, yarn must be available in the environment. Default: `false`.

### `workdir`

Optional. The directory from which to look for and run `yarn audit`. Default `.`.

## Example usage

```yaml
name: reviewdog
on: [pull_request]
jobs:
  yarn_audit:
    name: runner / yarn audit
    runs-on: ubuntu-latest
    steps:
      - name: Check out code
        uses: actions/checkout@v6
      - name: Set up Node.js
        uses: actions/setup-node@v6
        with:
          node-version: 'lts/*'
      - name: Run yarn audit
        uses: codeur/action-yarn-audit@v0
        with:
          reporter: github-pr-review
```

## Dev

### Release new version

1. Create a Pull Request with changes.
2. Add one of the following labels to the PR:
   - `bump:major`: Bump major version (e.g. v1.0.0 -> v2.0.0)
   - `bump:minor`: Bump minor version (e.g. v1.0.0 -> v1.1.0)
   - `bump:patch`: Bump patch version (e.g. v1.0.0 -> v1.0.1)
3. Merge the PR.
4. The release workflow will automatically bump the version, create a release, and update major/minor tags (e.g. v1).

### Test locally

You can test locally with a command like that:

```sh
GITHUB_WORKSPACE=$(pwd) INPUT_WORKDIR=test/rdjson_formatter/testdata INPUT_TOOL_NAME="yarn audit" INPUT_LEVEL=error INPUT_FAIL_LEVEL=any INPUT_REPORTER=local GITHUB_ACTION_PATH=$(pwd) ./script.sh
```

## License

[MIT](https://choosealicense.com/licenses/mit)
