FROM ubuntu:focal

LABEL maintainer="vo3xel@gmail.com"

ENV TERM linux
ENV LANGUAGE C.UTF-8
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

ENV BLENDER_VERSION 2.83.5

ARG DEBIAN_FRONTEND=noninteractive

# install necessary packages
RUN apt-get update && apt-get -y install apt-utils software-properties-common build-essential \
	git subversion cmake libx11-dev libxxf86vm-dev libxcursor-dev \
	libxi-dev libxrandr-dev libxinerama-dev libglew-dev \
	&& rm -rf /var/lib/apt/lists/*

RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt-get update && apt-get -y install python3.7
RUN rm /usr/bin/python3 && ln -s python3.7 /usr/bin/python3

# user management
RUN groupadd -g 999 blender && useradd -u 999 -g blender -G sudo -m -s /bin/bash blender
RUN echo '%blender ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER blender

# clone blender
RUN mkdir -p /home/blender/blender-git
WORKDIR /home/blender/blender-git
RUN git clone http://git.blender.org/blender.git

# download precompiled libs
RUN mkdir -p /home/blender/blender-git/lib
WORKDIR /home/blender/blender-git/lib
RUN svn checkout https://svn.blender.org/svnroot/bf-blender/trunk/lib/linux_centos7_x86_64

# build blender full
WORKDIR /home/blender/blender-git/blender
RUN git checkout --recurse-submodules v2.83.5
RUN make

# copy adapted bpy cmake file
COPY ./bpy_module.cmake /home/blender/blender-git/blender/build_files/cmake/config/bpy_module.cmake
RUN make bpy

RUN python3 -c "import bpy ; bpy.ops.render.render(write_still=True)"
