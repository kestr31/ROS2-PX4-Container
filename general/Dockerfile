FROM docker.io/kestr3l/ros2:galactic-cuda-tensorrt-full AS apt_cache

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV \
    DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

RUN \
    rm -rf /etc/apt/apt.conf.d/docker-clean \
	&& echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache \
	&& apt-get update

FROM docker.io/kestr3l/ros2:galactic-cuda-tensorrt-gazebo AS app

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV \
    DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

COPY aptDeps.txt /tmp/aptDeps.txt

# INSTALL APT DEPENDENCIES USING CACHE OF apt_cache
RUN \
    --mount=type=cache,target=/var/cache/apt,from=apt_cache,source=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt,from=apt_cache,source=/var/lib/apt \
    --mount=type=cache,target=/etc/apt/sources.list.d,from=apt_cache,source=/etc/apt/sources.list.d \
	apt-get install --no-install-recommends -y $(cat /tmp/aptDeps.txt) \
    && rm -rf /tmp/*

COPY pyDeps.txt /tmp/pyDeps.txt

# INSTALL PYTHON DEPENDENCIES
RUN \
    pip3 install --no-cache-dir -r /tmp/pyDeps.txt \
    && rm -rf /tmp/*

# docker build -t kestr3l/sitl-ros2:galactic-cuda-tensorrt-full -f Dockerfile .