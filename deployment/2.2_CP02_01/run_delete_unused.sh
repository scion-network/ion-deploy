#!bin/bash
set -e
set -v
thisdir="$(dirname "$0")"

echo 'Deactivate persistence for 6 CE05 and 6 CP05 unused glider platform devices recursively'
bin/pycc -x ion.agents.agentctrl.AgentControl recurse=True autoclean=True preload_id="CE05MOAS-GL001_PD,CE05MOAS-GL002_PD,CE05MOAS-GL003_PD,CE05MOAS-GL004_PD,CE05MOAS-GL005_PD,CE05MOAS-GL006_PD,CP05MOAS-GL001_PD,CP05MOAS-GL002_PD,CP05MOAS-GL003_PD,CP05MOAS-GL004_PD,CP05MOAS-GL005_PD,CP05MOAS-GL006_PD" op=suspend_persistence

echo 'Remove resources and coverage and agent state for 6 CE05 and 6 CP05 unused glider platform devices recursively'
bin/pycc -x ion.agents.agentctrl.AgentControl recurse=True preload_id="CE05MOAS-GL001_PD,CE05MOAS-GL002_PD,CE05MOAS-GL003_PD,CE05MOAS-GL004_PD,CE05MOAS-GL005_PD,CE05MOAS-GL006_PD,CP05MOAS-GL001_PD,CP05MOAS-GL002_PD,CP05MOAS-GL003_PD,CP05MOAS-GL004_PD,CP05MOAS-GL005_PD,CP05MOAS-GL006_PD" op=delete_all_device

echo 'Remove resources for 6 CE05 and 6 CP05 unused glider platform sites recursively'
bin/pycc -x ion.agents.agentctrl.AgentControl recurse=True preload_id="CE05MOAS-GL001,CE05MOAS-GL002,CE05MOAS-GL003,CE05MOAS-GL004,CE05MOAS-GL005,CE05MOAS-GL006,CP05MOAS-GL001,CP05MOAS-GL002,CP05MOAS-GL003,CP05MOAS-GL004,CP05MOAS-GL005,CP05MOAS-GL006" op=delete_site

