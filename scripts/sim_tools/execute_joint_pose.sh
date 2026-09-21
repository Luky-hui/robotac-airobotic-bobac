#!/usr/bin/env bash
set -eo pipefail

export PKG="${PKG:-/home/<USER>/ros2_ws/src/isaac2}"
source /opt/ros/humble/setup.bash
source "$PKG/install/setup.bash"
export ROS_DOMAIN_ID="${ROS_DOMAIN_ID:-0}"

TARGET="${1:-[0.103500, 0.029600, -0.087500, 0.212000, 1.647500, 0.328400]}"
DURATION="${2:-3.0}"
COMMAND_TOPIC="${COMMAND_TOPIC:-/hand_command}"

exec ros2 run isaac_sim_2026 bobac_execute_joint_pose_2026.py --ros-args \
  -p command_topic:="$COMMAND_TOPIC" \
  -p target:="$TARGET" \
  -p duration:="$DURATION"
