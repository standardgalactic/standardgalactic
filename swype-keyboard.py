import bpy
import math

# QWERTY keyboard layout coordinates
KEYBOARD = {
    'q': (0, 0), 'w': (1, 0), 'e': (2, 0), 'r': (3, 0), 't': (4, 0),
    'y': (5, 0), 'u': (6, 0), 'i': (7, 0), 'o': (8, 0), 'p': (9, 0),
    'a': (0, -1), 's': (1, -1), 'd': (2, -1), 'f': (3, -1), 'g': (4, -1),
    'h': (5, -1), 'j': (6, -1), 'k': (7, -1), 'l': (8, -1),
    'z': (0, -2), 'x': (1, -2), 'c': (2, -2), 'v': (3, -2), 'b': (4, -2),
    'n': (5, -2), 'm': (6, -2)
}

def create_swipe_curve(word, is_3d=False, height_factor=0.5, position=(0, 0, 0)):
    curve_data = bpy.data.curves.new(name=f"Swype_{word}", type='CURVE')
    curve_data.dimensions = '3D' if is_3d else '2D'
    
    spline = curve_data.splines.new('POLY')
    word = word.lower()
    spline.points.add(len(word) - 1)
    
    for i, char in enumerate(word):
        if char in KEYBOARD:
            x, y = KEYBOARD[char]
            if is_3d:
                z = math.sin(i/len(word) * math.pi * 2) * height_factor
                spline.points[i].co = (x, y, z, 1)
            else:
                spline.points[i].co = (x, y, 0, 1)
    
    curve_obj = bpy.data.objects.new(f"Swype_{word}", curve_data)
    bpy.context.collection.objects.link(curve_obj)
    curve_obj.location = position
    curve_data.bevel_depth = 0.1
    curve_data.bevel_resolution = 4
    
    return curve_obj

def create_projection_plane(word, position=(0, 0, 0)):
    # Create larger plane under each curve
    bpy.ops.mesh.primitive_plane_add(size=7, location=(position[0], position[1], position[2]))
    plane = bpy.context.active_object
    plane.name = f"Projection_{word}"
    
    # Create material with grid
    mat = bpy.data.materials.new(name=f"Proj_Mat_{word}")
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    nodes.clear()
    
    principled = nodes.new('ShaderNodeBsdfPrincipled')
    output = nodes.new('ShaderNodeOutputMaterial')
    mat.node_tree.links.new(principled.outputs['BSDF'], output.inputs['Surface'])
    
    plane.data.materials.append(mat)
    
    # Add 2D path projection as curve on plane
    curve_data = bpy.data.curves.new(name=f"Proj_Curve_{word}", type='CURVE')
    curve_data.dimensions = '2D'
    spline = curve_data.splines.new('POLY')
    word = word.lower()
    spline.points.add(len(word) - 1)
    
    for i, char in enumerate(word):
        if char in KEYBOARD:
            x, y = KEYBOARD[char]
            spline.points[i].co = (x * 0.7 - 3, y * 0.7 + 2, 0, 1)  # Adjusted for larger plane
    
    proj_curve = bpy.data.objects.new(f"Proj_Curve_{word}", curve_data)
    proj_curve.location = (position[0], position[1], position[2] + 0.01)
    bpy.context.collection.objects.link(proj_curve)
    curve_data.bevel_depth = 0.05
    
    # Add label above plane
    bpy.ops.object.text_add(location=(position[0], position[1], position[2] + 0.02))
    text = bpy.context.active_object
    text.data.body = word.upper()
    text.scale = (0.7, 0.7, 0.7)  # Slightly larger text
    text.rotation_euler = (0, 0, 0)  # Facing up

def create_word_grid(words, cols=3, spacing=8):
    for i, word in enumerate(words):
        row = i // cols
        col = i % cols
        pos = (col * spacing - spacing*(cols-1)/2, row * spacing, 0)
        
        # 3D version - raised higher
        create_swipe_curve(word, is_3d=True, position=(pos[0], pos[1], pos[2] + 5))
        
        # Create projection plane with 2D path and label
        create_projection_plane(word, position=pos)

def main():
    # Clear existing objects
    bpy.ops.object.select_all(action='DESELECT')
    bpy.ops.object.select_by_type(type='CURVE')
    bpy.ops.object.select_by_type(type='MESH')
    bpy.ops.object.select_by_type(type='FONT')
    bpy.ops.object.delete()
    
    # Sample words for grid with "swype"
    sample_words = [
        "magic", "swype", "hello",
        "curve", "twist", "blend",
        "trace", "path", "loop"
    ]
    
    # Create grid of words with projections
    create_word_grid(sample_words, cols=3, spacing=8)
    
    # Set up camera
    bpy.ops.object.camera_add(location=(0, -30, 20))
    cam = bpy.context.active_object
    cam.rotation_euler = (math.radians(60), 0, 0)
    bpy.context.scene.camera = cam

if __name__ == "__main__":
    main()