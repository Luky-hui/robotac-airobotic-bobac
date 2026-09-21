#!/usr/bin/env bash
set -eo pipefail

export PKG="${PKG:-/home/<USER>/ros2_ws/src/isaac2}"
cd "$PKG"
source /opt/ros/humble/setup.bash

colcon build \
  --base-paths "$PKG" \
  --build-base "$PKG/build" \
  --install-base "$PKG/install" \
  --packages-select grasp_demo_interfaces grasp_demo_pkg isaac_sim_2026 \
  --symlink-install

source "$PKG/install/setup.bash"
