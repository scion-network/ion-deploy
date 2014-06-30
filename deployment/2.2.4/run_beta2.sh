#!bin/bash
set -e
set -v
thisdir="$(dirname "$0")"

echo 'stop agents'
#2.2.1
bin/pycc -x ion.agents.agentctrl.AgentControl op=stop preload_id="CP02PMUO-WP001_PD,CP02PMUI-WP001_PD" recurse=True verbose=True
#2.2.2
bin/pycc -x ion.agents.agentctrl.AgentControl preload_id="CP02PMCI-WP001_PD,CP02PMCO-WP001_PD,CE09OSPM-WP001_PD,CP04OSPM-WP001_PD" recurse=True op=stop
#2.2.3
bin/pycc -x ion.agents.agentctrl.AgentControl op=stop preload_id="CP02PMUO-WP001_PD_CL1,CP02PMUI-WP001_PD_CL1" recurse=True verbose=True
#2.2.4
bin/pycc -x ion.agents.agentctrl.AgentControl op=stop preload_id="CE05MOAS-GL001_PD,CE05MOAS-GL002_PD,CE05MOAS-GL003_PD,CP05MOAS-GL001_PD,CP05MOAS-GL002_PD,CP05MOAS-GL003_PD" recurse=True verbose=True

echo 'reconfigure agents'
#2.2.1
bin/pycc -x ion.agents.agentctrl.AgentControl op=config_instance preload_id="CP02PMUO-WP001_PD,CP02PMUI-WP001_PD" recurse=True verbose=True cfg=$thisdir/eai_mopak_configs.csv
#2.2.2
bin/pycc -x ion.agents.agentctrl.AgentControl preload_id="CP02PMCI-WP001_PD,CP02PMCO-WP001_PD,CE09OSPM-WP001_PD,CP04OSPM-WP001_PD" recurse=True op=config_instance cfg=$thisdir/eai_mopak_configs.csv
#2.2.3
bin/pycc -x ion.agents.agentctrl.AgentControl op=config_instance preload_id="CP02PMUO-WP001_PD_CL1,CP02PMUI-WP001_PD_CL1" recurse=True verbose=True cfg=$thisdir/eai_mopak_configs.csv
#2.2.4
bin/pycc -x ion.agents.agentctrl.AgentControl op=config_instance preload_id="CE05MOAS-GL001_PD,CE05MOAS-GL002_PD,CE05MOAS-GL003_PD,CP05MOAS-GL001_PD,CP05MOAS-GL002_PD,CP05MOAS-GL003_PD" recurse=True verbose=True cfg=$thisdir/eai_mopak_configs.csv

echo 'start agents'
#2.2.1
bin/pycc -x ion.agents.agentctrl.AgentControl op=start preload_id="CP02PMUO-WP001_PD,CP02PMUI-WP001_PD" recurse=True verbose=True
#2.2.2
bin/pycc -x ion.agents.agentctrl.AgentControl preload_id="CP02PMCI-WP001_PD,CP02PMCO-WP001_PD,CE09OSPM-WP001_PD,CP04OSPM-WP001_PD" recurse=True op=start
#2.2.3
bin/pycc -x ion.agents.agentctrl.AgentControl op=start preload_id="CP02PMUO-WP001_PD_CL1,CP02PMUI-WP001_PD_CL1" recurse=True verbose=True
#2.2.4
bin/pycc -x ion.agents.agentctrl.AgentControl op=start preload_id="CE05MOAS-GL001_PD,CE05MOAS-GL002_PD,CE05MOAS-GL003_PD,CP05MOAS-GL001_PD,CP05MOAS-GL002_PD,CP05MOAS-GL003_PD" recurse=True verbose=True
