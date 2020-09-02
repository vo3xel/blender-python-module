import bpy

bpy.ops.wm.save_as_mainfile(filepath='./my.blend')
print(bpy.app.version_string)