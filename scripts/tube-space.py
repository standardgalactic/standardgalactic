import bpy
import random

def clear_scene():
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete()

def create_web_mesh(name, num_verts, link_distance):
    # Create a new mesh and an object
    mesh = bpy.data.meshes.new(name)
    obj = bpy.data.objects.new(name, mesh)

    # Link the object to the scene
    bpy.context.collection.objects.link(obj)
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)

    # Prepare mesh data
    verts = [(random.uniform(-10, 10), random.uniform(-10, 10), random.uniform(-10, 10)) for _ in range(num_verts)]
    edges = []

    # Connect vertices that are close enough
    for i in range(num_verts):
        for j in range(i + 1, num_verts):
            if (verts[i][0] - verts[j][0])**2 + (verts[i][1] - verts[j][1])**2 + (verts[i][2] - verts[j][2])**2 < link_distance**2:
                edges.append((i, j))

    # Create mesh from data
    mesh.from_pydata(verts, edges, [])
    mesh.update()

    # Add modifiers to mesh
    mod = obj.modifiers.new(name="Skin", type='SKIN')
    obj.modifiers.new(name="Subdivision", type='SUBSURF').levels = 2

    # Ensure each vertex has a skin radius
    for v in obj.data.skin_vertices[0].data:
        v.radius = 0.1, 0.1

# Clear the scene
clear_scene()

# Create web structure
create_web_mesh("CosmicWeb", 100, 3)  # Adjust number of vertices and linking distance

# Switch to object mode and select the object
bpy.ops.object.mode_set(mode='OBJECT')
