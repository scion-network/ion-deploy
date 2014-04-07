#!bin/bash
set -e
set -v
thisdir="$(dirname "$0")"

# MASTER paths
preload_path="https://docs.google.com/spreadsheet/pub?key=0AttCeOvLP6XMdG82NHZfSEJJOGdQTkgzb05aRjkzMEE&output=xls"
assetmappings_path="https://docs.google.com/spreadsheet/pub?key=0AttCeOvLP6XMdFVUeDdoUTU0b0NFQ1dCVDhuUjY0THc&output=xls"

# Copy of master
preload_path="https://docs.google.com/spreadsheet/pub?key=0ArzZOLNhEGVqdGptdl8tVk1QdHl0d01oYTY0aGJTMVE&output=xls"
assetmappings_path="https://docs.google.com/spreadsheet/pub?key=0ArzZOLNhEGVqdHpVSmtIUE5UeHNUTVBObmd4WlBmaHc&output=xls"

rm -f /tmp/preload.xlsx
rm -f /tmp/assetmappings.xlsx
curl -o /tmp/preload.xlsx $preload_path
curl -o /tmp/assetmappings.xlsx $assetmappings_path

echo 'Stop agents for 6 WP PDs and 6 WF PDs'
bin/pycc -x ion.agents.agentctrl.AgentControl recurse=True autoclean=True preload_id="CP02PMUI-WP001_PD,CP02PMUO-WP001_PD,CP02PMCI-WP001_PD,CP02PMCO-WP001_PD,CE09OSPM-WP001_PD,CP04OSPM-WP001_PD,CP02PMUI-WF001_PD,CP02PMUO-WF001_PD,CP02PMCI-WF001_PD,CP02PMCO-WF001_PD,CE09OSPM-WF001_PD,CP04OSPM-WF001_PD" op=stop

echo 'Deactivate persistence for 6 WP PDs and 6 WF PDs'
bin/pycc -x ion.agents.agentctrl.AgentControl recurse=True autoclean=True preload_id="CP02PMUI-WP001_PD,CP02PMUO-WP001_PD,CP02PMCI-WP001_PD,CP02PMCO-WP001_PD,CE09OSPM-WP001_PD,CP04OSPM-WP001_PD,CP02PMUI-WF001_PD,CP02PMUO-WF001_PD,CP02PMCI-WF001_PD,CP02PMCO-WF001_PD,CE09OSPM-WF001_PD,CP04OSPM-WF001_PD" op=suspend_persistence

echo 'Remove resources and coverage and agent state for 6 WP PDs and 6 WF PDs'
bin/pycc -x ion.agents.agentctrl.AgentControl recurse=True preload_id="CP02PMUI-WP001_PD,CP02PMUO-WP001_PD,CP02PMCI-WP001_PD,CP02PMCO-WP001_PD,CE09OSPM-WP001_PD,CP04OSPM-WP001_PD,CP02PMUI-WF001_PD,CP02PMUO-WF001_PD,CP02PMCI-WF001_PD,CP02PMCO-WF001_PD,CE09OSPM-WF001_PD,CP04OSPM-WF001_PD" op=delete_all_device

echo 'Remove resources for 6 WP and 6 WF sites'
bin/pycc -x ion.agents.agentctrl.AgentControl recurse=True preload_id="CP02PMUI-WP001,CP02PMUO-WP001,CP02PMCI-WP001,CP02PMCO-WP001,CE09OSPM-WP001,CP04OSPM-WP001,CP02PMUI-WF001,CP02PMUO-WF001,CP02PMCI-WF001,CP02PMCO-WF001,CE09OSPM-WF001,CP04OSPM-WF001" op=delete_site


echo 'Run OOI preload incrementally - this will fill in the gaps after the deletions and create DataProducts for new agent definitions'
bin/pycc -x ion.processes.bootstrap.ion_loader.IONLoader cfg=$thisdir/ooi_inc_preload.yml path=/tmp/preload.xlsx assetmappings=/tmp/assetmappings.xlsx


echo 'Run calibration for 4 instruments and 2 platforms'
bin/pycc -x ion.agents.agentctrl.AgentControl preload_id="CP02PMUI-WF001-04-FLORTK999_ID,CP02PMUI-WF001-05-PARADK999_ID,CP02PMUI-WF001_PD,CP02PMUO-WF001-04-FLORTK999_ID,CP02PMUO-WF001-05-PARADK999_ID,CP02PMUO-WF001_PD" op=set_calibration cfg=$thisdir/calibration2.csv

echo 'Configure agent instances for 4 instruments and 2 platforms'
bin/pycc -x ion.agents.agentctrl.AgentControl preload_id="CP02PMUI-WF001-04-FLORTK999_ID,CP02PMUI-WF001-05-PARADK999_ID,CP02PMUI-WF001_PD,CP02PMUO-WF001-04-FLORTK999_ID,CP02PMUO-WF001-05-PARADK999_ID,CP02PMUO-WF001_PD" op=config_instance cfg=$thisdir/eai_configs.csv

echo 'Start agents for 4 instruments and 2 platforms'
bin/pycc -x ion.agents.agentctrl.AgentControl preload_id="CP02PMUI-WF001-04-FLORTK999_ID,CP02PMUI-WF001-05-PARADK999_ID,CP02PMUI-WF001_PD,CP02PMUO-WF001-04-FLORTK999_ID,CP02PMUO-WF001-05-PARADK999_ID,CP02PMUO-WF001_PD" op=start

