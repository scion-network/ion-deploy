#!bin/bash
set -e
set -v
thisdir="$(dirname "$0")"

echo 'Set turned devices to INTEGRATED state'
bin/pycc -x ion.agents.agentctrl.AgentControl op=set_lcstate  lcstate=INTEGRATED preload_id="CP02PMUO-WP001_PD,CP02PMUI-WP001_PD" recurse=True verbose=True

echo 'Set cloned devices to DEPLOYED state'
bin/pycc -x ion.agents.agentctrl.AgentControl op=set_lcstate  lcstate=DEPLOYED preload_id="CP02PMUO-WP001_PD_CL1,CP02PMUI-WP001_PD_CL1" recurse=True verbose=True
