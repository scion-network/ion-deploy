#!bin/bash
set -e
set -x
this_dir="$(dirname "$0")"

echo 'Run below steps on an old commit'
echo 'Run bin/pycc --rel res/deploy/r2deploy.yml -fc'

sh $this_dir/preload_local_beta.sh

echo 'Now change to a new commit before next script'
