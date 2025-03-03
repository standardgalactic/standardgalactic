import bpy
import math

# Clear existing objects
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete()

# Create the sphere
bpy.ops.mesh.primitive_uv_sphere_add(radius=1, location=(0, 0, 0), segments=64, ring_count=32)
sphere = bpy.context.active_object
sphere.name = "EarthSphere"

# Function to create and rotate a torus
def create_torus(name, x_rot=0, y_rot=0, z_rot=0, major_radius=1.03, minor_radius=0.01):
    bpy.ops.mesh.primitive_torus_add(
        major_radius=major_radius,
        minor_radius=minor_radius,
        major_segments=64,
        minor_segments=16,
        location=(0, 0, 0)
    )
    torus = bpy.context.active_object
    torus.name = name
    torus.rotation_euler = (math.radians(x_rot), math.radians(y_rot), math.radians(z_rot))
    return torus

# Create exactly 9 orthodromes
# 1. Equator
create_torus("Equator", x_rot=0, y_rot=0, z_rot=0)

# 2-5. First tetraorthodrome (4 polar orthodromes, vertical, 45° increments)
create_torus("Tetra1_0", x_rot=0, y_rot=90, z_rot=0)    # 0°
create_torus("Tetra1_1", x_rot=0, y_rot=90, z_rot=45)   # 45°
create_torus("Tetra1_2", x_rot=0, y_rot=90, z_rot=90)   # 90°
create_torus("Tetra1_3", x_rot=0, y_rot=90, z_rot=135)  # 135°

# 6-9. Second tetraorthodrome (4 tilted orthodromes at 55°, 90° increments)
create_torus("Tetra2_0", x_rot=55, y_rot=0, z_rot=0)    # 0°
create_torus("Tetra2_1", x_rot=55, y_rot=0, z_rot=90)   # 90°
create_torus("Tetra2_2", x_rot=55, y_rot=0, z_rot=180)  # 180°
create_torus("Tetra2_3", x_rot=55, y_rot=0, z_rot=270)  # 270°

# Set material for sphere (blue)
mat_sphere = bpy.data.materials.new(name="EarthMaterial")
mat_sphere.use_nodes = True
nodes = mat_sphere.node_tree.nodes
nodes.clear()
principled = nodes.new("ShaderNodeBsdfPrincipled")
principled.inputs["Base Color"].default_value = (0, 0, 1, 1)
output = nodes.new("ShaderNodeOutputMaterial")
mat_sphere.node_tree.links.new(principled.outputs["BSDF"], output.inputs["Surface"])
sphere.data.materials.append(mat_sphere)

# Set material for orthodromes (red)
for obj in bpy.data.objects:
    if "Tetra" in obj.name or "Equator" in obj.name:
        mat = bpy.data.materials.new(name=f"TorusMat_{obj.name}")
        mat.use_nodes = True
        nodes = mat.node_tree.nodes
        nodes.clear()
        principled = nodes.new("ShaderNodeBsdfPrincipled")
        principled.inputs["Base Color"].default_value = (1, 0, 0, 1)
        output = nodes.new("ShaderNodeOutputMaterial")
        mat.node_tree.links.new(principled.outputs["BSDF"], output.inputs["Surface"])
        obj.data.materials.append(mat)

# Set smooth shading for all objects
for obj in bpy.data.objects:
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.shade_smooth()

# Deselect all
bpy.ops.object.select_all(action='DESELECT')

# Verify object count
torus_count = sum(1 for obj in bpy.data.objects if "Tetra" in obj.name or "Equator" in obj.name)
print(f"Created {torus_count} orthodrome toruses (expected 9) and 1 sphere.")

# Ensure visibility
for obj in bpy.data.objects:
    obj.hide_viewport = False
    obj.hide_render = False