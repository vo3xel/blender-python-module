#!/bin/sh
BLENDER_MAJOR=$(curl -vs https://git.blender.org/gitweb/gitweb.cgi/blender.git/blob_plain/refs/heads/master:/source/blender/blenkernel/BKE_blender_version.h 2>&1 | grep "BLENDER_VERSION " | cut -d' ' -f3 | cut -c 1-1)
BLENDER_MINOR=$(curl -vs https://git.blender.org/gitweb/gitweb.cgi/blender.git/blob_plain/refs/heads/master:/source/blender/blenkernel/BKE_blender_version.h 2>&1 | grep "BLENDER_VERSION " | cut -d' ' -f3 | cut -c 2-3)
BLENDER_VERSION_PATCH=$(curl -vs https://git.blender.org/gitweb/gitweb.cgi/blender.git/blob_plain/refs/heads/master:/source/blender/blenkernel/BKE_blender_version.h 2>&1 | grep "BLENDER_VERSION_PATCH " | cut -d' ' -f3)
BLENDER_VERSION_CYCLE=$(curl -vs https://git.blender.org/gitweb/gitweb.cgi/blender.git/blob_plain/refs/heads/master:/source/blender/blenkernel/BKE_blender_version.h 2>&1 | grep "BLENDER_VERSION_CYCLE " | cut -d' ' -f3)

BLENDER_VERSION_STRING="${BLENDER_MAJOR}.${BLENDER_MINOR}.${BLENDER_VERSION_PATCH}-${BLENDER_VERSION_CYCLE}"

echo "Current blender version: ${BLENDER_VERSION_STRING}"

docker build --build-arg BLENDER_VERSION_STRING="$BLENDER_VERSION_STRING" -t vo3xel/blender-python-module:"nightly-$BLENDER_VERSION_STRING" -f nightly-precompiled-deps.Dockerfile .

docker run -v $PWD/data:/home/blender/data vo3xel/blender-python-module:"nightly-$BLENDER_VERSION_STRING" test.py

BLENDER_TEST_FILE=./data/my.blend
if test -f "$BLENDER_TEST_FILE"; then
    echo "***********************************************************************"
    echo "Blender python module test OK"
    echo "***********************************************************************"
else
    echo "***********************************************************************"
    echo "Blender python module test failed"
    echo "***********************************************************************"
fi
