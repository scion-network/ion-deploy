#!bin/bash
set -v

# MASTER paths
preload_path="https://docs.google.com/spreadsheet/pub?key=0AttCeOvLP6XMdG82NHZfSEJJOGdQTkgzb05aRjkzMEE&output=xls"
assetmappings_path="https://docs.google.com/spreadsheet/pub?key=0AttCeOvLP6XMdFVUeDdoUTU0b0NFQ1dCVDhuUjY0THc&output=xls"

# Pinned paths
#preload_path="https://docs.google.com/spreadsheet/pub?key=0ArzZOLNhEGVqdDNNZ2pDWENHdmY4bHM1UkU5Mlhpbmc&output=xls"
#assetmappings_path="https://docs.google.com/spreadsheet/pub?key=0AttCeOvLP6XMdHoxSWpva2pIN0UtenBoMmt4ODNFYVE&output=xls"

ui_path="ui_path='https://userexperience.oceanobservatories.org/database-exports/R3Candidates/'"

rm -f /tmp/b3_preload.xlsx
rm -f /tmp/b3_assetmappings.xlsx
curl -o /tmp/b3_preload.xlsx $preload_path
curl -o /tmp/b3_assetmappings.xlsx $assetmappings_path

bin/pycc -D -x ion.processes.bootstrap.ion_loader.IONLoader $ui_path assets=res/preload/r2_ioc/ooi_assets cfg=res/preload/r2_ioc/config/r3_production.yml path=$preload_path assetmappings=$assetmappings
