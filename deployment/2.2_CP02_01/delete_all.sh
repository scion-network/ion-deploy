#!/bin/bash
#set -e
set -x 
this_dir="$(dirname "$0")"

bin/pycc -x ion.agents.agentctrl.AgentControl platform='Wire-Following Profiler - Coastal Pioneer Offshore' op=delete_all_site recurse=True

bin/pycc -x ion.agents.agentctrl.AgentControl platform='Wire-Following Profiler - Coastal Endurance Washington Offshore' op=delete_all_site recurse=True

bin/pycc -x ion.agents.agentctrl.AgentControl platform='Wire-Following Profiler - Coastal Pioneer Upstream Inshore' op=delete_all_site recurse=True

bin/pycc -x ion.agents.agentctrl.AgentControl platform='Wire-Following Profiler - Coastal Pioneer Upstream Offshore' op=delete_all_site recurse=True

bin/pycc -x ion.agents.agentctrl.AgentControl platform='Wire-Following Profiler - Coastal Pioneer Central Inshore' op=delete_all_site recurse=True

bin/pycc -x ion.agents.agentctrl.AgentControl platform='Wire-Following Profiler - Coastal Pioneer Central Offshore' op=delete_all_site recurse=True

echo 'Script Completed'
