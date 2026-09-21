#!/usr/bin/env bash
set -eo pipefail

export PKG="${PKG:-/home/<USER>/ros2_ws/src/isaac2}"
source /opt/ros/humble/setup.bash
source "$PKG/install/setup.bash"
export ROS_DOMAIN_ID="${ROS_DOMAIN_ID:-0}"

exec ros2 run isaac_sim_2026 bobac_place_after_grasp_fixed_2026.py --ros-args \
  -p enforce_base_pose:=false
