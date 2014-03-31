#!bin/bash
set -v
set -e
trap 'my_exit; exit' SIGUSR1
count=0
thisdir="$(dirname "$0")"

echo 'Run below steps on an old commit'
git fetch origin
yes | git checkout v2.2.2
git submodule update
ant clean
bin/generate_interfaces

echo 'Start r2 deploy in no shell mode with signaling to parent'
bin/pycc -sp -n --rel res/deploy/r2deploy.yml -fc &
r2deploy_pid=$!

my_exit()
{
echo $r2deploy_pid caught
echo 'Preload ion alpha'
bin/pycc -x ion.processes.bootstrap.ion_loader.IONLoader cfg=res/preload/r2_ioc/config/ooi_alpha.yml path="https://docs.google.com/spreadsheet/pub?key=0Aq_8oD79eIi4dHpTOGV2bGZVNkJXd0J1ci1SX25zNXc&output=xls" assetmappings="https://docs.google.com/spreadsheet/pub?key=0ArzZOLNhEGVqdHA2MHNSX1dlT2ZTaHVrNVJzOG4xZnc&output=xls"

echo 'Run alpha integration 1 scripts...This is just an approximation'
sh $thisdir/run_alpha1.sh

sleep 5
echo 'Kill the r2 deploy'

kill -s INT $r2deploy_pid

sleep 5
echo 'Run below steps with a new commit'
git checkout REL2.0
yes | git checkout origin/REL2.0
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
