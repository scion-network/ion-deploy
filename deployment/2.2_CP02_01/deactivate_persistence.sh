#!/bin/bash
set -e
set -x
this_dir="$(dirname "$0")"

bin/pycc -x ion.agents.agentctrl.AgentControl platform='Wire-Following Profiler - Coastal Pioneer Offshore' op=suspend_persistence recurse=True

bin/pycc -x ion.agents.agentctrl.AgentControl platform='Wire-Following Profiler - Coastal Endurance Washington Offshore' op=suspend_persistence recurse=True

bin/pycc -x ion.agents.agentctrl.AgentControl platform='Wire-Following Profiler - Coastal Pioneer Upstream Inshore' op=suspend_persistence recurse=True

bin/pycc -x ion.agents.agentctrl.AgentControl platform='Wire-Following Profiler - Coastal Pioneer Upstream Offshore' op=suspend_persistence recurse=True

bin/pycc -x ion.agents.agentctrl.AgentControl platform='Wire-Following Profiler - Coastal Pioneer Central Inshore' op=suspend_persistence recurse=True

bin/pycc -x ion.agents.agentctrl.AgentControl platform='Wire-Following Profiler - Coastal Pioneer Central Offshore' op=suspend_persistence recurse=True

echo 'Script Completed'
