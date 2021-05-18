#!/bin/bash
# Test that resolution versions are in sync with installed versions.

while read dep; do
    read resolution_version
    package="$(sed -e 's/^.*\*\*\///' <<< $dep)"
    version="$(jq -r .dependencies[\""$package"\"] package.json)"
    if [ "$version" != "$resolution_version" ]; then
        echo "Need $package $version but got $resolution_version in resolutions"
        exit 1
    fi
done < <(jq -r '.resolutions | to_entries[][]' package.json)

echo "Resolution versions match dependencies"
