#!/bin/bash
set -e
cd ..

echo 'Load WFP01'
bin/pycc -x ion.processes.bootstrap.ion_loader.IONLoader cfg=dsadriver/wfp_all01.yml path="https://docs.google.com/spreadsheet/pub?key=0Aq_8oD79eIi4dElmNnp0SEo4RlYzLVVMWWhHcTdIaGc&output=xls" assetmappings="https://docs.google.com/spreadsheet/pub?key=0Aq_8oD79eIi4dEtVX1ZpaXRZNTlENVdWMWZidTdZMGc&output=xls"

echo 'Configure 3-Wavelength Fluorometer on Wire-Following Profiler - Coastal Pioneer Upstream Inshore'
bin/pycc -x ion.agents.agentctrl.AgentControl instrument='3-Wavelength Fluorometer on Wire-Following Profiler - Coastal Pioneer Upstream Inshore' op=config_instance cfg=dsadriver/ai_configs_production.csv
bin/pycc -x ion.agents.agentctrl.AgentControl instrument='3-Wavelength Fluorometer on Wire-Following Profiler - Coastal Pioneer Upstream Inshore' op=activate_persistence 
bin/pycc -x ion.agents.agentctrl.AgentControl device_name='3-Wavelength Fluorometer on Wire-Following Profiler - Coastal Pioneer Upstream Inshore' op=set_calibration cfg=dsadriver/CalData.csv

echo 'Configure Photosynthetically Available Radiation on Wire-Following Profiler - Coastal Pioneer Upstream Inshore'
bin/pycc -x ion.agents.agentctrl.AgentControl device_name='Photosynthetically Available Radiation on Wire-Following Profiler - Coastal Pioneer Upstream Inshore' op=config_instance cfg=dsadriver/ai_configs_production.csv
bin/pycc -x ion.agents.agentctrl.AgentControl device_name='Photosynthetically Available Radiation on Wire-Following Profiler - Coastal Pioneer Upstream Inshore' op=activate_persistence 
bin/pycc -x ion.agents.agentctrl.AgentControl device_name='Photosynthetically Available Radiation on Wire-Following Profiler - Coastal Pioneer Upstream Inshore' op=set_calibration cfg=dsadriver/CalData.csv

echo 'Configure Wire-Following Profiler - Coastal Pioneer Upstream Inshore'
bin/pycc -x ion.agents.agentctrl.AgentControl device_name='Wire-Following Profiler - Coastal Pioneer Upstream Inshore' op=config_instance cfg=dsadriver/ai_configs_production.csv

echo 'Configure 3-Wavelength Fluorometer on Wire-Following Profiler - Coastal Pioneer Upstream Offshore'
bin/pycc -x ion.agents.agentctrl.AgentControl instrument='3-Wavelength Fluorometer on Wire-Following Profiler - Coastal Pioneer Upstream Offshore' op=config_instance cfg=dsadriver/ai_configs_production.csv
bin/pycc -x ion.agents.agentctrl.AgentControl instrument='3-Wavelength Fluorometer on Wire-Following Profiler - Coastal Pioneer Upstream Offshore' op=activate_persistence
bin/pycc -x ion.agents.agentctrl.AgentControl device_name='3-Wavelength Fluorometer on Wire-Following Profiler - Coastal Pioneer Upstream Offshore' op=set_calibration cfg=dsadriver/CalData.csv

echo 'Configure Photosynthetically Available Radiation on Wire-Following Profiler - Coastal Pioneer Upstream Offshore'
bin/pycc -x ion.agents.agentctrl.AgentControl device_name='Photosynthetically Available Radiation on Wire-Following Profiler - Coastal Pioneer Upstream Offshore' op=config_instance cfg=dsadriver/ai_configs_production.csv
bin/pycc -x ion.agents.agentctrl.AgentControl device_name='Photosynthetically Available Radiation on Wire-Following Profiler - Coastal Pioneer Upstream Offshore' op=activate_persistence
bin/pycc -x ion.agents.agentctrl.AgentControl device_name='Photosynthetically Available Radiation on Wire-Following Profiler - Coastal Pioneer Upstream Offshore' op=set_calibration cfg=dsadriver/CalData.csv

echo 'Configure Wire-Following Profiler - Coastal Pioneer Upstream Offshore'
bin/pycc -x ion.agents.agentctrl.AgentControl device_name='Wire-Following Profiler - Coastal Pioneer Upstream Offshore' op=config_instance cfg=dsadriver/ai_configs_production.csv

echo 'Start Inshore Instruments'
bin/pycc -x ion.agents.agentctrl.AgentControl device_name='3-Wavelength Fluorometer on Wire-Following Profiler - Coastal Pioneer Upstream Inshore' op=start
bin/pycc -x ion.agents.agentctrl.AgentControl device_name='Photosynthetically Available Radiation on Wire-Following Profiler - Coastal Pioneer Upstream Inshore' op=start
bin/pycc -x ion.agents.agentctrl.AgentControl device_name='Wire-Following Profiler - Coastal Pioneer Upstream Inshore' op=start

echo 'Start Offshore Instruments'
bin/pycc -x ion.agents.agentctrl.AgentControl device_name='3-Wavelength Fluorometer on Wire-Following Profiler - Coastal Pioneer Upstream Offshore' op=start
bin/pycc -x ion.agents.agentctrl.AgentControl device_name='Photosynthetically Available Radiation on Wire-Following Profiler - Coastal Pioneer Upstream Offshore' op=start
bin/pycc -x ion.agents.agentctrl.AgentControl device_name='Wire-Following Profiler - Coastal Pioneer Upstream Offshore' op=start

echo 'Script Completed'

cd -
