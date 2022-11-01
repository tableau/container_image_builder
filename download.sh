#!/usr/bin/env bash
set -o errexit; set -o errtrace; set -o nounset; set -o pipefail; set -o xtrace;
cd "$(dirname "$0")"
set -a
source variables.sh
set +a
./check_variables.sh
find . -name '*.sh' -type f -exec chmod 0755 {} \;
./download/download.sh
