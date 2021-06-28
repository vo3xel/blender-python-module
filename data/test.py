import bpy
import sys
bpy.ops.wm.save_as_mainfile(filepath='./my.blend')
print("***********************************************************************")
print("File save OK, blender python module OK")
print("***********************************************************************")
print("Python version: " + sys.version)
path_string = "\n"
for p in sys.path:
    path_string = path_string + p + "\n"
print("***********************************************************************")
print("Python paths: " + path_string)
print("***********************************************************************")
print("Blender version: " + bpy.app.version_string)
print("***********************************************************************")