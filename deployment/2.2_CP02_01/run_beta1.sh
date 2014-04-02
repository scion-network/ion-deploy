#!bin/bash
set -e
set -v
thisdir="$(dirname "$0")"

echo 'Stop agents for 2 sites'
bin/pycc -x ion.agents.agentctrl.AgentControl force=True recurse=True preload_id="CE09OSPM-WF001_PD,CP04OSPM-WF001_PD" op=stop

echo 'Deactivate persistence for 2 sites'
bin/pycc -x ion.agents.agentctrl.AgentControl force=True recurse=True preload_id="CE09OSPM-WF001_PD,CP04OSPM-WF001_PD" op=suspend_persistence

echo 'Run inc preload 1'
bin/pycc -x ion.processes.bootstrap.ion_loader.IONLoader cfg=$thisdir/ooi_inc_preload.yml path=master

echo 'Remove resources and coverage and agent state for 6 WP and 6 WF sites'
bin/pycc -x ion.agents.agentctrl.AgentControl force=True recurse=True preload_id="CP02PMUI-WP001_PD,CP02PMUO-WP001_PD,CP02PMCI-WP001_PD,CP02PMCO-WP001_PD,CE09OSPM-WP001_PD,CP04OSPM-WP001_PD,CP02PMUI-WF001_PD,CP02PMUO-WF001_PD,CP02PMCI-WF001_PD,CP02PMCO-WF001_PD,CE09OSPM-WF001_PD,CP04OSPM-WF001_PD" op=delete_all_site

echo 'Run wfp preload'
bin/pycc -x ion.processes.bootstrap.ion_loader.IONLoader cfg=$thisdir/wfp_preload.yml path=master

echo 'Run inc preload 2'
bin/pycc -x ion.processes.bootstrap.ion_loader.IONLoader cfg=$thisdir/ooi_inc_preload.yml path=master


echo 'run calibration for 4 sites'
bin/pycc -x ion.agents.agentctrl.AgentControl force=True preload_id="CP02PMUI-WF001-04-FLORTK999_ID,CP02PMUI-WF001-05-PARADK999_ID,CP02PMUI-WF001_PD,CP02PMUO-WF001-04-FLORTK999_ID,CP02PMUO-WF001-05-PARADK999_ID,CP02PMUO-WF001_PD" op=set_calibration cfg=$thisdir/calibration2.csv

echo 'activate deployment for 4 sites'
bin/pycc -x ion.agents.agentctrl.AgentControl force=True preload_id="CP02PMUI-WF001-04-FLORTK999_ID,CP02PMUI-WF001-05-PARADK999_ID,CP02PMUI-WF001_PD,CP02PMUO-WF001-04-FLORTK999_ID,CP02PMUO-WF001-05-PARADK999_ID,CP02PMUO-WF001_PD" op=activate_deployment

echo 'configure agent instances for 4 sites'
bin/pycc -x ion.agents.agentctrl.AgentControl force=True preload_id="CP02PMUI-WF001-04-FLORTK999_ID,CP02PMUI-WF001-05-PARADK999_ID,CP02PMUI-WF001_PD,CP02PMUO-WF001-04-FLORTK999_ID,CP02PMUO-WF001-05-PARADK999_ID,CP02PMUO-WF001_PD" op=config_instance cfg=$thisdir/eai_configs.csv

echo 'Start agents for 4 sites'
bin/pycc -x ion.agents.agentctrl.AgentControl force=True preload_id="CP02PMUI-WF001-04-FLORTK999_ID,CP02PMUI-WF001-05-PARADK999_ID,CP02PMUI-WF001_PD,CP02PMUO-WF001-04-FLORTK999_ID,CP02PMUO-WF001-05-PARADK999_ID,CP02PMUO-WF001_PD" op=start
