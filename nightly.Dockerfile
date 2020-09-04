
FROM ubuntu:focal

LABEL maintainer="vo3xel@gmail.com"

ENV TERM linux
ENV LANGUAGE C.UTF-8
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

ARG DEBIAN_FRONTEND=noninteractive

# install necessary packages
RUN apt-get update && apt-get -y install \ 
	bison autoconf automake libtool yasm nasm tcl libasound2-dev \
	curl apt-utils software-properties-common build-essential \
	git subversion cmake libx11-dev libxxf86vm-dev libxcursor-dev \
	libxi-dev libxrandr-dev libxinerama-dev libglew-dev \
	&& rm -rf /var/lib/apt/lists/*

RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt-get update && apt-get -y install python3.7
RUN rm /usr/bin/python3 && ln -s python3.7 /usr/bin/python3
RUN curl https://bootstrap.pypa.io/get-pip.py | python3

# user management
RUN groupadd -g 999 blender && useradd -u 999 -g blender -G sudo -m -s /bin/bash blender
USER blender

# clone blender
RUN mkdir -p /home/blender/blender-git
WORKDIR /home/blender/blender-git
RUN git clone http://git.blender.org/blender.git

# download precompiled libs
# RUN mkdir -p /home/blender/blender-git/lib
# WORKDIR /home/blender/blender-git/lib
# RUN svn checkout https://svn.blender.org/svnroot/bf-blender/trunk/lib/linux_centos7_x86_64

# build blender as python module
WORKDIR /home/blender/blender-git/blender
RUN make update
RUN make deps
RUN make bpy

ENV PYTHONPATH="${PYTHONPATH}:/home/blender/blender-git/lib/linux_centos7_x86_64/python/lib/python3.7/site-packages"

RUN mkdir -p /home/blender/data
WORKDIR /home/blender/data

ENTRYPOINT ["python3"]
CMD ["-c","import bpy; bpy.ops.wm.save_as_mainfile(filepath='./my.blend'); print(bpy.app.version_string);"]
