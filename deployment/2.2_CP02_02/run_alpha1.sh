#!bin/bash
set -e
set -v
thisdir="$(dirname "$0")"

# MASTER paths
#preload_path="https://docs.google.com/spreadsheet/pub?key=0AttCeOvLP6XMdG82NHZfSEJJOGdQTkgzb05aRjkzMEE&output=xls"
#assetmappings_path="https://docs.google.com/spreadsheet/pub?key=0AttCeOvLP6XMdFVUeDdoUTU0b0NFQ1dCVDhuUjY0THc&output=xls"

# Copy of master
preload_path="https://docs.google.com/spreadsheet/pub?key=0ArzZOLNhEGVqdDNNZ2pDWENHdmY4bHM1UkU5Mlhpbmc&output=xls"
assetmappings_path="https://docs.google.com/spreadsheet/pub?key=0AttCeOvLP6XMdHoxSWpva2pIN0UtenBoMmt4ODNFYVE&output=xls"

rm -f /tmp/preload.xlsx
rm -f /tmp/assetmappings.xlsx
curl -o /tmp/preload.xlsx $preload_path
curl -o /tmp/assetmappings.xlsx $assetmappings_path

echo 'Correct CP02PMUI-0001 PARADK wrong wet calibration factor in previous release'

echo 'stop agent instance'
bin/pycc -x ion.agents.agentctrl.AgentControl recurse=True preload_id="CP02PMUI-WF001-05-PARADK999_ID" op=stop autoclean=True

echo 'suspend persistence'
bin/pycc -x ion.agents.agentctrl.AgentControl recurse=True preload_id="CP02PMUI-WF001-05-PARADK999_ID" op=suspend_persistence autoclean=True

echo 'delete coverage dataset'
bin/pycc -x ion.agents.agentctrl.AgentControl recurse=True preload_id="CP02PMUI-WF001-05-PARADK999_ID" op=delete_dataset

echo 'clear saved state'
bin/pycc -x ion.agents.agentctrl.AgentControl recurse=True preload_id="CP02PMUI-WF001-05-PARADK999_ID" op=clear_saved_state

echo 'run calibration'
bin/pycc -x ion.agents.agentctrl.AgentControl recurse=True preload_id="CP02PMUI-WF001-05-PARADK999_ID" op=set_calibration cfg=$thisdir/calibration.csv

echo 'start persistence'
bin/pycc -x ion.agents.agentctrl.AgentControl recurse=True preload_id="CP02PMUI-WF001-05-PARADK999_ID" op=activate_persistence

if [ "X$1" != "XNORUN" ]; then
echo 'start agent instance'
bin/pycc -x ion.agents.agentctrl.AgentControl recurse=True preload_id="CP02PMUI-WF001-05-PARADK999_ID" op=start
fi

echo 'CE09OSPM-WP001_PD site has SB missing.  Needs to clean up site/device trees and incremental preload again'

echo 'Stop agents'
bin/pycc -x ion.agents.agentctrl.AgentControl recurse=True autoclean=True preload_id="CE09OSPM-WP001_PD" op=stop

echo 'Suspend persistence'
bin/pycc -x ion.agents.agentctrl.AgentControl recurse=True autoclean=True preload_id="CE09OSPM-WP001_PD" op=suspend_persistence

echo 'Clean site and device tree'
bin/pycc -x ion.agents.agentctrl.AgentControl recurse=True preload_id="CE09OSPM-WP001" op=delete_site
bin/pycc -x ion.agents.agentctrl.AgentControl recurse=True preload_id="CE09OSPM-WP001_PD" op=delete_all_device

echo 'Clean up CP02PMUO-RI001-01-ADCPSL999 as it has wrong data products.  We created new agent maps using ADCPSL_CSTL to differentiate from default global deployments that uses a different driver.'

echo 'Run OOI preload incrementally - this will fill in the gaps after the deletions and create DataProducts for new agent definitions'
bin/pycc -x ion.processes.bootstrap.ion_loader.IONLoader op=load loadooi=True path=/tmp/preload.xlsx assetmappings=/tmp/assetmappings.xlsx ooiuntil="6/30/2014" ooiparams=True ooiupdate=True

echo 'Deactivate deployment for CP02PMUO PD'
bin/pycc -x ion.agents.agentctrl.AgentControl preload_id="CP02PMUO-WP001_PD" op=deactivate_deployment

echo 'suspend persistence'
bin/pycc -x ion.agents.agentctrl.AgentControl recurse=True preload_id="CP02PMUO-RI001-01-ADCPSL999_ID" op=suspend_persistence autoclean=True

echo 'Remove resources and coverage and agent state for CP02PMUO-RI001-01-ADCPSL999_ID'
bin/pycc -x ion.agents.agentctrl.AgentControl recurse=True preload_id="CP02PMUO-RI001-01-ADCPSL999_ID" op=delete_all_device

echo 'Remove resources for CP02PMUO-RI001-01-ADCPSL999 site'
bin/pycc -x ion.agents.agentctrl.AgentControl recurse=True preload_id="CP02PMUO-RI001-01-ADCPSL999" op=delete_site

echo 'Run wfp preload for the 5 drivers - this adds new agent definitions and parameters'
bin/pycc -x ion.processes.bootstrap.ion_loader.IONLoader op=load path=/tmp/preload.xlsx assetmappings=/tmp/assetmappings.xlsx scenario=DOFST_K_CSTL,CTDPF_CKL_CSTL,VEL3D_K_CSTL,ADCPSL_CSTL,CG_STC_ENG_CSTL idmap=True categories=ExternalDatasetAgent,ParameterFunctions,ParameterDefs,ParameterDictionary,StreamConfiguration,IDMap

echo 'Run OOI preload incrementally - this will fill in the gaps after the deletions and create DataProducts for new agent definitions'
bin/pycc -x ion.processes.bootstrap.ion_loader.IONLoader op=load loadooi=True path=/tmp/preload.xlsx assetmappings=/tmp/assetmappings.xlsx ooiuntil="6/30/2014" ooiparams=True ooiupdate=True

echo 'activate deployment for CP02PMUO PD, incremental preload does not activate existing deployment'
bin/pycc -x ion.agents.agentctrl.AgentControl preload_id="CP02PMUO-WP001_PD" op=activate_deployment

echo 'Bring in 5 new drivers for CP02PMUI, CP02PMUO platforms'

echo 'Run calibration for CP02PMUI consisting of 1 PD and 4 IDs, and CP02PMUO consisting of 1PD and 4 IDs'
bin/pycc -x ion.agents.agentctrl.AgentControl preload_id="CP02PMUI-SB001_PD,CP02PMUI-WF001-01-VEL3DK999_ID,CP02PMUI-WF001-02-DOFSTK999_ID,CP02PMUI-WF001-03-CTDPFK999_ID,CP02PMUI-RI001-01-ADCPTG999_ID,CP02PMUO-SB001_PD,CP02PMUO-WF001-01-VEL3DK999_ID,CP02PMUO-WF001-02-DOFSTK999_ID,CP02PMUO-WF001-03-CTDPFK999_ID,CP02PMUO-RI001-01-ADCPSL999_ID" op=set_calibration cfg=$thisdir/calibration.csv

echo 'Configure agent instances for CP02PMUI consisting of 1 PD and 4 IDs, and CP02PMUO consisting of 1PD and 4 IDs'
bin/pycc -x ion.agents.agentctrl.AgentControl preload_id="CP02PMUI-SB001_PD,CP02PMUI-WF001-01-VEL3DK999_ID,CP02PMUI-WF001-02-DOFSTK999_ID,CP02PMUI-WF001-03-CTDPFK999_ID,CP02PMUI-RI001-01-ADCPTG999_ID,CP02PMUO-SB001_PD,CP02PMUO-WF001-01-VEL3DK999_ID,CP02PMUO-WF001-02-DOFSTK999_ID,CP02PMUO-WF001-03-CTDPFK999_ID,CP02PMUO-RI001-01-ADCPSL999_ID" op=config_instance cfg=$thisdir/eai_configs.csv

echo 'Bring in 8 new drivers for CP02PMCI, CP02PMCO, CE09OSPM, CP04OSPM  platforms'
echo 'Run calibration'
bin/pycc -x ion.agents.agentctrl.AgentControl preload_id="CP02PMCI-WP001_PD,CP02PMCO-WP001_PD,CE09OSPM-WP001_PD,CP04OSPM-WP001_PD" recurse=True op=set_calibration cfg=$thisdir/calibration.csv

echo 'Configure agent: 8 drivers for 4 platforms'
bin/pycc -x ion.agents.agentctrl.AgentControl preload_id="CP02PMCI-WP001_PD,CP02PMCO-WP001_PD,CE09OSPM-WP001_PD,CP04OSPM-WP001_PD" recurse=True op=config_instance cfg=$thisdir/eai_configs.csv

if [ "X$1" != "XNORUN" ]; then
echo 'Start agents for CP02PMUI consisting of 1 PD and 4 IDs, and CP02PMUO consisting of 1PD and 4 IDs'
bin/pycc -x ion.agents.agentctrl.AgentControl preload_id="CP02PMUI-SB001_PD,CP02PMUI-WF001-01-VEL3DK999_ID,CP02PMUI-WF001-02-DOFSTK999_ID,CP02PMUI-WF001-03-CTDPFK999_ID,CP02PMUI-RI001-01-ADCPTG999_ID" op=start
bin/pycc -x ion.agents.agentctrl.AgentControl preload_id="CP02PMUO-SB001_PD,CP02PMUO-WF001-01-VEL3DK999_ID,CP02PMUO-WF001-02-DOFSTK999_ID,CP02PMUO-WF001-03-CTDPFK999_ID,CP02PMUO-RI001-01-ADCPSL999_ID" op=start

echo 'Start agents 8 drivers for 4 platforms CP02PMCI, CP02PMCO, CE09OSPM, CP04OSPM'
bin/pycc -x ion.agents.agentctrl.AgentControl preload_id="CP02PMCI-WP001_PD" recurse=True op=start
bin/pycc -x ion.agents.agentctrl.AgentControl preload_id="CP02PMCO-WP001_PD" recurse=True op=start
bin/pycc -x ion.agents.agentctrl.AgentControl preload_id="CE09OSPM-WP001_PD" recurse=True op=start
bin/pycc -x ion.agents.agentctrl.AgentControl preload_id="CP04OSPM-WP001_PD" recurse=True op=start

fi
