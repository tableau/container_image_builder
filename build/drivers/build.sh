#!/usr/bin/env bash
set -o errexit; set -o errtrace; set -o nounset; set -o pipefail; set -o xtrace;
cd "$(dirname "$0")"
source_path="$(pwd)/$OS_TYPE.sh"
source "$source_path"
cd "$(pwd)/files/$OS_TYPE"
pre_build
for i in ${DRIVERS//,/ }; do
  eval "$i"
done
post_build
