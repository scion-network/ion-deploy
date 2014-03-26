#!bin/bash
set -e
this_dir="$(dirname "$0")"

echo 'Preload ion beta in an old commit'
sh $this_dir/preload_local_beta.sh
