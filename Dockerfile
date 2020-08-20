FROM debian:stable-slim

LABEL maintainer="vo3xel@gmail.com"

ENV TERM linux
ENV LANGUAGE C.UTF-8
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

ENV BLENDER_VERSION 2.83.5

ARG DEBIAN_FRONTEND=noninteractive

# install necessary packages
RUN apt-get update && apt-get -y install apt-utils bzip2 \
	build-essential git whiptail locales \
	subversion cmake libx11-dev libxxf86vm-dev \
	libxcursor-dev libxi-dev libxrandr-dev libxinerama-dev \
	libglew-dev libxml2 yasm libjack-jackd2-dev sudo \
	&& rm -rf /var/lib/apt/lists/*

# user management
RUN groupadd -g 999 blender && useradd -u 999 -g blender -G sudo -m -s /bin/bash blender
RUN echo '%blender ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER blender

# clone blender and switch to specific blender release version
RUN mkdir -p /home/blender/blender-git
WORKDIR /home/blender/blender-git
RUN git clone --recursive --branch v${BLENDER_VERSION} http://git.blender.org/blender.git
WORKDIR /home/blender/blender-git/blender

# build blender dependencies
RUN ./build_files/build_environment/install_deps.sh --show-deps
RUN ./build_files/build_environment/install_deps.sh --help
RUN sudo apt-get update && sudo ./build_files/build_environment/install_deps.sh
