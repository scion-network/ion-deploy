#!/bin/bash
set -e
this_dir="$(dirname "$0")"

bin/pycc -x ion.agents.agentctrl.AgentControl platform='Wire-Following Profiler - Coastal Pioneer Offshore' op=stop recurse=True

bin/pycc -x ion.agents.agentctrl.AgentControl platform='Wire-Following Profiler - Coastal Endurance Washington Offshore' op=stop recurse=True

bin/pycc -x ion.agents.agentctrl.AgentControl platform='Wire-Following Profiler - Coastal Pioneer Upstream Inshore' op=stop recurse=True

bin/pycc -x ion.agents.agentctrl.AgentControl platform='Wire-Following Profiler - Coastal Pioneer Upstream Offshore' op=stop recurse=True


bin/pycc -x ion.agents.agentctrl.AgentControl platform='Wire-Following Profiler - Coastal Pioneer Central Inshore' op=stop recurse=True


bin/pycc -x ion.agents.agentctrl.AgentControl platform='Wire-Following Profiler - Coastal Pioneer Central Offshore' op=stop recurse=True

echo 'Script Completed'
