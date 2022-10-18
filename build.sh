#!/usr/bin/env bash
set -o errexit; set -o errtrace; set -o nounset; set -o pipefail; set -o xtrace;
cd "$(dirname "$0")"
set -a
source variables.sh
set +a
find . -name '*.sh' -type f -exec chmod 0755 {} \;
# Update Dockerfile
cp template/Dockerfile .
sed -i.bak "s|\$SOURCE_REPO|$SOURCE_REPO|" Dockerfile
sed -i.bak "s|\$IMAGE_TAG|$IMAGE_TAG|" Dockerfile
sed -i.bak "s|\$USER|$USER|" Dockerfile
# Run container build jobs
docker build \
  --build-arg DRIVERS="$DRIVERS" \
  --build-arg OS_TYPE="$OS_TYPE" \
  --tag "$TARGET_REPO:$IMAGE_TAG" \
  --no-cache \
  --progress=plain \
  ./
