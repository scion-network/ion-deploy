#!bin/bash
set -e
set -v
thisdir="$(dirname "$0")"

# MASTER paths
preload_path="https://docs.google.com/spreadsheet/pub?key=0AttCeOvLP6XMdG82NHZfSEJJOGdQTkgzb05aRjkzMEE&output=xls"
assetmappings_path="https://docs.google.com/spreadsheet/pub?key=0AttCeOvLP6XMdFVUeDdoUTU0b0NFQ1dCVDhuUjY0THc&output=xls"

# Copy of master
#preload_path="https://docs.google.com/spreadsheet/pub?key=0ArzZOLNhEGVqdFpPMVd6Y1BkNmpLbjhNdXBVNElidGc&output=xls"
#assetmappings_path="https://docs.google.com/spreadsheet/pub?key=0ArzZOLNhEGVqdDRuOEFIcWJyNDdGYTl4RzhHdXRtTHc&output=xls"

rm -f /tmp/preload.xlsx
rm -f /tmp/assetmappings.xlsx
curl -o /tmp/preload.xlsx $preload_path
curl -o /tmp/assetmappings.xlsx $assetmappings_path

echo 'Stop agents'
bin/pycc -x ion.agents.agentctrl.AgentControl preload_id="CP02PMUI-RI001-01-ADCPTG999_ID,CP02PMUI-RI001-01-ADCPTG999_ID_CL1,CP02PMUO-RI001-01-ADCPSL999_ID,CP02PMUO-RI001-01-ADCPSL999_ID_CL1,CP02PMCI-RI001-01-ADCPTG999_ID,CP02PMCO-RI001-01-ADCPTG999_ID" op=stop

echo 'We are doing this since our preloaded scenario on ADCPSL_CSTL had mismatched param definition names from the drivers that were actually delivered'

echo 'Delete data product, resources, and coverage for 6 instruments.'

bin/pycc -x ion.agents.agentctrl.AgentControl preload_id="CP02PMUI-RI001-01-ADCPTG999_ID,CP02PMUI-RI001-01-ADCPTG999_ID_CL1,CP02PMUO-RI001-01-ADCPSL999_ID,CP02PMUO-RI001-01-ADCPSL999_ID_CL1,CP02PMCI-RI001-01-ADCPTG999_ID,CP02PMCO-RI001-01-ADCPTG999_ID" op=delete_all_data force=True

echo 'Clear saved state for 6 instruments'

bin/pycc -x ion.agents.agentctrl.AgentControl preload_id="CP02PMUI-RI001-01-ADCPTG999_ID,CP02PMUI-RI001-01-ADCPTG999_ID_CL1,CP02PMUO-RI001-01-ADCPSL999_ID,CP02PMUO-RI001-01-ADCPSL999_ID_CL1,CP02PMCI-RI001-01-ADCPTG999_ID,CP02PMCO-RI001-01-ADCPTG999_ID" op=clear_saved_state

echo 'Instroduce new dataset agent definition using a FIX scenario'
echo 'TBD'

echo 'Incremental preload to recreate data product, etc.'
bin/pycc -x ion.processes.bootstrap.ion_loader.IONLoader op=load loadooi=True path=/tmp/preload.xlsx assetmappings=/tmp/assetmappings.xlsx ooiuntil="6/30/2014" ooiparams=True ooiupdate=True

echo 'Start agents to reingest'
bin/pycc -x ion.agents.agentctrl.AgentControl preload_id="CP02PMUI-RI001-01-ADCPTG999_ID,CP02PMUI-RI001-01-ADCPTG999_ID_CL1,CP02PMUO-RI001-01-ADCPSL999_ID,CP02PMUO-RI001-01-ADCPSL999_ID_CL1,CP02PMCI-RI001-01-ADCPTG999_ID,CP02PMCO-RI001-01-ADCPTG999_ID" op=start
