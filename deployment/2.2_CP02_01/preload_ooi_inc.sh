#!/bin/bash
set -x
this_dir="$(dirname "$0")"

echo 'Load ooi incremental preload'
bin/pycc -x ion.processes.bootstrap.ion_loader.IONLoader cfg=$this_dir/ooi_inc_preload.yml path="https://docs.google.com/spreadsheet/pub?key=0Aq_8oD79eIi4dElmNnp0SEo4RlYzLVVMWWhHcTdIaGc&output=xls" assetmappings="https://docs.google.com/spreadsheet/pub?key=0Aq_8oD79eIi4dHNzVWJKQkRzbkNZdWZKRDM2Vi1qZHc&output=xls"

echo 'Script Completed'
