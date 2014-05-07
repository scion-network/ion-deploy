#!bin/bash
set -e
set -v

SQLFILE=${1:-"mmcoi_ion_master_beta22.sql"}
DBNAME=${2:-"mmcoi_ion"}

dropdb $DBNAME

createdb $DBNAME

psql -f $SQLFILE $DBNAME

echo "delete from ion_resources where id ~~ 'registration%'" | psql $DBNAME

echo "delete from ion_resources where type_='Service'" | psql $DBNAME

echo "delete from ion_resources where type_='Policy'" | psql $DBNAME

