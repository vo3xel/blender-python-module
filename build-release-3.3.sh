#!/bin/sh
BLENDER_VERSION_STRING="3.3.0"
BLENDER_PRECOMPILED_LIBS_VERSION_STRING="blender-3.3-release"
BLENDER_PYTHON_VERSION="3.10"

./build-release-precompiled-deps.sh "$BLENDER_VERSION_STRING" "$BLENDER_PRECOMPILED_LIBS_VERSION_STRING" "$BLENDER_PYTHON_VERSION"