#!/usr/bin/env bash
set -o errexit; set -o errtrace; set -o nounset; set -o pipefail; set -o xtrace;
cd "$(dirname "$0")"
set -a
source variables.sh
set +a
./check_variables.sh
name=test_image
# Run container test jobs
docker container kill $name ||:
docker container rm $name ||:
docker container run \
  --detach \
  --name $name \
  --volume "$(pwd)/test:/test" \
  --env DRIVERS="$DRIVERS" \
  --env OS_TYPE="$OS_TYPE" \
  "$TARGET_REPO:$IMAGE_TAG" \
  sleep infinity
docker container exec \
  $name \
  /test/test.sh
