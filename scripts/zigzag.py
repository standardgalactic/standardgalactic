import bpy
import random
from mathutils import Vector

def clear_scene():
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete()

def add_branch(parent_point, curve_data, depth=0, max_depth=3):
    if depth > max_depth:
        return
    
    # Generate a branch from the parent point
    direction = Vector((random.uniform(-1, 1), random.uniform(-1, 1), random.uniform(-1, 1))).normalized()
    length = random.uniform(1, 3)
    child_point = parent_point + direction * length

    spline = curve_data.splines.new('BEZIER')
    spline.bezier_points.add(1)
    p0, p1 = spline.bezier_points[0], spline.bezier_points[1]
    p0.co = parent_point
    p1.co = child_point
    p0.handle_left_type = p0.handle_right_type = 'AUTO'
    p1.handle_left_type = p1.handle_right_type = 'AUTO'
    
    # Randomly adjust handles to make the branch wavy
    p0.handle_left = p0.co - (direction * 0.5) + Vector((random.uniform(-0.5, 0.5), random.uniform(-0.5, 0.5), random.uniform(-0.5, 0.5)))
    p0.handle_right = p0.co + (direction * 0.5) + Vector((random.uniform(-0.5, 0.5), random.uniform(-0.5, 0.5), random.uniform(-0.5, 0.5)))
    p1.handle_left = p1.co - (direction * 0.5) + Vector((random.uniform(-0.5, 0.5), random.uniform(-0.5, 0.5), random.uniform(-0.5, 0.5)))
    p1.handle_right = p1.co + (direction * 0.5) + Vector((random.uniform(-0.5, 0.5), random.uniform(-0.5, 0.5), random.uniform(-0.5, 0.5)))

    # Recursively add more branches
    for _ in range(random.randint(1, 3)):  # Control number of branches from each point
        add_branch(child_point, curve_data, depth + 1, max_depth)

def create_web_structure(name, num_roots, spread, max_depth):
    # Create a curve object
    curve_data = bpy.data.curves.new(name='WebCurve', type='CURVE')
    curve_data.dimensions = '3D'
    curve_data.fill_mode = 'FULL'
    curve_data.bevel_depth = 0.02  # Control thickness of tubes
    curve_data.bevel_resolution = 2  # Control smoothness of tubes
    
    curve_obj = bpy.data.objects.new(name, curve_data)
    bpy.context.collection.objects.link(curve_obj)

    # Generate root points and branches
    for _ in range(num_roots):
        root_point = Vector((random.uniform(-spread, spread), random.uniform(-spread, spread), random.uniform(-spread, spread)))
        add_branch(root_point, curve_data, max_depth=max_depth)

# Clear the scene
clear_scene()

# Parameters: name, number of root points, spread of roots, depth of recursion
create_web_structure("ComplexWeb", 20, 10, 4)  # Adjust for more complexity or density

# Switch to object mode (needed if coming from another mode)
bpy.ops.object.mode_set(mode='OBJECT')
