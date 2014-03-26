#!/bin/bash
set -e
set -x
this_dir="$(dirname "$0")"

echo bin/pycc -x ion.agents.agentctrl.AgentControl platform='Wire-Following Profiler Mooring - Coastal Pioneer Upstream Inshore'  recurse=True op=set_calibration cfg=$thisdir/calibration2.csv
bin/pycc -x ion.agents.agentctrl.AgentControl platform='Wire-Following Profiler Mooring - Coastal Pioneer Upstream Inshore'  recurse=True op=set_calibration cfg=$thisdir/calibration2.csv

echo bin/pycc -x ion.agents.agentctrl.AgentControl platform='Wire-Following Profiler Mooring - Coastal Pioneer Upstream Offshore' recurse=True op=set_calibration cfg=$thisdir/calibration2.csv
bin/pycc -x ion.agents.agentctrl.AgentControl platform='Wire-Following Profiler Mooring - Coastal Pioneer Upstream Offshore' recurse=True op=set_calibration cfg=$thisdir/calibration2.csv

echo bin/pycc -x ion.agents.agentctrl.AgentControl platform='Wire-Following Profiler Mooring - Coastal Pioneer Central Inshore' recurse=True op=set_calibration cfg=$thisdir/calibration2.csv 
bin/pycc -x ion.agents.agentctrl.AgentControl platform='Wire-Following Profiler Mooring - Coastal Pioneer Central Inshore' recurse=True op=set_calibration cfg=$thisdir/calibration2.csv 

echo bin/pycc -x ion.agents.agentctrl.AgentControl platform='Wire-Following Profiler Mooring - Coastal Pioneer Central Offshore' recurse=True op=set_calibration cfg=$thisdir/calibration2.csv
bin/pycc -x ion.agents.agentctrl.AgentControl platform='Wire-Following Profiler Mooring - Coastal Pioneer Central Offshore' recurse=True op=set_calibration cfg=$thisdir/calibration2.csv

echo 'Script Completed'
