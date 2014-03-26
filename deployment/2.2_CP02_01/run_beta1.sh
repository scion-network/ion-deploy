#!bin/bash
set -e
set -x
this_dir="$(dirname "$0")"

echo 'Stop agents for 2 sites'
sh $this_dir/stop_agents.sh

echo 'Deactivate persistence for 2 sites'
sh $this_dir/deactivate_persistence.sh

echo 'Remove resources and coverage and agent state for 2 sites'
sh $this_dir/delete_all.sh

echo 'Run wfp preload'
sh $this_dir/preload_wfp.sh

echo 'run calibration for 4 sites'
sh $this_dir/calibrate.sh

echo 'activate deployment for 4 sites'
sh $this_dir/activate_deployment.sh

echo 'configure agent instances for 4 sites'
sh $this_dir/config_eai.sh

echo 'Start agents for 4 sites'
sh $this_dir/start_agents.sh
