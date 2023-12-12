ARG BLENDER_VERSION_STRING

FROM vo3xel/blender-python-module:${BLENDER_VERSION_STRING}-build-env
LABEL maintainer="gh@v3x.xyz"+

WORKDIR /home/blender/blender-git/blender
RUN make bpy

ENV PYTHONPATH="${PYTHONPATH}:/home/blender/blender-git/build_linux_bpy/bin:/home/blender/blender-git/lib/linux_x86_64_glibc_228/python/lib/python${BLENDER_PYTHON_VERSION}/site-packages"

RUN mkdir -p /home/blender/data
WORKDIR /home/blender/data

ENTRYPOINT ["python3"]
CMD ["-c","import bpy; bpy.ops.wm.save_as_mainfile(filepath='/home/blender/my.blend'); print(bpy.app.version_string);"]
