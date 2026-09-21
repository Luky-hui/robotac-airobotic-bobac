#!/usr/bin/env bash
set -eo pipefail

export PKG="${PKG:-/home/<USER>/ros2_ws/src/isaac2}"
source /opt/ros/humble/setup.bash
source "$PKG/install/setup.bash"
export ROS_DOMAIN_ID="${ROS_DOMAIN_ID:-44}"

MAP_ARG="${1:-}"
if [[ -n "$MAP_ARG" ]]; then
  exec ros2 launch nav2_demo_pkg nav2_navigation.launch.py map:="$MAP_ARG"
else
  exec ros2 launch nav2_demo_pkg nav2_navigation.launch.py "$@"
fi
