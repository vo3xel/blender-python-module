#!/bin/sh
BLENDER_VERSION_STRING="4.0"
BLENDER_PYTHON_VERSION="3.10"

echo "Current blender version: $BLENDER_VERSION_STRING"
echo "Current blender python version: $BLENDER_PYTHON_VERSION"

BLENDER_TEST_FILE=./data/my.blend

if test -f "$BLENDER_TEST_FILE"; then
    rm -f "$BLENDER_TEST_FILE"
fi

docker build --no-cache --build-arg BLENDER_VERSION_STRING="$BLENDER_VERSION_STRING" --build-arg BLENDER_PYTHON_VERSION="$BLENDER_PYTHON_VERSION" -t vo3xel/blender-python-module:"$BLENDER_VERSION_STRING"-build-env -f v4.0-build-env.Dockerfile .

docker build --no-cache --build-arg BLENDER_VERSION_STRING="$BLENDER_VERSION_STRING" -t vo3xel/blender-python-module:"$BLENDER_VERSION_STRING" -f v4.0-release-precompiled-deps.Dockerfile .

docker run -v $PWD/data:/home/blender/data vo3xel/blender-python-module:"$BLENDER_VERSION_STRING" test.py

if test -f "$BLENDER_TEST_FILE"; then
    echo "***********************************************************************"
    echo "Blender python module test OK"
    echo "***********************************************************************"
else
    echo "***********************************************************************"
    echo "Blender python module test failed"
    echo "***********************************************************************"
fi