#!/bin/bash
set -e
set -x
this_dir="$(dirname "$0")"

bin/pycc -x ion.agents.agentctrl.AgentControl platform='Wire-Following Profiler Mooring - Coastal Pioneer Upstream Inshore'  recurse=True op=start

bin/pycc -x ion.agents.agentctrl.AgentControl platform='Wire-Following Profiler Mooring - Coastal Pioneer Upstream Offshore' recurse=True op=start

bin/pycc -x ion.agents.agentctrl.AgentControl platform='Wire-Following Profiler Mooring - Coastal Pioneer Central Inshore' recurse=True op=start

bin/pycc -x ion.agents.agentctrl.AgentControl platform='Wire-Following Profiler Mooring - Coastal Pioneer Central Offshore' recurse=True op=start

echo 'Script Completed'
