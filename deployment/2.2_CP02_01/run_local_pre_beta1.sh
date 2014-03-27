#!bin/bash
set -e
set -x
this_dir="$(dirname "$0")"

echo 'Run below steps on an old commit'
echo 'Run bin/pycc --rel res/deploy/r2deploy.yml -fc'

echo 'Preload local beta'
bin/pycc -x ion.processes.bootstrap.ion_loader.IONLoader cfg=res/preload/r2_ioc/config/ooi_beta.yml path="https://docs.google.com/spreadsheet/pub?key=0Aq_8oD79eIi4dHpTOGV2bGZVNkJXd0J1ci1SX25zNXc&output=xls" assetmappings="https://docs.google.com/spreadsheet/pub?key=0ArzZOLNhEGVqdHA2MHNSX1dlT2ZTaHVrNVJzOG4xZnc&output=xls"

echo 'Now manually change to a new commit before running next step'
echo 'Run bin/pycc --rel res/deploy/r2deploy.yml bootmode=restart --mx'
