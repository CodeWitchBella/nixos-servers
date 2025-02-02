#!/usr/bin/env bash

set -e

pin_file="docker-pin.json"
images=`jq 'keys_unsorted | join("\n")' -r $pin_file`

for image in $images
do
    echo "updating: $image"
    ./pin/add.sh "$image"
done
