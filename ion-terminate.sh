#!/bin/bash
##################################################################################
# ion-terminate.sh
#
# This script terminates the ION system
#
##################################################################################

# Usage
if [ "$1" == "" ]; then
  echo "Usage: $0 [ion-name]"
  exit
fi

ION_NAME=$1

# Source ENV
source ./build-env.sh $ION_NAME

# Setup virtualenv
. $ION_NAME/bin/activate

# Check if system has already been launched
if [ -e $HOME/.cloudinitd/cloudinitd-$RUN.db ]; then 
    #### Disable ion-ux
    echo "Disable ion-ux..."
    ssh -t $UX_HOST "sudo /www/ux-maintenance.sh offline"

    # remove nodes from nagios
    echo "Removing nagios nodes..."
    ssh $NAGIOS_HOST "sudo /root/bin/remove-ion-nodes.sh ion-beta"

    # terminate ION system
    echo "Terminating ${ION_NAME}..."
    cloudinitd terminate $RUN
else
    echo "$HOME/.cloudinitd/cloudinitd-$RUN.db not found, $ION_NAME already terminated??"
    exit 1;
fi;

