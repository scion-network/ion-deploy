#!bin/bash
set -e
set -v
trap 'my_exit; exit' SIGUSR1
count=0
this_dir="$(dirname "$0")"

echo 'Run below steps on an old commit'
git fetch origin
git checkout v2.1.2
git submodule update
ant clean
bin/generate_interfaces

echo 'Start r2 deploy in no shell mode with signaling to parent'
bin/pycc -sp -n --rel res/deploy/r2deploy.yml -fc &
r2deploy_pid=$!

my_exit()
{
echo $r2deploy_pid caught
echo 'Preload local beta'
bin/pycc -x ion.processes.bootstrap.ion_loader.IONLoader cfg=res/preload/r2_ioc/config/ooi_beta.yml path="https://docs.google.com/spreadsheet/pub?key=0ArzZOLNhEGVqdE5zaGhGS3Q2ZFhoRk1rSlpsaXBULXc&output=xls" assetmappings="https://docs.google.com/spreadsheet/pub?key=0ArzZOLNhEGVqdHA2MHNSX1dlT2ZTaHVrNVJzOG4xZnc&output=xls"


sleep 5
echo 'Kill the r2 deploy'
kill $r2deploy_pid

echo 'Now manually change to a new commit before running next step'
git checkout REL2.0
git checkout origin/REL2.0
git submodule update
ant clean
bin/generate_interfaces

bin/pycc --rel  res/deploy/r2deploy.yml bootmode=restart --mx
}

while :
do
    sleep 5
    count=$(expr $count + 1)
    echo $count
done
