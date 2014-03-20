#!/bin/bash

cd ..

echo 'Clean up'
bin/pycc -X -fc -bc 

echo 'Start r2 services'
bin/pycc --mx --rel res/deploy/r2deploy.yml -fc

cd -
