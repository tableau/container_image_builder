#!/usr/bin/env bash
set -o errexit; set -o errtrace; set -o nounset; set -o pipefail; set -o xtrace;
cd "$(dirname "$0")"
source "$(pwd)/$OS_TYPE.sh"
user_path="$(realpath ../user/drivers)/$OS_TYPE.sh"
if [ -f "$user_path" ]; then
  source "$user_path"
fi
cd "$(pwd)/files/$OS_TYPE"
pre_build
for i in ${DRIVERS//,/ }; do
  eval "$i"
done
post_build
