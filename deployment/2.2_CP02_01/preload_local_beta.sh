#!/bin/bash

echo 'preload beta'
bin/pycc -x ion.processes.bootstrap.ion_loader.IONLoader cfg=res/preload/r2_ioc/config/ooi_beta.yml path="https://docs.google.com/spreadsheet/pub?key=0Aq_8oD79eIi4dHpTOGV2bGZVNkJXd0J1ci1SX25zNXc&output=xls" assetmappings="https://docs.google.com/spreadsheet/pub?key=0ArzZOLNhEGVqdHA2MHNSX1dlT2ZTaHVrNVJzOG4xZnc&output=xls"
