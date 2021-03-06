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
export REMOTE_WORKING_DIR_ENV=/tmp/nimbusready-$ION_NAME

# Need to set this for Jenkins so mx can start
export BUILD_ID=

### Set env based on ion system
case $ION_NAME in 
  # ion-stage
  stage)
  	export RUN=R2_STAGE_SYSTEM
	export RABBITMQ_HOST=r01.s.oceanobservatories.org
  	export RABBITMQ_USERNAME=ooistagermq
  	export RABBITMQ_PASSWORD="RBT5t2G3"
	export ERDDAP_HOST=erddap.s.oceanobservatories.org
	export GRAYLOG_HOST=elasticsearch.s.oceanobservatories.org
	export NAGIOS_HOST=nagios-pl.oceanobservatories.org
        export SG_HOST=sg.s.oceanobservatories.org
	export UX_HOST=ooin.oceanobservatories.org
	export MX_PORT=8080
	export COI_VERS="2.1.4-dev"
	#export DTDATA_VERS="2.0.1"
	export EPU_VERS="2.0.1"
	export EPUAGENT_VERS="2.0.2"
	export COI_TAR="http://plrepo.oceanobservatories.org/releases/coi-services-ooici-REL2.0-$COI_VERS.tar.gz"
	export PRELOAD_KEY="0ArzZOLNhEGVqdE5zaGhGS3Q2ZFhoRk1rSlpsaXBULXc"
        export ASSET_MAP_KEY="0ArzZOLNhEGVqdHA2MHNSX1dlT2ZTaHVrNVJzOG4xZnc"
	export PRELOAD="bin/pycc -x ion.processes.bootstrap.ion_loader.IONLoader assets=res/preload/r2_ioc/ooi_assets cfg=res/preload/r2_ioc/config/ooi_beta.yml path='http://docs.google.com/spreadsheet/pub?key=${PRELOAD_KEY}&output=xls' assetmappings='http://docs.google.com/spreadsheet/pub?key=${ASSET_MAP_KEY}&output=xls'"
  	;;
  # ion-beta
  beta)
  	export RUN=R2_BETA_SYSTEM
	export RABBITMQ_HOST=r01.b.oceanobservatories.org
  	export RABBITMQ_USERNAME=ooistagermq
  	export RABBITMQ_PASSWORD="RBT5t2G3"
	export ERDDAP_HOST=erddap.b.oceanobservatories.org
	export GRAYLOG_HOST=logging.b.oceanobservatories.org
	export NAGIOS_HOST=nagios-sd.oceanobservatories.org
        export SG_HOST=sg.b.oceanobservatories.org
	export UX_HOST=ion-beta.oceanobservatories.org
	export MX_PORT=8083
	export COI_VERS="2.2.6"
	#export DTDATA_VERS="2.0.1"
	export EPU_VERS="2.0.1"
	export EPUAGENT_VERS="2.0.2"
	export COI_TAR="http://sddevrepo.oceanobservatories.org/releases/coi-services-ooici-REL2.0-$COI_VERS.tar.gz"
	export PRELOAD_KEY="0Aq_8oD79eIi4dHpTOGV2bGZVNkJXd0J1ci1SX25zNXc"
        export ASSET_MAP_KEY="0ArzZOLNhEGVqdHA2MHNSX1dlT2ZTaHVrNVJzOG4xZnc"
	export PRELOAD="bin/pycc -x ion.processes.bootstrap.ion_loader.IONLoader assets=res/preload/r2_ioc/ooi_assets cfg=res/preload/r2_ioc/config/ooi_beta.yml path='http://docs.google.com/spreadsheet/pub?key=${PRELOAD_KEY}&output=xls' assetmappings='http://docs.google.com/spreadsheet/pub?key=${ASSET_MAP_KEY}&output=xls'"
  	;;
  # ion-beta r3
  beta_r3)
  	export RUN=R3_BETA_SYSTEM
	export RABBITMQ_HOST=rabbit.b3.oceanobservatories.org
  	export RABBITMQ_USERNAME=ooistagermq
  	export RABBITMQ_PASSWORD="RBT5t2G3"
	export ERDDAP_HOST=erddap.b3.oceanobservatories.org
	export GRAYLOG_HOST=logging.b3.oceanobservatories.org
	export NAGIOS_HOST=nagios-sd.oceanobservatories.org
        export SG_HOST=sg.b3.oceanobservatories.org
	export UX_HOST=r3-beta.oceanobservatories.org
	export MX_PORT=8084
	export COI_VERS="2.2.3"
	#export DTDATA_VERS="2.0.1"
	export EPU_VERS="2.0.1"
	export EPUAGENT_VERS="2.0.2"
	export COI_TAR="http://sddevrepo.oceanobservatories.org/releases/coi-services-ooici-master.tar.gz"
	export PRELOAD_KEY="0Aq_8oD79eIi4dHpTOGV2bGZVNkJXd0J1ci1SX25zNXc"
        export ASSET_MAP_KEY="0ArzZOLNhEGVqdHA2MHNSX1dlT2ZTaHVrNVJzOG4xZnc"
        export UI_PATH="https://userexperience.oceanobservatories.org/database-exports/R3Candidates/"
	export PRELOAD="bin/pycc -x ion.processes.bootstrap.ion_loader.IONLoader ui_path=${UI_PATH} assets=res/preload/r2_ioc/ooi_assets cfg=res/preload/r2_ioc/config/ooi_beta.yml path='http://docs.google.com/spreadsheet/pub?key=${PRELOAD_KEY}&output=xls' assetmappings='http://docs.google.com/spreadsheet/pub?key=${ASSET_MAP_KEY}&output=xls'"
  	;;
  *)
  	echo "Not a valid ion system name. Aborting..."
	exit 1
	;;
esac
