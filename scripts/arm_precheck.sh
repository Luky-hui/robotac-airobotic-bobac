#!/usr/bin/env bash
source /opt/ros/noetic/setup.bash
source /opt/ros/rei_nav/setup.bash --extend
source ~/bobac3_ws/devel/setup.bash --extend
source ~/rm_ws/devel/setup.bash --extend
export REI_ROBOT=bobac3
mkdir -p ~/bobac_match_logs
roslaunch rm_driver rm_eco65_driver.launch >~/bobac_match_logs/rm_driver_$(date +%H%M%S).log 2>&1 &
sleep 4
rostopic echo -n 1 /joint_states | tee ~/bobac_match_logs/joint_states_once.txt
rostopic echo -n 1 /rm_driver/Pose_State | tee ~/bobac_match_logs/tcp_pose_once.txt
rostopic pub -1 /rm_driver/Set_Modbus_Mode rm_msgs/Set_Modbus_Mode "{port: 1, baudrate: 115200, timeout: 100, ip: ''}"
