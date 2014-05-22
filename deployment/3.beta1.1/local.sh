#!/bin/bash
set -v
thisdir="$(dirname "$0")"

# MASTER paths
preload_path="https://docs.google.com/spreadsheet/pub?key=0AttCeOvLP6XMdG82NHZfSEJJOGdQTkgzb05aRjkzMEE&output=xls"
assetmappings_path="https://docs.google.com/spreadsheet/pub?key=0AttCeOvLP6XMdFVUeDdoUTU0b0NFQ1dCVDhuUjY0THc&output=xls"

# Copy of master
#preload_path="https://docs.google.com/spreadsheet/pub?key=0ArzZOLNhEGVqdEhOZ0NNMUtaUjFiam01Wno0TlVwaWc&output=xls"
#assetmappings_path="https://docs.google.com/spreadsheet/pub?key=0AlQ93_KBW3ibdEZwRW9LSEJfTHZxTzZselBRMnRUa0E&output=xls"

rm -f /tmp/preload.xlsx
rm -f /tmp/assetmappings.xlsx
curl -o /tmp/preload.xlsx $preload_path
curl -o /tmp/assetmappings.xlsx $assetmappings_path

bin/pycc -x ion.processes.bootstrap.ion_loader.IONLoader cfg=res/preload/r2_ioc/config/r3_production.yml path=/tmp/preload.xlsx assetmappings=/tmp/assetmappings.xlsx
