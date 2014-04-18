#!bin/bash
set -e
set -v
thisdir="$(dirname "$0")"

# MASTER paths
preload_path="https://docs.google.com/spreadsheet/pub?key=0AttCeOvLP6XMdG82NHZfSEJJOGdQTkgzb05aRjkzMEE&output=xls"
assetmappings_path="https://docs.google.com/spreadsheet/pub?key=0AttCeOvLP6XMdFVUeDdoUTU0b0NFQ1dCVDhuUjY0THc&output=xls"

# Copy of master
#preload_path="https://docs.google.com/spreadsheet/pub?key=0ArzZOLNhEGVqdGptdl8tVk1QdHl0d01oYTY0aGJTMVE&output=xls"
#assetmappings_path="https://docs.google.com/spreadsheet/pub?key=0ArzZOLNhEGVqdHpVSmtIUE5UeHNUTVBObmd4WlBmaHc&output=xls"

rm -f /tmp/preload.xlsx
rm -f /tmp/assetmappings.xlsx
curl -o /tmp/preload.xlsx $preload_path
curl -o /tmp/assetmappings.xlsx $assetmappings_path

echo 'Run OOI preload incrementally - this will fill in the gaps after the deletions and create DataProducts for new agent definitions'
bin/pycc -x ion.processes.bootstrap.ion_loader.IONLoader op=load loadooi=True path=/tmp/preload.xlsx assetmappings=/tmp/assetmappings.xlsx ooiuntil="6/30/2014" ooiparams=True ooiupdate=True

echo 'Deactivate deployment for the 2 top PDS'
bin/pycc -x ion.agents.agentctrl.AgentControl preload_id="CP02PMUI-WP001_PD,CP02PMUO-WP001_PD" op=deactivate_deployment

echo 'suspend persistence'
bin/pycc -x ion.agents.agentctrl.AgentControl recurse=True preload_id="CP02PMUO-RI001-01-ADCPSL999_ID" op=suspend_persistence autoclean=True

echo 'Clean up CP02PMUO-RI001-01-ADCPSL999 as it has wrong data products'
echo 'Remove resources and coverage and agent state for CP02PMUO-RI001-01-ADCPSL999_ID'
bin/pycc -x ion.agents.agentctrl.AgentControl recurse=True preload_id="CP02PMUO-RI001-01-ADCPSL999_ID" op=delete_all_device
echo 'Remove resources for CP02PMUO-RI001-01-ADCPSL999 site'
bin/pycc -x ion.agents.agentctrl.AgentControl recurse=True preload_id="CP02PMUO-RI001-01-ADCPSL999" op=delete_site

echo 'Run wfp preload for the 5 drivers - this adds new agent definitions and parameters'
bin/pycc -x ion.processes.bootstrap.ion_loader.IONLoader op=load path=/tmp/preload.xlsx assetmappings=/tmp/assetmappings.xlsx scenario=DOFST_K_CSTL,CTDPF_CKL_CSTL,VEL3D_K_CSTL,ADCPSL_CSTL,CG_STC_ENG_CSTL idmap=True categories=ExternalDatasetAgent,ParameterFunctions,ParameterDefs,ParameterDictionary,StreamConfiguration,IDMap

echo 'Run OOI preload incrementally - this will fill in the gaps after the deletions and create DataProducts for new agent definitions'
bin/pycc -x ion.processes.bootstrap.ion_loader.IONLoader op=load loadooi=True path=/tmp/preload.xlsx assetmappings=/tmp/assetmappings.xlsx ooiuntil="6/30/2014" ooiparams=True ooiupdate=True

echo 'Run calibration for CP02PMUI consisting of 1 PD and 4 IDs, and CP02PMUO consisting of 1PD and 4 IDs'
bin/pycc -x ion.agents.agentctrl.AgentControl preload_id="CP02PMUI-SB001_PD,CP02PMUI-WF001-01-VEL3DK999_ID,CP02PMUI-WF001-02-DOFSTK999_ID,CP02PMUI-WF001-03-CTDPFK999_ID,CP02PMUI-RI001-01-ADCPTG999_ID,CP02PMUO-SB001_PD,CP02PMUO-WF001-01-VEL3DK999_ID,CP02PMUO-WF001-02-DOFSTK999_ID,CP02PMUO-WF001-03-CTDPFK999_ID,CP02PMUO-RI001-01-ADCPSL999_ID" op=set_calibration cfg=$thisdir/calibration.csv

echo 'Configure agent instances for CP02PMUI consisting of 1 PD and 4 IDs, and CP02PMUO consisting of 1PD and 4 IDs' 
bin/pycc -x ion.agents.agentctrl.AgentControl preload_id="CP02PMUI-SB001_PD,CP02PMUI-WF001-01-VEL3DK999_ID,CP02PMUI-WF001-02-DOFSTK999_ID,CP02PMUI-WF001-03-CTDPFK999_ID,CP02PMUI-RI001-01-ADCPTG999_ID,CP02PMUO-SB001_PD,CP02PMUO-WF001-01-VEL3DK999_ID,CP02PMUO-WF001-02-DOFSTK999_ID,CP02PMUO-WF001-03-CTDPFK999_ID,CP02PMUO-RI001-01-ADCPSL999_ID" op=config_instance cfg=$thisdir/eai_configs.csv

if [ $1 == "NORUN" ]; then
  exit 0
fi

echo 'Start agents for CP02PMUI consisting of 1 PD and 4 IDs, and CP02PMUO consisting of 1PD and 4 IDs' 
bin/pycc -x ion.agents.agentctrl.AgentControl preload_id="CP02PMUI-SB001_PD,CP02PMUI-WF001-01-VEL3DK999_ID,CP02PMUI-WF001-02-DOFSTK999_ID,CP02PMUI-WF001-03-CTDPFK999_ID,CP02PMUI-RI001-01-ADCPTG999_ID,CP02PMUO-SB001_PD,CP02PMUO-WF001-01-VEL3DK999_ID,CP02PMUO-WF001-02-DOFSTK999_ID,CP02PMUO-WF001-03-CTDPFK999_ID,CP02PMUO-RI001-01-ADCPSL999_ID" op=start
