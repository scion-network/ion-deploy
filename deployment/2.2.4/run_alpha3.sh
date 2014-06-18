#!bin/bash
set -e
set -v
thisdir="$(dirname "$0")"

echo 'Change attribute for a parameter def'
bin/pycc -x ion.agents.agentctrl.AgentControl op=set_attributes preload_id="PD1527" cfg=$thisdir/parameter_defs.csv verbose=True
