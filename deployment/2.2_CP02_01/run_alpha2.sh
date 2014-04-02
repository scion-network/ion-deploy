#!bin/bash
set -e
set -v
thisdir="$(dirname "$0")"

echo 'Stop agents for 6 sites'
bin/pycc -x ion.agents.agentctrl.AgentControl force=True recurse=True preload_id="CP02PMUI-WF001_PD,CP02PMUO-WF001_PD,CP02PMCI-WF001_PD,CP02PMCO-WF001_PD,CE09OSPM-WF001_PD,CP04OSPM-WF001_PD" op=stop

echo 'Deactivate persistence for 6 sites'
bin/pycc -x ion.agents.agentctrl.AgentControl force=True recurse=True preload_id="CP02PMUI-WF001_PD,CP02PMUO-WF001_PD,CP02PMCI-WF001_PD,CP02PMCO-WF001_PD,CE09OSPM-WF001_PD,CP04OSPM-WF001_PD" op=suspend_persistence

echo 'Remove resources and coverage and agent state for 6 WP and 6 WF sites'
bin/pycc -x ion.agents.agentctrl.AgentControl force=True recurse=True preload_id="CP02PMUI-WP001_PD,CP02PMUO-WP001_PD,CP02PMCI-WP001_PD,CP02PMCO-WP001_PD,CE09OSPM-WP001_PD,CP04OSPM-WP001_PD,CP02PMUI-WF001_PD,CP02PMUO-WF001_PD,CP02PMCI-WF001_PD,CP02PMCO-WF001_PD,CE09OSPM-WF001_PD,CP04OSPM-WF001_PD" op=delete_all_site

# MASTER paths

rm -f /tmp/preload.xlsx
rm -f /tmp/assetmappings.xlsx
preload_path="https://docs.google.com/spreadsheet/pub?key=0AttCeOvLP6XMdG82NHZfSEJJOGdQTkgzb05aRjkzMEE&output=xls"
curl -o /tmp/preload.xlsx $preload_path
assetmappings_path="https://docs.google.com/spreadsheet/pub?key=0AttCeOvLP6XMdFVUeDdoUTU0b0NFQ1dCVDhuUjY0THc&output=xls"
curl -o /tmp/assetmappings.xlsx $assetmappings_path

echo 'Run inc preload 1'
bin/pycc -x ion.processes.bootstrap.ion_loader.IONLoader cfg=$thisdir/ooi_inc_preload.yml path=/tmp/preload.xlsx assetmappings=/tmp/assetmappings.xlsx

echo 'run calibration for 4 instruments and 2 pds'
bin/pycc -x ion.agents.agentctrl.AgentControl force=True preload_id="CP02PMUI-WF001-04-FLORTK999_ID,CP02PMUI-WF001-05-PARADK999_ID,CP02PMUI-WF001_PD,CP02PMUO-WF001-04-FLORTK999_ID,CP02PMUO-WF001-05-PARADK999_ID,CP02PMUO-WF001_PD" op=set_calibration cfg=$thisdir/calibration2.csv

echo 'activate deployment for 4 instruments and 2 pds'
bin/pycc -x ion.agents.agentctrl.AgentControl force=True preload_id="CP02PMUI-WF001-04-FLORTK999_ID,CP02PMUI-WF001-05-PARADK999_ID,CP02PMUI-WF001_PD,CP02PMUO-WF001-04-FLORTK999_ID,CP02PMUO-WF001-05-PARADK999_ID,CP02PMUO-WF001_PD" op=activate_deployment

echo 'configure agent instances for 4 instruments and 2 pds'
bin/pycc -x ion.agents.agentctrl.AgentControl force=True preload_id="CP02PMUI-WF001-04-FLORTK999_ID,CP02PMUI-WF001-05-PARADK999_ID,CP02PMUI-WF001_PD,CP02PMUO-WF001-04-FLORTK999_ID,CP02PMUO-WF001-05-PARADK999_ID,CP02PMUO-WF001_PD" op=config_instance cfg=$thisdir/eai_configs.csv

echo 'Start agents for 4 instruments and 2 pds'
bin/pycc -x ion.agents.agentctrl.AgentControl force=True preload_id="CP02PMUI-WF001-04-FLORTK999_ID,CP02PMUI-WF001-05-PARADK999_ID,CP02PMUI-WF001_PD,CP02PMUO-WF001-04-FLORTK999_ID,CP02PMUO-WF001-05-PARADK999_ID,CP02PMUO-WF001_PD" op=start
