#!/bin/bash
set -v

# MASTER paths
# preload_path="https://docs.google.com/spreadsheet/pub?key=0AttCeOvLP6XMdG82NHZfSEJJOGdQTkgzb05aRjkzMEE&output=xls"
# assetmappings_path="https://docs.google.com/spreadsheet/pub?key=0AttCeOvLP6XMdFVUeDdoUTU0b0NFQ1dCVDhuUjY0THc&output=xls"

# Pinned paths
preload_path="https://docs.google.com/spreadsheet/pub?key=0Aq_8oD79eIi4dHpTOGV2bGZVNkJXd0J1ci1SX25zNXc&output=xls"
assetmappings_path="https://docs.google.com/spreadsheet/pub?key=0ArzZOLNhEGVqdHA2MHNSX1dlT2ZTaHVrNVJzOG4xZnc&output=xls"

ui_path=""

rm -f $preload_local
rm -f $assetmappings_local
curl -o $preload_local $preload_path
curl -o $assetmappings_local $assetmappings_path

bin/pycc -D -x ion.processes.bootstrap.ion_loader.IONLoader $ui_path assets=res/preload/r2_ioc/ooi_assets cfg=res/preload/r2_ioc/config/ooi_alpha.yml path=$preload_local assetmappings=$assetmappings_local
