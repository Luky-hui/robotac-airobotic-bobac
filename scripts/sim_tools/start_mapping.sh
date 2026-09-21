#!/usr/bin/env bash
set -eo pipefail

export PKG="${PKG:-/home/<USER>/ros2_ws/src/isaac2}"
source /opt/ros/humble/setup.bash
source "$PKG/install/setup.bash"
export ROS_DOMAIN_ID="${ROS_DOMAIN_ID:-0}"

exec ros2 launch isaac_sim_2026 rtab-map-scan.launch.py \
  launch_viz:="${LAUNCH_VIZ:-false}" \
  "$@"
