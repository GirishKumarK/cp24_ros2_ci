# ===== Base Image =====
FROM kkhadka343/kailash-cp22:tortoisebot-ros2-gazebo

# ===== Timezone Configuration =====
ARG timezone=UTC
ENV TZ=${timezone}

# ===== User Setup =====
USER root
ARG USERNAME=ttbot
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# ===== Set up environment =====
ENV DEBIAN_FRONTEND=noninteractive
ENV ROS2_WS=/home/${USERNAME}/ros2_ws
SHELL ["/bin/bash", "-c"]

# ===== User Context + Workspace Setup =====
USER $USERNAME
WORKDIR ${ROS2_WS}

# ===== Create and build workspace =====
RUN git clone https://github.com/kailash197/cp23_ros2test_tortoisebot_waypoints.git src/tortoisebot_waypoints
COPY --chown=${USER_UID}:${USER_GID} ./ros2_ci/cyclonedds.xml /home/${USERNAME}/cyclonedds.xml

# ===== Build =====
RUN . /opt/ros/galactic/setup.bash \
    && colcon build --packages-select tortoisebot_waypoints\
    && source install/setup.bash \
    && echo "source /opt/ros/galactic/setup.bash" >> ~/.bashrc \
    && echo "source ~/ros2_ws/install/setup.bash" >> ~/.bashrc

# ===== Environment Variables =====
ENV ROS_DISTRO=galactic
ENV RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
ENV ROS_DOMAIN_ID=7


# ===== Entrypoint =====
COPY --chown=${USER_UID}:${USER_GID} ./ros2_ci/entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]