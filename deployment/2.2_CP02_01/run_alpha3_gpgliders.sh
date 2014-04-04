#!bin/bash
set -e
set -v
thisdir="$(dirname "$0")"

# MASTER paths
preload_path="https://docs.google.com/spreadsheet/pub?key=0AttCeOvLP6XMdG82NHZfSEJJOGdQTkgzb05aRjkzMEE&output=xls"
assetmappings_path="https://docs.google.com/spreadsheet/pub?key=0AttCeOvLP6XMdFVUeDdoUTU0b0NFQ1dCVDhuUjY0THc&output=xls"

rm -f /tmp/preload.xlsx
rm -f /tmp/assetmappings.xlsx
curl -o /tmp/preload.xlsx $preload_path
curl -o /tmp/assetmappings.xlsx $assetmappings_path

echo 'Stop agents for 3 GP05 glider platform devices recursively'
bin/pycc -x ion.agents.agentctrl.AgentControl recurse=True autoclean=True preload_id="GP05MOAS-GL001_PD,GP05MOAS-GL002_PD,GP05MOAS-GL003_PD" op=stop

echo 'Deactivate persistence for 3 GP05 glider platform devices recursively'
bin/pycc -x ion.agents.agentctrl.AgentControl recurse=True autoclean=True preload_id="GP05MOAS-GL001_PD,GP05MOAS-GL002_PD,GP05MOAS-GL003_PD" op=suspend_persistence

echo 'Remove resources and coverage and agent state for 3 GP05 glider platform devices recursively'
bin/pycc -x ion.agents.agentctrl.AgentControl recurse=True preload_id="GP05MOAS-GL001_PD,GP05MOAS-GL002_PD,GP05MOAS-GL003_PD" op=delete_all_device

echo 'Remove resources for 3 GP05 glider platform sites recursively'
bin/pycc -x ion.agents.agentctrl.AgentControl recurse=True preload_id="GP05MOAS-GL001,GP05MOAS-GL002,GP05MOAS-GL003"" op=delete_site

echo 'Run OOI preload incrementally - this will fill in the gaps after the deletions and create DataProducts for new agent definitions'
bin/pycc -x ion.processes.bootstrap.ion_loader.IONLoader cfg=$thisdir/ooi_inc_preload.yml path=/tmp/preload.xlsx assetmappings=/tmp/assetmappings.xlsx

echo 'Configure agent instances for 3 GP05 glider platform devices'
bin/pycc -x ion.agents.agentctrl.AgentControl preload_id="GP05MOAS-GL001_PD,GP05MOAS-GL002_PD,GP05MOAS-GL003_PD" op=config_instance cfg=$thisdir/eai_configs.csv

echo 'Start agents for 3 GP05 glider platform devices'
bin/pycc -x ion.agents.agentctrl.AgentControl preload_id="GP05MOAS-GL001_PD,GP05MOAS-GL002_PD,GP05MOAS-GL003_PD" op=start

