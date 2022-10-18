#!/usr/bin/env bash
set -o errexit; set -o errtrace; set -o nounset; set -o pipefail; set -o xtrace;
cd "$(dirname "$0")"
source_path="$(pwd)/$OS_TYPE.sh"
source "$source_path"
files_dir=$(realpath ../../build/drivers/files)
mkdir -p "$files_dir"
files_dir="$files_dir/$OS_TYPE"
if [ -d "$files_dir" ]; then
  echo "The directory '$files_dir' already exists therefore skip host/drivers job"
  exit 0
fi
mkdir -p "$files_dir/tmp"
cd "$files_dir"
for i in ${DRIVERS//,/ }; do
  eval "$i"
done
