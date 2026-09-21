#!/usr/bin/env bash
set -eo pipefail

export PKG="${PKG:-/home/<USER>/ros2_ws/src/isaac2}"
source /opt/ros/humble/setup.bash
source "$PKG/install/setup.bash"
export ROS_DOMAIN_ID="${ROS_DOMAIN_ID:-0}"

X="${1:-3.939420}"
Y="${2:--4.722604}"
YAW="${3:-0.094949}"
EXTRA_ARGS=("${@:4}")

exec ros2 run isaac_sim_2026 bobac_send_nav2_goal_2026.py --ros-args \
  -p x:="$X" \
  -p y:="$Y" \
  -p yaw:="$YAW" \
  "${EXTRA_ARGS[@]}"
