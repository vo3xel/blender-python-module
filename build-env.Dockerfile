FROM ubuntu:focal

LABEL org.opencontainers.image.authors="vo3xel <mail@vo3xel.xyz>"
LABEL org.opencontainers.image.title="Blender Python module"
LABEL org.opencontainers.artifact.description="Blender compiled as python module"
LABEL org.opencontainers.image.source="https://github.com/vo3xel/blender-python-module.git"
LABEL org.opencontainers.image.licenses="GPL-3.0-only"
LABEL org.opencontainers.image.version="v1.3.3"

ARG BLENDER_VERSION_STRING
ARG BLENDER_PRECOMPILED_LIBS_VERSION_STRING
ARG BLENDER_PYTHON_VERSION

ENV TERM linux
ENV LANGUAGE C.UTF-8
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

ARG DEBIAN_FRONTEND=noninteractive

ENV BLENDER_VERSION_STRING=$BLENDER_VERSION_STRING
ENV BLENDER_PRECOMPILED_LIBS_VERSION_STRING=$BLENDER_PRECOMPILED_LIBS_VERSION_STRING
ENV BLENDER_PYTHON_VERSION=$BLENDER_PYTHON_VERSION

# install necessary packages
RUN apt-get update && apt-get -y install \ 
	bison autoconf automake libtool yasm nasm tcl libasound2-dev \
	libsndio-dev portaudio19-dev libportaudio2 pulseaudio libpulse-dev \
	curl apt-utils software-properties-common build-essential \
	git subversion cmake libx11-dev libxxf86vm-dev libxcursor-dev \
	libxi-dev libxrandr-dev libxinerama-dev libglew-dev \
	&& rm -rf /var/lib/apt/lists/*

RUN add-apt-repository ppa:deadsnakes/ppa
RUN apt-get update && apt-get -y install python${BLENDER_PYTHON_VERSION} python${BLENDER_PYTHON_VERSION}-dev python${BLENDER_PYTHON_VERSION}-distutils
RUN rm /usr/bin/python3 && ln -s python${BLENDER_PYTHON_VERSION} /usr/bin/python3
RUN curl https://bootstrap.pypa.io/get-pip.py | python3

# clone blender
RUN mkdir -p /home/blender/blender-git
WORKDIR /home/blender/blender-git
RUN git clone --recursive --branch v${BLENDER_VERSION_STRING} http://git.blender.org/blender.git

# download precompiled libs
RUN mkdir -p /home/blender/blender-git/lib
WORKDIR /home/blender/blender-git/lib
RUN svn checkout https://svn.blender.org/svnroot/bf-blender/tags/${BLENDER_PRECOMPILED_LIBS_VERSION_STRING}/lib/linux_centos7_x86_64/
WORKDIR /home/blender/blender-git/blender
