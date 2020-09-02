FROM vo3xel/blender-lts-python-module:latest-source

# copy adapted bpy cmake file
COPY ./bpy_module.cmake /home/blender/blender-git/blender/build_files/cmake/config/bpy_module.cmake
RUN make bpy

ENV PYTHONPATH="${PYTHONPATH}:/home/blender/blender-git/lib/linux_centos7_x86_64/python/lib/python3.7/site-packages"

RUN mkdir -p /home/blender/data
WORKDIR /home/blender/data

ENTRYPOINT ["python3"]
CMD ["-c","import bpy; bpy.ops.wm.save_as_mainfile(filepath='./my.blend'); print(bpy.app.version_string);"]