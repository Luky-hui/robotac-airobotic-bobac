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
mkdir -p ~/bobac_match_logs ~/bobac_final_scripts
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
cp "$SCRIPT_DIR"/live_black_pen_detection_with_depth.py ~/bobac_final_scripts/ 2>/dev/null || true
chmod +x ~/bobac_final_scripts/live_black_pen_detection_with_depth.py 2>/dev/null || true
TX=2.798; TY=-1.645; TT=-0.119; QZ=-0.0595; QW=0.9982

echo '[1/7] 启动导航/RViz'
roslaunch bobac3_navigation bobac3_nav_2d.launch map_file_name:=site_0827_new open_nav_rviz:=true >~/bobac_match_logs/nav_$(date +%H%M%S).log 2>&1 &
sleep 8

echo '[2/7] 连接底盘'
rosservice call /base_connect "data: true" || true
sleep 1

echo '[3/7] 发送识别目标点'
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

echo '[4/7] 等待到达并打印误差'
python3 - <<PY
import math,time,rospy,tf
tx,ty,tt=$TX,$TY,$TT
rospy.init_node('wait_nav_reach',anonymous=True)
l=tf.TransformListener(); ok=False
for i in range(90):
    try:
        l.waitForTransform('map','base_footprint',rospy.Time(0),rospy.Duration(1.0))
        p,q=l.lookupTransform('map','base_footprint',rospy.Time(0)); yaw=tf.transformations.euler_from_quaternion(q)[2]
        e=math.hypot(p[0]-tx,p[1]-ty); ye=math.atan2(math.sin(yaw-tt),math.cos(yaw-tt))
        print('当前 x=%.3f y=%.3f theta=%.3f | 误差=%.1fcm 朝向=%.1fdeg'%(p[0],p[1],yaw,e*100,math.degrees(ye)), flush=True)
        if e<0.10: ok=True; break
    except Exception as ex: print('等待TF:',ex, flush=True)
    time.sleep(1)
print('NAV_OK=%s'%ok)
PY

echo '[5/7] 关闭底盘'
rosservice call /base_connect "data: false" || true
sleep 1

echo '[6/7] 标定当前机械臂关节为识别姿态'
(timeout 5 rostopic echo -n 1 /joint_states || true) | tee ~/bobac_match_logs/recognition_joint_pose_$(date +%H%M%S).txt

echo '[7/7] 启动机械臂相机并打开识别窗口'
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
python3 ~/bobac_final_scripts/live_black_pen_detection_with_depth.py
