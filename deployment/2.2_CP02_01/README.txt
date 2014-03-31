Need to run scripts from coi-services dir:
You can soft link if you choose in coi:
ln -s ../ion-deploy/deployment deployment
thisdir=deployment/2.2_CP02_01
> eg: sh $thisdir/script_to_run.sh

Alpha run1:
sh $thisdir/run_alpha1.sh

Local run to prior to Alpha run2:
sh $thisdir/run_local_pre_alpha2.sh (or clone alpha db as an alternative)
sh $thisdir/run_alpha2.sh

Alpha run2:
sh $thisdir/run_alpha2.sh

Local run prior to Beta run1 :
sh $thisdir/run_local_pre_beta1.sh (or clone beta db as an alternative)
sh $thisdir/run_beta1.sh

Beta run1:
sh $thisdir/run_beta1.sh
