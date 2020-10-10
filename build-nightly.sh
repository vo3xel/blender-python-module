#!/bin/sh
docker build -t vo3xel/blender-lts-python-module:nightly-precompiled-deps-$(date +%s) -f nightly-precompiled-deps.Dockerfile .
docker build -t vo3xel/blender-lts-python-module:nightly-$(date +%s) -f nightly.Dockerfile .