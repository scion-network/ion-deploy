#!/bin/bash
##################################################################################
# ion-restart.sh
#
# This script re-starts the ION system
#
##################################################################################

# Usage
if [ "$1" == "" ]; then
  echo "Usage: $0 [ion-name]"
  exit
fi

ION_NAME=$1

# Source ENV
#source ./build-env.sh $ION_NAME

# Terminate ION system
./ion-terminate.sh $ION_NAME

# Create log dir
echo "BUILDLOG $BUILD_LOG"
mkdir -p $BUILD_LOG

# Check if system has already been launched
if [ -e $HOME/.cloudinitd/cloudinitd-$RUN.db ]; then 
    echo "$HOME/.cloudinitd/cloudinitd-$RUN.db exists"
    echo 'Already launched.  Abort.'
    exit 1;
fi;


##########################
#### setup virtualenv ####
##########################
# clean old virtualenv first
[ -d $LAUNCH_HOME/$ION_NAME ] && rm -rf $LAUNCH_HOME/$ION_NAME
# create new virtualenv
/usr/local/bin/virtualenv --no-site-packages $ION_NAME
. $ION_NAME/bin/activate
pip install argparse

# clean old coi-services
rm -rf $LAUNCH_HOME/coi-services*
# Install CEI and Pyon
pip install -r $RUN_DIR/requirements/default.txt
wget --no-check-certificate $COI_TAR
tar -xf coi-*.tar.gz

#################################
#### Run any CLEANUP scripts ####
#################################
# Clean elasticsearch indices
curl -XDELETE "http://$ES_HOST:9200/"

# Clean graylog2 indices (elasticsearch)
curl -XDELETE "http://$GRAYLOG_HOST:9200/graylog2"
# echo build number
echo https://github.com/ooici/coi-services/commit/`cat $PYON_PATH/.gitcommit` > $BUILD_LOG/build-number

# copy logging.yml to rundir
cp logging-stage.yml $RUN_DIR/logging.yml

#############  TEMP ########################
cp stage.yml $PYON_PATH/res/launch/stage.yml
#############  TEMP ########################
# generate pyon launch levels
echo "generate launch plan..."
sed "s/REPLACE_WITH_COI_VERS/${COI_VERS}/g" nimbus-$ION_NAME.yml > $RUN_DIR/nimbus-static.yml
$RUN_DIR/bin/generate-plan --logconfig $RUN_DIR/logging.yml --profile $RUN_DIR/nimbus-static.yml --rel $PYON_PATH/res/deploy/r2deploy.yml --launch $PYON_PATH/res/launch/$ION_NAME.yml $RUN_DIR/plans/$ION_NAME -f 

# launch
echo "launching ion system..."
cloudinitd boot -vvv $RUN_DIR/plans/stage/launch.conf -n $RUN
# get process list
sleep 15
ceictl -n $RUN process list > $BUILD_LOG/process-list

#### bootstrap elastic search
echo "bootstrap elastic search..."
cd $PYON_PATH
bin/pycc -D -x ion.processes.bootstrap.index_bootstrap.IndexBootStrap op='clean_bootstrap'

#### Add nagios nodes