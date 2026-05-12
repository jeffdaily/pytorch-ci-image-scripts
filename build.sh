#!/bin/bash
set -euo pipefail

# Resolve HASH = tree sha of pytorch/pytorch:.ci/docker (== git rev-parse <ref>:.ci/docker).
# The newest SHA on main can lag behind ghcr.io by 1-2h while upstream CI builds
# the matching image. Walk back recent commits touching .ci/docker until one
# has a published image. Override with HASH=<sha> in the env to skip detection.

REPO="ghcr.io/pytorch/ci-image"
TAG_PREFIX="pytorch-linux-noble-rocm-n-py3"

resolve_hash() {
    local commits commit sha
    commits=$(curl -fsSL "https://api.github.com/repos/pytorch/pytorch/commits?path=.ci/docker&per_page=10" \
        | python3 -c 'import json,sys; [print(c["sha"]) for c in json.load(sys.stdin)]')
    for commit in $commits; do
        sha=$(curl -fsSL "https://api.github.com/repos/pytorch/pytorch/contents/.ci?ref=${commit}" \
            | python3 -c 'import json,sys; print(next(x["sha"] for x in json.load(sys.stdin) if x["name"]=="docker"))')
        echo "trying ${sha} (from commit ${commit:0:12})" >&2
        if docker manifest inspect "${REPO}:${TAG_PREFIX}-${sha}" >/dev/null 2>&1; then
            echo "${sha}"
            return 0
        fi
    done
    echo "no published image found in last 10 commits touching .ci/docker" >&2
    return 1
}

HASH=${HASH:-$(resolve_hash)}
DATE=$(date +%Y%m%d)
TAG="jeffdaily/pytorch:noble-rocm-7.2-py3-${DATE}"

echo "HASH=${HASH}"
echo "TAG=${TAG}"
docker build . --build-arg HASH="${HASH}" -t "${TAG}"
