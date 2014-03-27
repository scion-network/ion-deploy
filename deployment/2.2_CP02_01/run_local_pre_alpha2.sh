#!bin/bash
set -e
set -x
this_dir="$(dirname "$0")"

echo 'Run below steps on an old commit'
echo 'Run manually: bin/pycc --rel res/deploy/r2deploy.yml -fc'

echo 'Preload ion alpha'
sh $this_dir/preload_local_alpha.sh

echo 'Run below steps with a new commit'
echo 'Run bin/pycc --rel res/deploy/r2deploy.yml bootmode=restart'

echo 'Run alpha integration 1 scripts...This is just an approximation'
sh $this_dir/run_alpha1.sh
