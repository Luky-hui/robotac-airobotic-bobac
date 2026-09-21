#!/usr/bin/env bash
set -eo pipefail

export PKG="${PKG:-/home/<USER>/ros2_ws/src/isaac2}"
source /opt/ros/humble/setup.bash
if [[ -f "$PKG/install/setup.bash" ]]; then
  source "$PKG/install/setup.bash"
fi
export ROS_DOMAIN_ID="${ROS_DOMAIN_ID:-0}"
export CARGO_DELIVERY_WORLD="${CARGO_DELIVERY_WORLD:-Bobac}"

unset BOBAC_ENABLE_PX4
unset PEGASUS_EXTENSION

cd "$PKG"
exec ~/isaac-sim-4.5.0/isaac-sim.sh \
  --exec "$PKG/isaac-sim/isaacsimassets-dev/integrated_runtime/scene_app.py" \
  --world Bobac
