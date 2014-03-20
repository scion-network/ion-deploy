In coi-services dir (ion-tools should be in the same dir as coi-services dir)

ln -s ../ion-deploy/dsadriver dsadriver

In one console:
cd dsadriver

sh r2deploy.sh

Once service is up, In another console:

cd dsadriver

sh preload.sh

sh specific_driver.sh
