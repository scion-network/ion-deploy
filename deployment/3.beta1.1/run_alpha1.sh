#!/bin/bash
set -e
set -v
thisdir="$(dirname "$0")"

# MASTER paths
preload_path="https://docs.google.com/spreadsheet/pub?key=0AttCeOvLP6XMdG82NHZfSEJJOGdQTkgzb05aRjkzMEE&output=xls"
assetmappings_path="https://docs.google.com/spreadsheet/pub?key=0AttCeOvLP6XMdFVUeDdoUTU0b0NFQ1dCVDhuUjY0THc&output=xls"

# Copy of master
#preload_path="https://docs.google.com/spreadsheet/pub?key=0ArzZOLNhEGVqdEhOZ0NNMUtaUjFiam01Wno0TlVwaWc&output=xls"
#assetmappings_path="https://docs.google.com/spreadsheet/pub?key=0AlQ93_KBW3ibdEZwRW9LSEJfTHZxTzZselBRMnRUa0E&output=xls"

rm -f /tmp/preload.xlsx
rm -f /tmp/assetmappings.xlsx
curl -o /tmp/preload.xlsx $preload_path
curl -o /tmp/assetmappings.xlsx $assetmappings_path

echo 'scenario preload'
bin/pycc -x ion.processes.bootstrap.ion_loader.IONLoader op=load path=/tmp/preload.xlsx assetmappings=/tmp/assetmappings.xlsx scenario=TMPSF,PREST idmap=True categories=InstrumentAgent,ParameterFunctions,ParameterDefs,ParameterDictionary,StreamConfiguration,IDMap

echo 'set serial numbers'
bin/pycc -x ion.agents.agentctrl.AgentControl op=set_attributes preload_id="RS09BTST-LJ09A-01-TMPSFA100_ID,RS09BTST-LJ09A-01-PRESTA100_ID" recurse=True verbose=True cfg=$thisdir/serial_numbers.csv

bin/pycc -x ion.agents.agentctrl.AgentControl op=config_instance preload_id="RS09BTST-LJ09A-01-TMPSFA100_ID,RS09BTST-LJ09A-01-PRESTA100_ID" recurse=True verbose=True cfg=$thisdir/iai_configs.csv

echo '2nd incremental preload'
bin/pycc -x ion.processes.bootstrap.ion_loader.IONLoader op=load loadooi=True path=/tmp/preload.xlsx assetmappings=/tmp/assetmappings.xlsx ooiuntil="6/30/2014" ooiparams=True ooiupdate=True
