#!bin/bash
set -e
this_dir="$(dirname "$0")"
echo 'Preload ion alpha on a old commit'
sh $this_dir/preload_local_alpha.sh

echo 'Run alpha integration 1 scripts'
sh $this_dir/run_alpha1.sh
