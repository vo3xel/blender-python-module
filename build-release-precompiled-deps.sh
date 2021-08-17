#!/bin/sh
BLENDER_VERSION_STRING="2.93.2" # change as you like

echo "Current blender version: ${BLENDER_VERSION_STRING}"

docker build --build-arg BLENDER_VERSION_STRING="$BLENDER_VERSION_STRING" -t vo3xel/blender-python-module:"$BLENDER_VERSION_STRING" -f release-precompiled-deps.Dockerfile .

docker run -v $PWD/data:/home/blender/data vo3xel/blender-python-module:"$BLENDER_VERSION_STRING" test.py

BLENDER_TEST_FILE=./data/my.blend
if test -f "$BLENDER_TEST_FILE"; then
    echo "***********************************************************************"
    echo "Blender python module test OK"
    echo "***********************************************************************"
    docker login
    docker push vo3xel/blender-python-module:"$BLENDER_VERSION_STRING"
    docker tag vo3xel/blender-python-module:"$BLENDER_VERSION_STRING" vo3xel/blender-python-module:latest
    docker push vo3xel/blender-python-module:latest
else
    echo "***********************************************************************"
    echo "Blender python module test failed"
    echo "***********************************************************************"
fi