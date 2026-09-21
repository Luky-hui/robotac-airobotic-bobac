#!/usr/bin/env bash
source /opt/ros/noetic/setup.bash
source /opt/ros/rei_nav/setup.bash --extend
source ~/bobac3_ws/devel/setup.bash --extend
source ~/cartographer_ws/install_isolated/setup.bash --extend 2>/dev/null || true
source ~/rm_ws/devel/setup.bash --extend 2>/dev/null || true
export REI_ROBOT=bobac3
export MAP_DIRECTORY=/home/bobac3/.reinovo/maps
