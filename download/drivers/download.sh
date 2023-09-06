#!/usr/bin/env bash
set -o errexit; set -o errtrace; set -o nounset; set -o pipefail; set -o xtrace;
cd "$(dirname "$0")"
source "$(pwd)/$OS_TYPE.sh"
user_path="$(realpath ../user/drivers)/$OS_TYPE.sh"
if [ -f "$user_path" ]; then
  source "$user_path"
fi
files_dir="$(realpath ../../build/drivers)/files"
mkdir -p "$files_dir"
files_dir="$files_dir/$OS_TYPE"
if [ -d "$files_dir" ]; then
  echo "ERROR: The directory already exists, delete it if you want to download the files again: $files_dir"
  exit 1
fi
mkdir -p "$files_dir/tmp"
cd "$files_dir"
for i in ${DRIVERS//,/ }; do
  eval "$i"
done
