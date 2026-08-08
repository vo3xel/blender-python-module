# syntax=docker/dockerfile:1
#
# Builds Blender as a Python module (bpy) and packages it into a slim
# runtime image. Works for every Blender release >= 4.2 and the nightly
# main branch — the version differences are handled entirely through
# build args (see versions.json / build.sh).
#
# Build args:
#   BLENDER_GIT_REF  git tag or branch, e.g. "v4.5.12" or "main"
#   PYTHON_VERSION   Python version bundled by that Blender release, e.g. "3.11"
#   BLENDER_VERSION  human-readable version used for labels, e.g. "4.5.12"

ARG PYTHON_VERSION=3.13

###############################################################################
# Stage 1: build bpy from source with Blender's precompiled libraries
###############################################################################
FROM ubuntu:24.04 AS builder

ARG BLENDER_GIT_REF=main
ARG DEBIAN_FRONTEND=noninteractive

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# Basic build environment, per
# https://developer.blender.org/docs/handbook/building_blender/linux/
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        cmake \
        git \
        git-lfs \
        python3 \
        libx11-dev \
        libxxf86vm-dev \
        libxcursor-dev \
        libxi-dev \
        libxrandr-dev \
        libxinerama-dev \
        libegl-dev \
        libwayland-dev \
        wayland-protocols \
        libxkbcommon-dev \
        libdbus-1-dev \
        linux-libc-dev \
    && rm -rf /var/lib/apt/lists/* \
    && git lfs install --skip-smudge

# Clone from the GitHub mirror: projects.blender.org sits behind aggressive
# anti-DDoS protection and throttles concurrent CI clones. The mirror does
# not host Blender's LFS objects, hence --skip-smudge above: the clone only
# fetches pointer files, and make_update.py below pulls the real objects
# from projects.blender.org via its built-in LFS fallback remote.
WORKDIR /opt/blender-git
RUN git clone --branch "${BLENDER_GIT_REF}" --depth 1 \
        https://github.com/blender/blender.git

WORKDIR /opt/blender-git/blender

# Fetch the precompiled libraries (git-lfs submodule lib/linux_x64) that match
# the checked-out ref. They are only hosted on projects.blender.org, which may
# throttle under load — retry with a backoff; git-lfs resumes partial downloads.
RUN for attempt in 1 2 3; do \
        python3 ./build_files/utils/make_update.py --no-blender --use-linux-libraries \
            && break; \
        [ "$attempt" = 3 ] && exit 1; \
        echo "make_update failed (attempt ${attempt}), retrying in 90s..."; \
        sleep 90; \
    done \
    # materialize the main repo's LFS files (normally done by the repo-update
    # step that --no-blender skips)
    && git lfs checkout

# Build the bpy module and package it as a wheel.
RUN make bpy
RUN python3 ./build_files/utils/make_bpy_wheel.py ../build_linux_bpy/bin \
        --build-dir ../build_linux_bpy --output-dir /wheels

###############################################################################
# Stage 2: slim runtime image with matching Python
###############################################################################
FROM python:${PYTHON_VERSION}-slim-trixie

ARG BLENDER_VERSION=nightly
ARG DEBIAN_FRONTEND=noninteractive

LABEL org.opencontainers.image.authors="vo3xel <mail@vo3xel.xyz>" \
      org.opencontainers.image.title="Blender Python module" \
      org.opencontainers.image.description="Blender compiled as Python module (bpy)" \
      org.opencontainers.image.source="https://github.com/vo3xel/blender-python-module" \
      org.opencontainers.image.licenses="GPL-3.0-only" \
      org.opencontainers.image.version="${BLENDER_VERSION}"

# Shared libraries bpy still needs at runtime (headless).
RUN apt-get update && apt-get install -y --no-install-recommends \
        libx11-6 \
        libxi6 \
        libxxf86vm1 \
        libxfixes3 \
        libxrender1 \
        libxkbcommon0 \
        libgl1 \
        libegl1 \
        libsm6 \
    && rm -rf /var/lib/apt/lists/*

RUN --mount=type=bind,from=builder,source=/wheels,target=/wheels \
    pip install --no-cache-dir /wheels/*.whl

RUN useradd --create-home blender \
    && mkdir -p /home/blender/data \
    && chown -R blender:blender /home/blender
USER blender
WORKDIR /home/blender/data

ENTRYPOINT ["python3"]
CMD ["-c", "import bpy; print(bpy.app.version_string)"]
