#!/usr/bin/env bash
# shellcheck disable=SC2181

# Stylua check
diffs=$(stylua --check --output-format=json .)

# Exit code != 0 means there are changes (files are not formatted)
if [[ "$?" -ne 0 ]]; then
  # Get filenames of diffs
  filelist="$(echo "$diffs" | jq -r '.file')"

  # Format & add to git
  stylua "$filelist"
  git add "$filelist"
fi

# Run lints
make lint

# Run tests
# make test

# Generate docs & add to git
make documentation
git add doc

