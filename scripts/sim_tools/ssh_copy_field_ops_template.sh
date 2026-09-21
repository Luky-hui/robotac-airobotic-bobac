#!/usr/bin/env bash
set -eo pipefail

ROBOT_USER="${ROBOT_USER:-bobac3}"
ROBOT_IP="${ROBOT_IP:-<ROBOT_IP>}"
USB_ROOT="${USB_ROOT:-/media/<USER>/新加卷/Bobac_27号比赛现场_必带资料_20260826}"
REMOTE_DIR="${REMOTE_DIR:-~/bobac_field_ops}"

echo "Copying field scripts to ${ROBOT_USER}@${ROBOT_IP}:${REMOTE_DIR}"
scp -r "${USB_ROOT}/02_现场脚本快照" "${ROBOT_USER}@${ROBOT_IP}:${REMOTE_DIR}"

echo "Done. Then SSH and run:"
echo "  ssh ${ROBOT_USER}@${ROBOT_IP}"
echo "  cd ${REMOTE_DIR}"
echo "  bash official_real_bobac_precheck_ros1.sh"
