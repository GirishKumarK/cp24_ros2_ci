#!/bin/bash
set -e

GAZEBO_IP=$(getent hosts gazebo2_container | awk '{ print $1 }')
sed -i "s|<Peer address=\"GAZEBO_CONTAINER\"/>|<Peer address=\"${GAZEBO_IP}\"/>|g" /home/ttbot/cyclonedds.xml
echo "${GAZEBO_IP} gazebo2_container" | sudo tee -a /etc/hosts

# Launch the ROS2 simulation for the TortoiseBot
source /opt/ros/galactic/setup.bash
source /home/ttbot/ros2_ws/install/setup.bash
ros2 launch tortoisebot_bringup bringup.launch.py use_sim_time:=True &

# Launch the Waypoints Action Server for ROS2
source /opt/ros/galactic/setup.bash
cd ~/ros2_ws && colcon build --packages-select tortoisebot_waypoints && source install/setup.bash
ros2 run tortoisebot_waypoints tortoisebot_action_server

# Replace current shell with the command passed as arguments to ensure proper signal handling
exec "$@"