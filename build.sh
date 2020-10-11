#!/bin/sh
docker build -t vo3xel/blender-lts-python-module:latest-source -f source.Dockerfile .
docker build -t vo3xel/blender-lts-python-module:latest -f build.Dockerfile .