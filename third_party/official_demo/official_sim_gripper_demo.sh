#!/usr/bin/env bash
set -eo pipefail

export PKG="${PKG:-/home/<USER>/ros2_ws/src/isaac2}"
source /opt/ros/humble/setup.bash
source "$PKG/install/setup.bash"
export ROS_DOMAIN_ID="${ROS_DOMAIN_ID:-44}"

exec ros2 launch grasp_demo_pkg gripper_demo.launch.py "$@"
