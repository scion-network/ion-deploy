#!bin/bash
set -e
set -v
this_dir="$(dirname "$0")"

echo 'Stop agents for 2 sites'
bin/pycc -x ion.agents.agentctrl.AgentControl force=True recurse=True preload_id="CE09OSPM-WF001_PD,CP04OSPM-WF001_PD" op=start

echo 'Deactivate persistence for 2 sites'
bin/pycc -x ion.agents.agentctrl.AgentControl force=True recurse=True preload_id="CE09OSPM-WF001_PD,CP04OSPM-WF001_PD" op=suspend_persistence

echo 'Remove resources and coverage and agent state for 2 sites'
bin/pycc -x ion.agents.agentctrl.AgentControl force=True recurse=True preload_id="CE09OSPM-WF001_PD,CP04OSPM-WF001_PD" op=delete_all_site

echo 'Run wfp preload'
bin/pycc -x ion.processes.bootstrap.ion_loader.IONLoader cfg=$this_dir/wfp_preload.yml

echo 'run calibration for 4 sites'
bin/pycc -x ion.agents.agentctrl.AgentControl force=True recurse=True preload_id="CP02PMUI-WP001_PD,CP02PMUO-WP001_PD,CP02PMCI-WP001_PD,CP02PMCO-WP001_PD" op=set_calibration cfg=$thisdir/calibration2.csv

echo 'activate deployment for 4 sites'
bin/pycc -x ion.agents.agentctrl.AgentControl force=True recurse=True preload_id="CP02PMUI-WP001_PD,CP02PMUO-WP001_PD,CP02PMCI-WP001_PD,CP02PMCO-WP001_PD" op=activate_deployment

echo 'configure agent instances for 4 sites'
bin/pycc -x ion.agents.agentctrl.AgentControl force=True recurse=True preload_id="CP02PMUI-WP001_PD,CP02PMUO-WP001_PD,CP02PMCI-WP001_PD,CP02PMCO-WP001_PD" op=config_instance cfg=$thisdir/eai_configs.csv

echo 'Start agents for 4 sites'
bin/pycc -x ion.agents.agentctrl.AgentControl force=True recurse=True preload_id="CP02PMUI-WP001_PD,CP02PMUO-WP001_PD,CP02PMCI-WP001_PD,CP02PMCO-WP001_PD" op=start
