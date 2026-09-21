#!/usr/bin/env bash
set -eo pipefail

export PKG="${PKG:-/home/<USER>/ros2_ws/src/isaac2}"
source /opt/ros/humble/setup.bash
source "$PKG/install/setup.bash"
export ROS_DOMAIN_ID="${ROS_DOMAIN_ID:-0}"

PARAMS_FILE="${1:-$PKG/grasp_demo_pkg/config/demo_params.yaml}"

exec ros2 launch grasp_demo_pkg pose_tf_demo.launch.py \
  params_file:="$PARAMS_FILE"
