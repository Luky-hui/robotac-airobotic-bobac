#!/usr/bin/env bash
set -eo pipefail

export PKG="${PKG:-/home/<USER>/ros2_ws/src/isaac2}"
source /opt/ros/humble/setup.bash
source "$PKG/install/setup.bash"
export ROS_DOMAIN_ID="${ROS_DOMAIN_ID:-0}"

ROOT="${1:-/home/<USER>/bobac_match_logs/preaudit_$(date +%Y%m%d_%H%M%S)}"
mkdir -p "$ROOT"

echo "PREAUDIT_DIR=$ROOT"
{
  echo "time=$(date -Iseconds)"
  echo "PKG=$PKG"
  echo "ROS_DOMAIN_ID=$ROS_DOMAIN_ID"
  echo "ROS_DISTRO=${ROS_DISTRO:-unknown}"
  echo "host=$(hostname)"
} > "$ROOT/environment.txt"

echo "[1/3] ROS2 preflight check"
"$PKG/field_ops/preflight_check.sh" --ros-args \
  -p timeout_sec:=3.0 \
  -p output_dir:="$ROOT/preflight" | tee "$ROOT/preflight_stdout.txt"

echo "[2/3] Save ROS2 topics, TF, params, configs"
"$PKG/field_ops/save_logs.sh" --ros-args \
  -p log_dir:="$ROOT/field_log" | tee "$ROOT/save_logs_stdout.txt"

echo "[3/3] Copy field operation scripts"
mkdir -p "$ROOT/field_ops_snapshot"
cp -a "$PKG/field_ops/." "$ROOT/field_ops_snapshot/"

cat > "$ROOT/README.md" <<EOF
# Bobac pre-audit evidence

- environment: environment.txt
- preflight stdout: preflight_stdout.txt
- preflight report: preflight/
- ROS2/TF/config logs: field_log/
- field scripts snapshot: field_ops_snapshot/

Use this folder for:

1. Hardware and driver adaptation evidence.
2. Sensor data receive/send evidence.
3. System integration evidence.
4. Engineering reproducibility appendix.
EOF

echo "PREAUDIT_DONE=$ROOT"
