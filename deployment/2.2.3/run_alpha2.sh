#!bin/bash
set -e
set -v
thisdir="$(dirname "$0")"

# MASTER paths
#preload_path="https://docs.google.com/spreadsheet/pub?key=0AttCeOvLP6XMdG82NHZfSEJJOGdQTkgzb05aRjkzMEE&output=xls"
#assetmappings_path="https://docs.google.com/spreadsheet/pub?key=0AttCeOvLP6XMdFVUeDdoUTU0b0NFQ1dCVDhuUjY0THc&output=xls"

# Copy of master
preload_path="https://docs.google.com/spreadsheet/pub?key=0ArzZOLNhEGVqdEhOZ0NNMUtaUjFiam01Wno0TlVwaWc&output=xls"
assetmappings_path="https://docs.google.com/spreadsheet/pub?key=0ArzZOLNhEGVqdEpVRjBxS2U2akVMOUkxS0dQLURDaFE&output=xls"

rm -f /tmp/preload.xlsx
rm -f /tmp/assetmappings.xlsx
curl -o /tmp/preload.xlsx $preload_path
curl -o /tmp/assetmappings.xlsx $assetmappings_path

echo 'Running OOI incremental preload to update names for devices and data products using NEW preload spreadsheet'
bin/pycc -x ion.processes.bootstrap.ion_loader.IONLoader op=load loadooi=True path=/tmp/preload.xlsx assetmappings=/tmp/assetmappings.xlsx ooiuntil="6/30/2014" ooiparams=True ooiupdate=True

