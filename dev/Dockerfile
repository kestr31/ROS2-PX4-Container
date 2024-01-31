ARG BASEIMAGE
ARG BASETAG

#          __                                     __ 
#    _____/ /_____ _____ ____        ____ _____  / /_
#   / ___/ __/ __ `/ __ `/ _ \______/ __ `/ __ \/ __/
#  (__  ) /_/ /_/ / /_/ /  __/_____/ /_/ / /_/ / /_  
# /____/\__/\__,_/\__, /\___/      \__,_/ .___/\__/  
#                /____/                /_/           

# BASE STAGE FOR CACHINE APT PACKAGE LISTS
FROM ${BASEIMAGE}:${BASETAG} as stage_apt

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG BASETAG

ENV \
    DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

RUN \
    if [ "x$(cat /etc/os-release | grep 'VERSION_ID' | cut -d'=' -f2 | tr -d '"')" == "x22.04" ] || [ "x$(cat /etc/os-release | grep 'VERSION_ID' | cut -d'=' -f2 | tr -d '"')" == "x20.04" ]; then \
        echo "BASE IMAGE CHECK PASSED."; \
    else \
        echo "IMAGE MUST BE BASED ON UBUNTU 20.04 OR 22.04." \
        && exit 1; \
    fi

# SET KAKAO MIRROR FOR FASTER BUILD
# THIS WILL ONLY BE APPLIED ON THE BUILD PROCESS
RUN \
    rm -rf /etc/apt/apt.conf.d/docker-clean \
	&& echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache \
	&& sed -i 's/archive.ubuntu.com/mirror.kakao.com/g' /etc/apt/sources.list \
    && apt-get update

# INSTALL DEPENDENCIES FOR ADDING ADDITIONAL REPOS.
RUN \
    apt install -y --no-install-recommends \
        ca-certificates \
        curl \
        lsb-release \
        software-properties-common \
        wget

# ADD ROS2 PACKAGE REPOSITORY
RUN \
    add-apt-repository universe \
    && curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null \
    && apt-get update --quiet


#          __                         _____             __
#    _____/ /_____ _____ ____        / __(_)___  ____ _/ /
#   / ___/ __/ __ `/ __ `/ _ \______/ /_/ / __ \/ __ `/ / 
#  (__  ) /_/ /_/ / /_/ /  __/_____/ __/ / / / / /_/ / /  
# /____/\__/\__,_/\__, /\___/     /_/ /_/_/ /_/\__,_/_/   
#                /____/                                   

FROM ${BASEIMAGE}:${BASETAG} as stage_final

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG BASETAG

ENV \
    DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

# ADD NON-ROOT USER user AND GRANT SUDO PERMISSION
RUN \
    groupadd user \
    && useradd -ms /bin/zsh user -g user

# UPGRADE THE BASIC ENVIRONMENT FIRST
RUN \
    --mount=type=cache,target=/var/cache/apt,from=stage_apt,source=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt,from=stage_apt,source=/var/lib/apt \
    --mount=type=cache,target=/etc/apt/sources.list.d,from=stage_apt,source=/etc/apt/sources.list.d \
    --mount=type=cache,target=/etc/apt/sources.list,from=stage_apt,source=/etc/apt/sources.list \
    apt-get upgrade -y \
    && apt-get install --no-install-recommends -y \
        ca-certificates \
        locales \
        gettext \
    && rm -rf /tmp/*

# SET LOCALE TO en_UT.UTF-8
RUN \
    locale-gen en_US en_US.UTF-8 \
    && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

# COPY REQUIRED APT PACKAGE LIST
COPY aptDeps.txt /tmp/aptDeps.txt

# INSTALL PACKAGES AVAIABLE BY APT REPOSITORY
RUN \
    --mount=type=cache,target=/var/cache/apt,from=stage_apt,source=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt,from=stage_apt,source=/var/lib/apt \
    --mount=type=cache,target=/etc/apt/sources.list.d,from=stage_apt,source=/etc/apt/sources.list.d \
    --mount=type=cache,target=/etc/apt/sources.list,from=stage_apt,source=/etc/apt/sources.list \
    if [[ "x$(cat /etc/os-release | grep 'VERSION_ID' | cut -d'=' -f2 | tr -d '"')" == "x22.04" ]]; then \
        ROS_DISTRO=humble envsubst < /tmp/aptDeps.txt > /tmp/aptDepsMod.txt; \
    elif [[ "x$(cat /etc/os-release | grep 'VERSION_ID' | cut -d'=' -f2 | tr -d '"')" == "x20.04" ]]; then \
        ROS_DISTRO=galactic envsubst < /tmp/aptDeps.txt > /tmp/aptDepsMod.txt; \
    else \
        echo "IMAGE MUST BE BASED ON UBUNTU 20.04 OR 22.04" \
        && exit 1; \
    fi \
    && apt-get install --no-install-recommends -y \
        $(cat /tmp/aptDepsMod.txt) \
    && rm -rf /tmp/*


COPY --chown=ue4:ue4 \
    pyDeps.txt /tmp/pyDeps.txt

# INSTALL PYTHON DEPENDENCIES
# AIRSIM PACKAGE MUST BE INSTALLED LATER THAN MSGPACK-RPC-PYTHON
RUN \
    python3 -m pip install  \
        $(cat /tmp/pyDeps.txt) \
    && rm -rf /tmp/*


# ADD NON-ROOT USER user AND GRANT SUDO PERMISSION
# THIS IS BAD FOR CONTAINER SECURITY
# BUT THIS DOES NOT MATTERS FOR DEVELOPING SIMULATOR CONTAINER
RUN \
    echo "user ALL=NOPASSWD: ALL" >> /etc/sudoers

# CHANGE USER TO NEWLY GENERATED user AND CHANGE WORKING DIRECTORY TO user's HOME
USER user
WORKDIR /home/user

# FOR EASE OF DEVELOPMENT, INSTALL OH-MY-ZSH AND PLUGINS. SET ALIAS FOR CAT
RUN \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended \
    && sed -i "s/robbyrussell/agnoster/g" ${HOME}/.zshrc \
    && git clone https://github.com/zsh-users/zsh-autosuggestions.git \
        ${HOME}/.oh-my-zsh/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
        ${HOME}/.oh-my-zsh/plugins/zsh-syntax-highlighting \
    && sed -i "s/(git)/(git zsh-autosuggestions zsh-syntax-highlighting)/g" ${HOME}/.zshrc \
    && echo "alias cat='batcat --paging=never'" >> ${HOME}/.zshrc

# BUILD PX4 MSG DEFINITIONS FOR SUBSCRIPTION AND PUBLICATION
RUN \
    mkdir -p /home/user/px4_ros_ws/src \
    && git clone https://github.com/PX4/px4_msgs.git \
        /home/user/px4_ros_ws/src/px4_msgs -b release/1.14 \
    && git -C /home/user/px4_ros_ws/src/px4_msgs \
        reset --hard ffc3a4cd578776213a444abe17d7eabf9621b266 \
    && if [[ "x$(cat /etc/os-release | grep 'VERSION_ID' | cut -d'=' -f2 | tr -d '"')" == "x22.04" ]]; then \
        source /opt/ros/humble/setup.bash; \
    elif [[ "x$(cat /etc/os-release | grep 'VERSION_ID' | cut -d'=' -f2 | tr -d '"')" == "x20.04" ]]; then \
        source /opt/ros/galactic/setup.bash; \
    else \
        echo "IMAGE MUST BE BASED ON UBUNTU 20.04 OR 22.04" \
        && exit 1; \
    fi \
    && colcon build \
        --base-paths ${HOME}/px4_ros_ws/src \
        --build-base ${HOME}/px4_ros_ws/build \
        --install-base ${HOME}/px4_ros_ws/install \
    && mv log ${HOME}/px4_ros_ws

# ENTRYPOINT SCRIPT
# SET PERMISSION SO THAT USER CAN EDIT INSIDE THE CONTAINER
COPY --chown=user:user entrypoint.sh \
    /usr/local/bin/entrypoint.sh

# CREATE SYMBOLIC LINK FOR QUICK ACCESS
# THEN ADD ADDITIONAL LINES ON SHELL RC FOR ROS2 USAGE
RUN \
    mkdir /home/user/scripts \
    && sudo ln -s /usr/local/bin/entrypoint.sh /home/user/scripts/entrypoint.sh \
    && if [[ "x$(cat /etc/os-release | grep 'VERSION_ID' | cut -d'=' -f2 | tr -d '"')" == "x22.04" ]]; then \
        echo "source /opt/ros/humble/setup.bash" >> ${HOME}/.bashrc \
        && echo "source /opt/ros/humble/setup.zsh" >> ${HOME}/.zshrc; \
    elif [[ "x$(cat /etc/os-release | grep 'VERSION_ID' | cut -d'=' -f2 | tr -d '"')" == "x20.04" ]]; then \
        echo "source /opt/ros/galactic/setup.bash" >> ${HOME}/.bashrc \
        && echo "source /opt/ros/galactic/setup.zsh" >> ${HOME}/.zshrc; \
    else \
        echo "IMAGE MUST BE BASED ON UBUNTU 20.04 OR 22.04" \
        && exit 1; \
    fi \
    && echo "source ${HOME}/px4_ros_ws/install/setup.bash" >> ${HOME}/.bashrc \
    && echo "source ${HOME}/px4_ros_ws/install/setup.zsh" >> ${HOME}/.zshrc

CMD [ "/usr/local/bin/entrypoint.sh" ]

# --------------- BUILD COMMAND ---------------
# DOCKER_BUILDKIT=1 docker build \
# --build-arg BASEIMAGE=nvidia/cuda \
# --build-arg BASETAG=11.8.0-devel-ubuntu22.04  \
# -t jociiiii/ros2:dev-humble-0.1 \
# -f ./Dockerfile .


# docker buildx build \
# --progress=plain \
# --platform=linux/arm64/v8,linux/amd64 \
# --build-arg BASEIMAGE=ubuntu \
# --build-arg BASETAG=22.04 \
# -t kestr3l/ros2:dev-humble-0.1 \
# -f ./Dockerfile .

# ------- BUILD COMMAND (AMD64 CUDA) ------
# docker buildx build \
# --progress=plain \
# --build-arg BASEIMAGE=nvidia/cuda \
# --build-arg BASETAG=11.8.0-devel-ubuntu22.04 \
# -t kestr3l/ros2:dev-humble-cu1181d \
# -f ./Dockerfile .

# ------- BUILD COMMAND (ARM64 L4T) -------
# docker buildx build \
# --progress=plain \
# --platform=linux/arm64/v8 \
# --build-arg BASEIMAGE=nvcr.io/nvidia/l4t-ml \
# --build-arg BASETAG=r35.2.1-py3 \
# -t kestr3l/ros2:dev-humble-l4t-ml \
# -f ./Dockerfile .