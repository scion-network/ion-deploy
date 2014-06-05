#!bin/bash
set -e
set -v
thisdir="$(dirname "$0")"

# MASTER paths
#preload_path="https://docs.google.com/spreadsheet/pub?key=0AttCeOvLP6XMdG82NHZfSEJJOGdQTkgzb05aRjkzMEE&output=xls"
#assetmappings_path="https://docs.google.com/spreadsheet/pub?key=0AttCeOvLP6XMdFVUeDdoUTU0b0NFQ1dCVDhuUjY0THc&output=xls"

# Copy of master
preload_path="https://docs.google.com/spreadsheet/pub?key=0ArzZOLNhEGVqdFpPMVd6Y1BkNmpLbjhNdXBVNElidGc&output=xls"
assetmappings_path="https://docs.google.com/spreadsheet/pub?key=0ArzZOLNhEGVqdDRuOEFIcWJyNDdGYTl4RzhHdXRtTHc&output=xls"

rm -f /tmp/preload.xlsx
rm -f /tmp/assetmappings.xlsx
curl -o /tmp/preload.xlsx $preload_path
curl -o /tmp/assetmappings.xlsx $assetmappings_path

echo 'Clean sites on CP01CNSM'
bin/pycc -x ion.agents.agentctrl.AgentControl recurse=True preload_id="CP01CNSM" op=delete_site

echo 'Clean instruments on CP01CNSM_PD'
bin/pycc -x ion.agents.agentctrl.AgentControl recurse=True preload_id="CP01CNSM_PD" op=delete_all_device force=True

echo 'Change the availability state for CP02PMUO-WP001_PD_CL1,CP02PMUI-WP001_PD_CL1'
bin/pycc -x ion.agents.agentctrl.AgentControl op=set_availability preload_id="CP02PMUO-WP001_PD_CL1,CP02PMUI-WP001_PD_CL1" recurse=True availability=AVAILABLE

echo 'Setting lcs state to INTEGRATED for CP05MOAS-GL004 to GL012 gliders and CE05MOAS-GL004 to GL012 gliders'
bin/pycc -x ion.agents.agentctrl.AgentControl op=set_lcstate preload_id="CE05MOAS-GL004_PD,CE05MOAS-GL005_PD,CE05MOAS-GL006_PD,CE05MOAS-GL007_PD,CE05MOAS-GL008_PD,CE05MOAS-GL009_PD,CE05MOAS-GL010_PD,CE05MOAS-GL011_PD,CE05MOAS-GL012_PD,CP05MOAS-GL004_PD,CP05MOAS-GL005_PD,CP05MOAS-GL006_PD,CP05MOAS-GL007_PD,CP05MOAS-GL008_PD,CP05MOAS-GL009_PD,CP05MOAS-GL010_PD,CP05MOAS-GL011_PD,CP05MOAS-GL012_PD" recurse=True lcstate=INTEGRATED

echo 'Setting serial numbers for CP05MOAS-GL001 to GL012 gliders and CE05MOAS-GL001 to GL012 gliders'
bin/pycc -x ion.agents.agentctrl.AgentControl op=set_attributes preload_id="CE05MOAS-GL001_PD,CE05MOAS-GL002_PD,CE05MOAS-GL003_PD,CE05MOAS-GL004_PD,CE05MOAS-GL005_PD,CE05MOAS-GL006_PD,CE05MOAS-GL007_PD,CE05MOAS-GL008_PD,CE05MOAS-GL009_PD,CE05MOAS-GL010_PD,CE05MOAS-GL011_PD,CE05MOAS-GL012_PD,CP05MOAS-GL001_PD,CP05MOAS-GL002_PD,CP05MOAS-GL003_PD,CP05MOAS-GL004_PD,CP05MOAS-GL005_PD,CP05MOAS-GL006_PD,CP05MOAS-GL007_PD,CP05MOAS-GL008_PD,CP05MOAS-GL009_PD,CP05MOAS-GL010_PD,CP05MOAS-GL011_PD,CP05MOAS-GL012_PD" recurse=True cfg=$thisdir/serial_numbers.csv

echo 'Running OOI incremental preload to update names for devices etc with serial numbers and generate new data products'
bin/pycc -x ion.processes.bootstrap.ion_loader.IONLoader op=load loadooi=True path=/tmp/preload.xlsx assetmappings=/tmp/assetmappings.xlsx ooiuntil="6/30/2014" ooiparams=True ooiupdate=True

