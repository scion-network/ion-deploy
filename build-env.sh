#!/bin/bash
##################################################################################
# build-env.sh
#
# This script sets the build environment variables based on ion system name.  It
# should be sourced by the deploy-ion.sh script 
#
##################################################################################

# Usage
if [ "$1" == "" ]; then
  echo "Usage: $0 [ion-name]"
  exit
fi

ION_NAME=$1

DATE=`/bin/date +%F_%H%M`

### Default
export LAUNCH_HOME=`pwd`
export LAUNCH_PLANS=`pwd`/launch-plans
export RUN_DIR=$LAUNCH_PLANS/R2
export BUILD_LOG=./logs/$DATE
export PYON_PATH=$LAUNCH_HOME/coi-services
export PYON_CONFIG_FILE=$PYON_PATH/res/config/pyon.local.yml

### Set env based on ion system
case $ION_NAME in 
  # ion-stage
  stage)
  	export RUN=R2_STAGE_SYSTEM
	export RABBITMQ_HOST=r01.s.oceanobservatories.org
  	export RABBITMQ_USERNAME=ooistagermq
  	export RABBITMQ_PASSWORD="RBT5t2G3"
	export ES_HOST=elasticsearch.s.oceanobservatories.org
	export GRAYLOG_HOST=elasticsearch.s.oceanobservatories.org
	export NAGIOS_HOST=nagios-pl.oceanobservatories.org
        export SG_HOST=sg.s.oceanobservatories.org
	export UX_HOST=ooin.oceanobservatories.org
	export COI_VERS="2.0.73"
	export DTDATA_VERS="2.0.0"
	export EPU_VERS="2.0.1"
	export EPUAGENT_VERS="2.0.2"
	export COI_TAR="http://plrepo.oceanobservatories.org/releases/coi-services-ooici-master-$COI_VERS.tar.gz"
	export PRELOAD_KEY="0ArzZOLNhEGVqdDBVSF9yZXhGV1NqZ0FkZG9pNWJydFE"
	export PRELOAD="bin/pycc -x ion.processes.bootstrap.ion_loader.IONLoader cfg=res/preload/r2_ioc/config/ooi_beta.yml path='http://docs.google.com/spreadsheet/pub?key=${PRELOAD_KEY}&output=xls'"
  	;;
  # ion-beta
  beta)
  	export RUN=R2_BETA_SYSTEM
	export RABBITMQ_HOST=r01.b.oceanobservatories.org
  	export RABBITMQ_USERNAME=ooistagermq
  	export RABBITMQ_PASSWORD="RBT5t2G3"
	export ES_HOST=elasticsearch.b.oceanobservatories.org
	export GRAYLOG_HOST=logging.b.oceanobservatories.org
	export NAGIOS_HOST=nagios-sd.oceanobservatories.org
        export SG_HOST=sg.b.oceanobservatories.org
	export UX_HOST=ion-beta.oceanobservatories.org
	export COI_VERS="2.0.73"
	export DTDATA_VERS="2.0.0"
	export EPU_VERS="2.0.1"
	export EPUAGENT_VERS="2.0.2"
	export COI_TAR="http://sddevrepo.oceanobservatories.org/releases/coi-services-ooici-master-$COI_VERS.tar.gz"
	export PRELOAD_KEY="0ArzZOLNhEGVqdDBVSF9yZXhGV1NqZ0FkZG9pNWJydFE"
	export PRELOAD="bin/pycc -x ion.processes.bootstrap.ion_loader.IONLoader cfg=res/preload/r2_ioc/config/ooi_beta.yml path='https://docs.google.com/spreadsheet/pub?key=${PRELOAD_KEY}&output=xls'"
  	;;
  *)
  	echo "Not a valid ion system name. Aborting..."
	exit 1
	;;
esac
