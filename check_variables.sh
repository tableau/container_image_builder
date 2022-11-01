#!/usr/bin/env bash
set -o errexit; set -o errtrace; set -o nounset; set -o pipefail; set -o xtrace;
: "${OS_TYPE:?OS_TYPE is required}"
: "${SOURCE_REPO:?SOURCE_REPO is required}"
: "${TARGET_REPO:?TARGET_REPO is required}"
: "${IMAGE_TAG:?IMAGE_TAG is required}"
: "${USER:?USER is required}"
