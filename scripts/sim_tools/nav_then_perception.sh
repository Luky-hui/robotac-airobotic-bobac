#!/usr/bin/env bash
set -eo pipefail

export PKG="${PKG:-/home/<USER>/ros2_ws/src/isaac2}"
source /opt/ros/humble/setup.bash
source "$PKG/install/setup.bash"
export ROS_DOMAIN_ID="${ROS_DOMAIN_ID:-0}"

X="${1:-3.939420}"
Y="${2:--4.722604}"
YAW="${3:-0.094949}"
PARAMS_FILE="${4:-$PKG/grasp_demo_pkg/config/demo_params.yaml}"

"$PKG/field_ops/send_goal.sh" "$X" "$Y" "$YAW" \
  -p initial_delay_sec:=0.5 \
  -p xy_refine_tolerance:=0.070 \
  -p yaw_refine_tolerance:=0.100 \
  -p refine_timeout_sec:=90.0 \
  -p refine_max_linear:=0.22 \
  -p refine_min_linear:=0.040

exec ros2 launch grasp_demo_pkg pose_tf_demo.launch.py \
  params_file:="$PARAMS_FILE"
