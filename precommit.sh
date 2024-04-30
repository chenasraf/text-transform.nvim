#!/usr/bin/env bash
diffs=$(stylua --check --output-format=json .)
if [[ "$?" -ne 0 ]]; then
  filelist="$(echo "$diffs" | jq -r '.file')"
  echo stylua "$filelist"
  echo git add "$filelist"
fi
make lint
# make test
make documentation
git add doc

