#!/usr/bin/env bash
set -eo pipefail

export PKG="${PKG:-/home/<USER>/ros2_ws/src/isaac2}"
source /opt/ros/humble/setup.bash
source "$PKG/install/setup.bash"

# Provincial simulation lessons use ROS_DOMAIN_ID=44 by default.  The national
# isaac2 package was validated with 0, so keep the caller's value if provided.
export ROS_DOMAIN_ID="${ROS_DOMAIN_ID:-44}"

exec ros2 launch nav2_demo_pkg slam_toolbox_online.launch.py "$@"
