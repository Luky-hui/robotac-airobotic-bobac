#!/usr/bin/env bash
set -eo pipefail

export PKG="${PKG:-/home/<USER>/ros2_ws/src/isaac2}"
source /opt/ros/humble/setup.bash
source "$PKG/install/setup.bash"
export ROS_DOMAIN_ID="${ROS_DOMAIN_ID:-0}"

X="${1:-3.939420}"
Y="${2:--4.722604}"
YAW="${3:-0.094949}"
ALIGN_POSE="${4:-[0.000000, 0.000000, -0.000100, -1.305000, 1.560000, 0.000000]}"
PARAMS_FILE="${5:-$PKG/grasp_demo_pkg/config/real_bobac_params.yaml}"
DURATION="${ALIGN_DURATION:-3.0}"

echo "[1/4] Nav2 goal: x=$X y=$Y yaw=$YAW"
"$PKG/field_ops/send_goal.sh" "$X" "$Y" "$YAW" \
  -p initial_delay_sec:=0.5 \
  -p xy_refine_tolerance:=0.070 \
  -p yaw_refine_tolerance:=0.100 \
  -p refine_timeout_sec:=90.0 \
  -p refine_max_linear:=0.22 \
  -p refine_min_linear:=0.040

echo "[2/4] Optional radar/SLAM stop"
if [[ -n "${STOP_RADAR_CMD:-}" ]]; then
  echo "Running STOP_RADAR_CMD=$STOP_RADAR_CMD"
  bash -lc "$STOP_RADAR_CMD"
else
  echo "STOP_RADAR_CMD is empty; no node is stopped. Stop lidar/SLAM manually if Berxel requires it."
fi

echo "[3/4] Arm align pose: $ALIGN_POSE"
"$PKG/field_ops/execute_joint_pose.sh" "$ALIGN_POSE" "$DURATION"

echo "[4/4] Start perception pipeline: $PARAMS_FILE"
exec "$PKG/field_ops/start_perception_pipeline.sh" "$PARAMS_FILE"
