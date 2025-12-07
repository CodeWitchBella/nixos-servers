#!/bin/sh

set -e

function q {
    "$@"
    # "$@" > /dev/null 2>&1
}

if [ ! -f flake.nix ]; then
    echo "This script must be run from the directory containing flake.nix"
    exit 1
fi

cd podman

if [ ! -z "$1" ]; then
    images="$1"
else
    images=`cat images.json | jq -r '[.[] | .repository+":"+.tag] | join(" ")'`
fi

if [ -z "$images" ]; then
    echo "No images to check"
    exit 0
fi
echo "Images to check: $images"

touch -d"-15min" .tmp
if [ ! -f check.json ] || [ .tmp -nt "check.json" ]; then
    if cup -s none check $images --raw > .tmp
    then
        mv .tmp check.json
        echo "check.json updated"
    else
        echo "Failed to update check.json"
        rm -f .tmp
        exit 1
    fi
fi
rm -f .tmp

deno run -A update.ts
