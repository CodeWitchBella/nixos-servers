#!/usr/bin/env bash

set -e

pin_file="docker-pin.json"
tag="$1"

manifest=`podman manifest inspect "$tag"`
# manifest='{"hello":"world"}'

out=`echo "$manifest" | jq '$pin[0] + {$tag:.}' \
    --slurpfile pin "$pin_file" \
    --arg tag "$tag"`

echo "$out" > "$pin_file"
