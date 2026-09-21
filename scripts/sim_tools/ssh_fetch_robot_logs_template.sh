#!/usr/bin/env bash
set -eo pipefail

ROBOT_USER="${ROBOT_USER:-bobac3}"
ROBOT_IP="${ROBOT_IP:-<ROBOT_IP>}"
REMOTE_LOG_DIR="${REMOTE_LOG_DIR:-~/bobac_match_logs}"
LOCAL_DIR="${LOCAL_DIR:-$HOME/bobac_match_logs_from_robot}"

mkdir -p "$LOCAL_DIR"
echo "Fetching ${ROBOT_USER}@${ROBOT_IP}:${REMOTE_LOG_DIR} -> ${LOCAL_DIR}"
scp -r "${ROBOT_USER}@${ROBOT_IP}:${REMOTE_LOG_DIR}" "$LOCAL_DIR/"
echo "Done: $LOCAL_DIR"
