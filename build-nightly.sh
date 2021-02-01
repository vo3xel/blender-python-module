#!/bin/sh
docker build -t vo3xel/blender-python-module:nightly-precompiled-deps-$(date +%s) -f nightly-precompiled-deps.Dockerfile .
docker build -t vo3xel/blender-python-module:nightly-$(date +%s) -f nightly.Dockerfile .