#!/bin/sh

echo "Current blender version: $1"
echo "Current precompiled libs version: $2"
echo "Current blender python version: $3"

docker build --no-cache --build-arg BLENDER_VERSION_STRING="$1" --build-arg BLENDER_PRECOMPILED_LIBS_VERSION_STRING="$2" --build-arg BLENDER_PYTHON_VERSION="$3" -t vo3xel/blender-python-module:"$1"-build-env -f build-env.Dockerfile .

docker build --no-cache --build-arg BLENDER_VERSION_STRING="$1" -t vo3xel/blender-python-module:"$1" -f release-precompiled-deps.Dockerfile .

docker run -v $PWD/data:/home/blender/data vo3xel/blender-python-module:"$1" test.py

BLENDER_TEST_FILE=./data/my.blend

if test -f "$BLENDER_TEST_FILE"; then
    echo "***********************************************************************"
    echo "Blender python module test OK"
    echo "***********************************************************************"
    docker login
    docker push vo3xel/blender-python-module:"$1"-build-env
    docker push vo3xel/blender-python-module:"$1"
else
    echo "***********************************************************************"
    echo "Blender python module test failed"
    echo "***********************************************************************"
fi