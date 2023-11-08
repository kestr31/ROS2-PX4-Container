#! /bin/bash

# CHECK IF AIRSIM_IP IS SET
if [ -z "${AIRSIM_IP}" ]; then
    echo -e "\033[31mERROR\t[ROS2-AIRSIM] AIRSIM_IP IS NOT SET"
    exit 1
fi

echo -e "\033[32mINFO\t[ROS2-AIRSIM] STARTING AIRSIM_ROS_PKGS..."

# ENABLE ROS2 ENVIRONMENT AND ENABLE PREBUILT PACKAGES
source /opt/ros/galactic/setup.bash
source ${HOME}/ros_ws/install/setup.bash

# LAUNCH AIRSIM_ROS_PKGS
ros2 launch airsim_ros_pkgs airsim_node.launch.py host:=${AIRSIM_IP}