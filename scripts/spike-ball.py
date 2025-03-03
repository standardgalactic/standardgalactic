import bpy
import random
from mathutils import Vector

def clear_scene():
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete()

def create_web_structure(name, num_points, spread, branches, chance_to_branch):
    # Create a curve object
    curve_data = bpy.data.curves.new(name='WebCurve', type='CURVE')
    curve_data.dimensions = '3D'
    curve_data.fill_mode = 'FULL'
    curve_data.bevel_depth = 0.02
    curve_data.bevel_resolution = 2
    
    curve_obj = bpy.data.objects.new(name, curve_data)
    bpy.context.collection.objects.link(curve_obj)

    # Generate points and branches
    points = [Vector((random.uniform(-spread, spread), random.uniform(-spread, spread), random.uniform(-spread, spread))) for _ in range(num_points)]
    for point in points:
        spline = curve_data.splines.new('BEZIER')
        spline.bezier_points.add(1)
        p0, p1 = spline.bezier_points[0], spline.bezier_points[1]
        p0.co = point
        p0.handle_left_type = p0.handle_right_type = 'AUTO'
        direction = Vector((random.uniform(-1, 1), random.uniform(-1, 1), random.uniform(-1, 1))).normalized() * random.uniform(0.5, 1.5)
        p1.co = p0.co + direction
        p1.handle_left_type = p1.handle_right_type = 'AUTO'

        # Branching
        for _ in range(branches):
            if random.random() < chance_to_branch:
                direction = Vector((random.uniform(-1, 1), random.uniform(-1, 1), random.uniform(-1, 1))).normalized() * random.uniform(0.5, 1.5)
                branch_point = p1.co + direction
                spline = curve_data.splines.new('BEZIER')
                spline.bezier_points.add(1)
                p0, p1 = spline.bezier_points[0], spline.bezier_points[1]
                p0.co = p1.co
                p1.co = branch_point
                p0.handle_left_type = p0.handle_right_type = 'AUTO'
                p1.handle_left_type = p1.handle_right_type = 'AUTO'

# Clear the scene
clear_scene()

# Parameters: name, number of initial points, spread of points, number of branches, chance of branching
create_web_structure("CosmicWeb", 10, 10, 3, 0.5)

# Switch to object mode (needed if coming from another mode)
bpy.ops.object.mode_set(mode='OBJECT')
