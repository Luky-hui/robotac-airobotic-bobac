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

if [ ! -f "$MAP_DIRECTORY/site_0827_new.yaml" ] || [ ! -f "$MAP_DIRECTORY/site_0827_new.pgm" ]; then
  echo "MAP_MISSING: 请先运行 00_restore_to_robot.sh"
  exit 2
fi

mkdir -p ~/bobac_match_logs

rosnode kill /bobac3_arm/berxel_camera /bobac3_arm /ros_yolo_detect /vision_detect /depth2xyz_roi 2>/dev/null || true
rosnode kill /move_base_node /move_base /amcl /map_server /virtual_wall_map_publisher \
/front_lidar/front_lidar /rear_lidar/rear_lidar /laserscan_multi_merger 2>/dev/null || true
yes y | rosnode cleanup 2>/dev/null || true

echo "START_NAV: 地图 site_0827_new，RViz 打开后先确认激光和地图贴合；不贴合就用 2D Pose Estimate。"
roslaunch bobac3_navigation bobac3_nav_2d.launch map_file_name:=site_0827_new open_nav_rviz:=true
