#!/usr/bin/env bash
# ============================================================
# 现场环境变量模板
#   用法：cp scripts/env.example.sh scripts/env.local.sh
#         编辑 env.local.sh 填入现场真实值，然后 source 它
#   注意：env.local.sh 已在 .gitignore 中忽略，请勿提交
# ============================================================

# 机器人登录信息
export ROBOT_USER="bobac3"
export ROBOT_IP="<ROBOT_IP>"            # 例：192.168.1.100
export ROBOT_PASSWORD="<PASSWORD>"      # 机器人登录口令

# Berxel 相机序列号（不同设备不同，先看驱动日志中的 Find device）
export BERXEL_SN="<BERXEL_SN>"

# 路径约定
export MAP_FILE_NAME="site_0827_new"                       # maps/ 下的地图名，不带扩展名
export MAP_DIRECTORY="/home/${ROBOT_USER}/.reinovo/maps"   # 机器人侧地图目录
export MATCH_SCRIPTS_DIR="/home/${ROBOT_USER}/bobac_match/scripts"
export LOG_DIR="/home/${ROBOT_USER}/bobac_match_logs"
