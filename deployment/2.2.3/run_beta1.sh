#!bin/bash
set -e
set -v
thisdir="$(dirname "$0")"

# MASTER paths
#preload_path="https://docs.google.com/spreadsheet/pub?key=0AttCeOvLP6XMdG82NHZfSEJJOGdQTkgzb05aRjkzMEE&output=xls"
#assetmappings_path="https://docs.google.com/spreadsheet/pub?key=0AttCeOvLP6XMdFVUeDdoUTU0b0NFQ1dCVDhuUjY0THc&output=xls"

# Copy of master
preload_path="https://docs.google.com/spreadsheet/pub?key=0ArzZOLNhEGVqdEhOZ0NNMUtaUjFiam01Wno0TlVwaWc&output=xls"
assetmappings_path="https://docs.google.com/spreadsheet/pub?key=0ArzZOLNhEGVqdEpVRjBxS2U2akVMOUkxS0dQLURDaFE&output=xls"

rm -f /tmp/preload.xlsx
rm -f /tmp/assetmappings.xlsx
curl -o /tmp/preload.xlsx $preload_path
curl -o /tmp/assetmappings.xlsx $assetmappings_path

echo 'Setting serial numbers for existing devices'
bin/pycc -x ion.agents.agentctrl.AgentControl op=set_attributes preload_id="CP02PMUO-WP001_PD,CP02PMUI-WP001_PD,CP02PMCI-WP001_PD,CP02PMCO-WP001_PD,CE09OSPM-WP001_PD,CP04OSPM-WP001_PD" recurse=True cfg=$thisdir/serial_numbers.csv

echo 'Running OOI incremental preload to update names for devices etc with serial numbers'
bin/pycc -x ion.processes.bootstrap.ion_loader.IONLoader op=load loadooi=True path=/tmp/preload.xlsx assetmappings=/tmp/assetmappings.xlsx ooiuntil="6/30/2014" ooiparams=True ooiupdate=True

echo 'Cloning (recursively) devices, agent instances, data products for CP02PMUO-WP001 and CP02PMUI-WP001'
bin/pycc -x ion.agents.agentctrl.AgentControl op=clone_device preload_id="CP02PMUO-WP001_PD,CP02PMUI-WP001_PD" clone_id=CL1 recurse=True verbose=True cfg=$thisdir/clone_attributes.csv

echo 'Cloning deployments for CP02PMUO-WP001 and CP02PMUI-WP001'
bin/pycc -x ion.agents.agentctrl.AgentControl op=clone_deployment preload_id="CP02PMUO-WP001_DEP,CP02PMUI-WP001_DEP" clone_id=CL1 recurse=True verbose=True cfg=$thisdir/clone_attributes.csv

echo 'Set agent instance config for CP02PMUO-WP001 and CP02PMUI-WP001 clones'
bin/pycc -x ion.agents.agentctrl.AgentControl op=config_instance preload_id="CP02PMUO-WP001_PD_CL1,CP02PMUI-WP001_PD_CL1" recurse=True verbose=True cfg=$thisdir/eai_configs.csv

echo 'Set calibration for CP02PMUO-WP001 and CP02PMUI-WP001 clones'
bin/pycc -x ion.agents.agentctrl.AgentControl op=set_calibration preload_id="CP02PMUO-WP001_PD_CL1,CP02PMUI-WP001_PD_CL1" recurse=True verbose=True cfg=$thisdir/calibration.csv

echo 'Activate persistence for CP02PMUO-WP001 and CP02PMUI-WP001 clones'
bin/pycc -x ion.agents.agentctrl.AgentControl op=activate_persistence preload_id="CP02PMUO-WP001_PD_CL1,CP02PMUI-WP001_PD_CL1" recurse=True verbose=True

echo 'Activate deployment for CP02PMUO-WP001 and CP02PMUI-WP001 clones'
bin/pycc -x ion.agents.agentctrl.AgentControl op=activate_deployment preload_id="CP02PMUO-WP001_PD_CL1,CP02PMUI-WP001_PD_CL1" verbose=True

echo 'Set turned devices to INTEGRATED state'
bin/pycc -x ion.agents.agentctrl.AgentControl op=set_lcstate  lcstate=INTEGRATED preload_id="CP02PMUO-WP001_PD,CP02PMUI-WP001_PD" recurse=True verbose=True

echo 'Set cloned devices to DEPLOYED state'
bin/pycc -x ion.agents.agentctrl.AgentControl op=set_lcstate  lcstate=DEPLOYED preload_id="CP02PMUO-WP001_PD_CL1,CP02PMUI-WP001_PD_CL1" recurse=True verbose=True

if [ "X$1" != "XNORUN" ]; then
echo 'Start agents for CP02PMUO-WP001 and CP02PMUI-WP001 clones'
bin/pycc -x ion.agents.agentctrl.AgentControl op=start preload_id="CP02PMUO-WP001_PD_CL1,CP02PMUI-WP001_PD_CL1" recurse=True verbose=True
fi

echo 'Updating system attribute mi_release_version'
bin/pycc -x ion.agents.agentctrl.AgentControl op=set_sys_attribute attr_key=mi_release_version attr_value="2.2.3" verbose=True
