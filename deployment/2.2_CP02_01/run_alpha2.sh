#!bin/bash
set -e
set -x
this_dir="$(dirname "$0")"

echo 'Stop agents for 6 sites'
bin/pycc -x ion.agents.agentctrl.AgentControl force=True recurse=True preload_id="CP02PMUI-WF001_PD,CP02PMUO-WF001_PD,CP02PMCI-WF001_PD,CP02PMCO-WF001_PD,CE09OSPM-WF001_PD,CP04OSPM-WF001_PD" op=start

echo 'Deactivate persistence for 6 sites'
bin/pycc -x ion.agents.agentctrl.AgentControl force=True recurse=True preload_id="CP02PMUI-WF001_PD,CP02PMUO-WF001_PD,CP02PMCI-WF001_PD,CP02PMCO-WF001_PD,CE09OSPM-WF001_PD,CP04OSPM-WF001_PD" op=suspend_persistence

echo 'Remove resources and coverage and agent state for 6 sites'
bin/pycc -x ion.agents.agentctrl.AgentControl force=True recurse=True preload_id="CP02PMUI-WF001_PD,CP02PMUO-WF001_PD,CP02PMCI-WF001_PD,CP02PMCO-WF001_PD,CE09OSPM-WF001_PD,CP04OSPM-WF001_PD" op=delete_all_site

echo 'Run incremental preload'
bin/pycc -x ion.processes.bootstrap.ion_loader.IONLoader cfg=$this_dir/ooi_inc_preload.yml path="https://docs.google.com/spreadsheet/pub?key=0Aq_8oD79eIi4dElmNnp0SEo4RlYzLVVMWWhHcTdIaGc&output=xls" assetmappings="https://docs.google.com/spreadsheet/pub?key=0Aq_8oD79eIi4dHNzVWJKQkRzbkNZdWZKRDM2Vi1qZHc&output=xls"

echo 'run calibration for 4 sites'
bin/pycc -x ion.agents.agentctrl.AgentControl force=True recurse=True preload_id="CP02PMUI-WP001_PD,CP02PMUO-WP001_PD,CP02PMCI-WP001_PD,CP02PMCO-WP001_PD" op=set_calibration cfg=$thisdir/calibration2.csv

echo 'activate deployment for 4 sites'
bin/pycc -x ion.agents.agentctrl.AgentControl force=True recurse=True preload_id="CP02PMUI-WP001_PD,CP02PMUO-WP001_PD,CP02PMCI-WP001_PD,CP02PMCO-WP001_PD" op=activate_deployment

echo 'configure agent instances for 4 sites'
bin/pycc -x ion.agents.agentctrl.AgentControl force=True recurse=True preload_id="CP02PMUI-WP001_PD,CP02PMUO-WP001_PD,CP02PMCI-WP001_PD,CP02PMCO-WP001_PD" op=config_instance cfg=$thisdir/eai_configs.csv

echo 'Start agents for 4 sites'
bin/pycc -x ion.agents.agentctrl.AgentControl force=True recurse=True preload_id="CP02PMUI-WP001_PD,CP02PMUO-WP001_PD,CP02PMCI-WP001_PD,CP02PMCO-WP001_PD" op=start