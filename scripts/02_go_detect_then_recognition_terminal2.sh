#!/usr/bin/env bash
set -e

source /opt/ros/noetic/setup.bash
source /opt/ros/rei_nav/setup.bash --extend
source ~/bobac3_ws/devel/setup.bash --extend
source ~/cartographer_ws/install_isolated/setup.bash --extend 2>/dev/null || true
source ~/rm_ws/devel/setup.bash --extend 2>/dev/null || true
export REI_ROBOT=bobac3
export MAP_DIRECTORY=/home/bobac3/.reinovo/maps
export DISPLAY="${DISPLAY:-:0}"
export BERXEL_SN="${BERXEL_SN:-}"

mkdir -p ~/bobac_match_logs

TX=2.798
TY=-1.645
TT=-0.119
QZ=-0.0595
QW=0.9982

echo "[1/6] 检查导航是否已启动"
for i in $(seq 1 20); do
  if rosnode list 2>/dev/null | grep -Eq 'move_base'; then
    echo "MOVE_BASE_PRESENT=True"
    break
  fi
  sleep 1
done
if ! rosnode list 2>/dev/null | grep -Eq 'move_base'; then
  echo "MOVE_BASE_PRESENT=False: 先在终端1运行 01_start_nav_terminal1.sh"
  exit 2
fi

echo "[2/6] 连接底盘并发送识别点"
rosservice call /base_connect "data: true" || true
rostopic pub -1 /move_base_simple/goal geometry_msgs/PoseStamped "header:
  frame_id: 'map'
pose:
  position:
    x: $TX
    y: $TY
    z: 0.0
  orientation:
    z: $QZ
    w: $QW"

echo "[3/6] 等待到达；误差小于10cm才切识别"
python3 - <<PY
import math, time, rospy, tf, sys
tx, ty, tt = $TX, $TY, $TT
rospy.init_node('bobac_wait_detect_goal', anonymous=True)
l = tf.TransformListener()
ok = False
last = None
for i in range(90):
    try:
        l.waitForTransform('map', 'base_footprint', rospy.Time(0), rospy.Duration(1.0))
        p, q = l.lookupTransform('map', 'base_footprint', rospy.Time(0))
        yaw = tf.transformations.euler_from_quaternion(q)[2]
        e = math.hypot(p[0] - tx, p[1] - ty)
        ye = math.atan2(math.sin(yaw - tt), math.cos(yaw - tt))
        print('当前 x=%.3f y=%.3f theta=%.3f | 位置误差=%.1fcm 朝向误差=%.1fdeg' %
              (p[0], p[1], yaw, e * 100, math.degrees(ye)), flush=True)
        if e < 0.10:
            ok = True
            break
        last = (p, yaw, e, ye)
    except Exception as ex:
        print('等待TF:', ex, flush=True)
    time.sleep(1)
print('NAV_OK=%s' % ok)
if not ok:
    sys.exit(3)
PY

echo "[4/6] 停车、取消目标、关闭导航/雷达/定位节点"
rostopic pub -1 /cmd_vel geometry_msgs/Twist "{}" || true
rostopic pub -1 /move_base/cancel actionlib_msgs/GoalID "{}" || true
rosnode kill /move_base_node /move_base /amcl /map_server /virtual_wall_map_publisher \
/front_lidar/front_lidar /rear_lidar/rear_lidar /laserscan_multi_merger 2>/dev/null || true
sleep 2

echo "[5/6] 记录当前机械臂关节为识别姿态"
(timeout 5 rostopic echo -n 1 /joint_states || true) | tee ~/bobac_match_logs/recognition_joint_pose_$(date +%H%M%S).txt

echo "[6/6] 启动机械臂 Berxel 相机并打开实时识别窗口"
rosnode kill /bobac3_arm/berxel_camera /bobac3_arm 2>/dev/null || true
echo "BERXEL_SN=$BERXEL_SN"
roslaunch berxel_camera berxel_arm.launch serial_no:=$BERXEL_SN >~/bobac_match_logs/arm_camera_$(date +%H%M%S).log 2>&1 &
sleep 8

if ! timeout 4 rostopic echo -n 1 /bobac3_arm/rgb/rgb_raw >/dev/null; then
  echo "RGB_TOPIC_MISSING: 当前相机话题如下"
  rostopic list | grep bobac3_arm || true
  grep -h "Find device" ~/bobac_match_logs/arm_camera_*.log 2>/dev/null || true
  exit 4
fi
if ! timeout 4 rostopic echo -n 1 /bobac3_arm/depth/depth_raw >/dev/null; then
  echo "DEPTH_TOPIC_MISSING: 当前相机话题如下"
  rostopic list | grep bobac3_arm || true
  grep -h "Find device" ~/bobac_match_logs/arm_camera_*.log 2>/dev/null || true
  exit 5
fi
echo "CAMERA_TOPICS_OK=True"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
python3 "$SCRIPT_DIR/live_black_pen_detection_with_depth.py"
