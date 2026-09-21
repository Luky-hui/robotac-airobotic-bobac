#!/usr/bin/env bash
set -eo pipefail

OUT="${1:-/home/<USER>/bobac_match_logs/official_ros1_precheck_$(date +%Y%m%d_%H%M%S)}"
mkdir -p "$OUT"

run_optional() {
  local name="$1"
  shift
  echo "### $*" | tee "$OUT/${name}.txt"
  if "$@" >> "$OUT/${name}.txt" 2>&1; then
    echo "OK $name"
  else
    echo "WARN $name failed; see $OUT/${name}.txt"
  fi
}

{
  echo "time=$(date -Iseconds)"
  echo "host=$(hostname)"
  echo "ROS_DISTRO=${ROS_DISTRO:-unknown}"
  echo "ROS_MASTER_URI=${ROS_MASTER_URI:-unset}"
} > "$OUT/environment.txt"

run_optional lidar_devices ls /dev/front_lidar /dev/rear_lidar
run_optional rostopic_list bash -lc 'rostopic list'
run_optional rosnode_list bash -lc 'rosnode list'
run_optional odom_once bash -lc 'rostopic echo /odom --once'
run_optional scan_once bash -lc 'rostopic echo /scan --once'
run_optional cmd_vel_info bash -lc 'rostopic info /cmd_vel'
run_optional camera_topics bash -lc 'rostopic list | grep -E "berxel|rgb|depth|camera|cloud"'
run_optional joint_topics bash -lc 'rostopic list | grep -E "joint|arm|eco|rm|gripper"'
run_optional tf_frames bash -lc 'rosrun tf view_frames'

cat > "$OUT/README.md" <<EOF
# Official Bobac ROS1 precheck

This folder records the official/manual side evidence:

- lidar device names: lidar_devices.txt
- ROS graph: rostopic_list.txt, rosnode_list.txt
- base motion topics: odom_once.txt, scan_once.txt, cmd_vel_info.txt
- camera topics: camera_topics.txt
- arm/gripper topics: joint_topics.txt
- TF frames: tf_frames.txt

If this script reports warnings, inspect the corresponding txt file and use the
official Bobac manual launch commands before running competition scripts.
EOF

echo "OFFICIAL_ROS1_PRECHECK_DIR=$OUT"
