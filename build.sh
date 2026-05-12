#!/bin/bash
set -euo pipefail

# HASH = tree sha of pytorch/pytorch:.ci/docker on main (== git rev-parse HEAD:.ci/docker)
HASH=$(curl -fsSL "https://api.github.com/repos/pytorch/pytorch/contents/.ci?ref=main" \
    | python3 -c 'import json,sys; print(next(x["sha"] for x in json.load(sys.stdin) if x["name"]=="docker"))')

DATE=$(date +%Y%m%d)
TAG="jeffdaily/pytorch:noble-rocm-7.2-py3-${DATE}"

echo "HASH=${HASH}"
echo "TAG=${TAG}"
docker build . --build-arg HASH="${HASH}" -t "${TAG}"
