#!bin/bash
set -e
set -v
thisdir="$(dirname "$0")"

# MASTER paths
#preload_path="https://docs.google.com/spreadsheet/pub?key=0AttCeOvLP6XMdG82NHZfSEJJOGdQTkgzb05aRjkzMEE&output=xls"
#assetmappings_path="https://docs.google.com/spreadsheet/pub?key=0AttCeOvLP6XMdFVUeDdoUTU0b0NFQ1dCVDhuUjY0THc&output=xls"

# Copy of master
preload_path="https://docs.google.com/spreadsheet/pub?key=0ArzZOLNhEGVqdFpPMVd6Y1BkNmpLbjhNdXBVNElidGc&output=xls"
assetmappings_path="https://docs.google.com/spreadsheet/pub?key=0ArzZOLNhEGVqdDRuOEFIcWJyNDdGYTl4RzhHdXRtTHc&output=xls"

rm -f /tmp/preload.xlsx
rm -f /tmp/assetmappings.xlsx
curl -o /tmp/preload.xlsx $preload_path
curl -o /tmp/assetmappings.xlsx $assetmappings_path

echo 'Clean sites on CE05 and CP05 gliders'
bin/pycc -x ion.agents.agentctrl.AgentControl recurse=True preload_id="CP05MOAS-GL001,CP05MOAS-GL002,CP05MOAS-GL003,CP05MOAS-GL004,CP05MOAS-GL005,CP05MOAS-GL006,CE05MOAS-GL001,CE05MOAS-GL002,CE05MOAS-GL003,CE05MOAS-GL004,CE05MOAS-GL005,CE05MOAS-GL006" op=delete_site

echo 'Clean instruments on CE05 and CP05 gliders'
bin/pycc -x ion.agents.agentctrl.AgentControl recurse=True preload_id="CP05MOAS-GL001_PD,CP05MOAS-GL002_PD,CP05MOAS-GL003_PD,CP05MOAS-GL004_PD,CP05MOAS-GL005_PD,CP05MOAS-GL006_PD,CE05MOAS-GL001_PD,CE05MOAS-GL002_PD,CE05MOAS-GL003_PD,CE05MOAS-GL004_PD,CE05MOAS-GL005_PD,CE05MOAS-GL006_PD" op=delete_all_device force=True

echo 'Running OOI incremental preload to bring in new sites not in SAF: CE05MOAS-GL007 to GL012 and CP05MOAS-GL007 to GL012'
bin/pycc -x ion.processes.bootstrap.ion_loader.IONLoader op=load loadooi=True path=/tmp/preload.xlsx assetmappings=/tmp/assetmappings.xlsx ooiuntil="6/30/2014" ooiparams=True ooiupdate=True

echo 'Run glider preload'
bin/pycc -x ion.processes.bootstrap.ion_loader.IONLoader op=load path=/tmp/preload.xlsx assetmappings=/tmp/assetmappings.xlsx scenario=CTDGV_M_GLDR_CSTL,DOSTA_M_GLDR_CSTL,ENG_M_GLDR_CSTL,FLORT_M_GLDR_CSTL,PARAD_M_GLDR_CSTL idmap=True categories=ExternalDatasetAgent,ParameterFunctions,ParameterDefs,ParameterDictionary,StreamConfiguration,IDMap

echo 'Setting serial numbers'
bin/pycc -x ion.agents.agentctrl.AgentControl op=set_attributes preload_id="CE05MOAS-GL001_PD,CE05MOAS-GL002_PD,CE05MOAS-GL003_PD,CP05MOAS-GL001_PD,CP05MOAS-GL002_PD,CP05MOAS-GL003_PD" recurse=True cfg=$thisdir/serial_numbers.csv

echo 'Running OOI incremental preload to update names for devices etc with serial numbers and generate new data products'
bin/pycc -x ion.processes.bootstrap.ion_loader.IONLoader op=load loadooi=True path=/tmp/preload.xlsx assetmappings=/tmp/assetmappings.xlsx ooiuntil="6/30/2014" ooiparams=True ooiupdate=True

echo 'Set agent instance config'
bin/pycc -x ion.agents.agentctrl.AgentControl op=config_instance preload_id="CE05MOAS-GL001_PD,CE05MOAS-GL002_PD,CE05MOAS-GL003_PD,CP05MOAS-GL001_PD,CP05MOAS-GL002_PD,CP05MOAS-GL003_PD" recurse=True verbose=True cfg=$thisdir/eai_configs.csv

echo 'No calibration'

if [ "X$1" != "XNORUN" ]; then
echo 'Start agents'
bin/pycc -x ion.agents.agentctrl.AgentControl op=start preload_id="CE05MOAS-GL001_PD,CE05MOAS-GL002_PD" recurse=True verbose=True
bin/pycc -x ion.agents.agentctrl.AgentControl op=start preload_id="CE05MOAS-GL003_PD,CP05MOAS-GL001_PD" recurse=True verbose=True
bin/pycc -x ion.agents.agentctrl.AgentControl op=start preload_id="CP05MOAS-GL002_PD,CP05MOAS-GL003_PD" recurse=True verbose=True
fi

echo 'Updating system attribute mi_release_version'
bin/pycc -x ion.agents.agentctrl.AgentControl op=set_sys_attribute attr_key=mi_release_version attr_value="2.2.4" verbose=True
