#!/bin/bash
##################################################################################
# ion-terminate.sh
#
# This script terinates the ION system
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

# Create log dir
#echo "BUILDLOG $BUILD_LOG"
#mkdir -p $BUILD_LOG

# Setup virtualenv
. $ION_NAME/bin/activate

# Check if system has already been launched
if [ -e $HOME/.cloudinitd/cloudinitd-$RUN.db ]; then 
    # remove node from nagios

    # terminate ION system
    echo "Terminating ${ION_NAME}..."
    cloudinitd terminate $RUN
else
    echo "$HOME/.cloudinitd/cloudinitd-$RUN.db not found, $ION_NAME already terminated??"
    exit 1;
fi;

