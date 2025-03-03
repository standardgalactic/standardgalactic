import bpy

# Clear existing objects in the scene
bpy.ops.object.select_all(action='DESELECT')
bpy.ops.object.select_by_type(type='MESH')
bpy.ops.object.delete()

# Create a new mesh object
bpy.ops.mesh.primitive_uv_sphere_add(radius=1, location=(0, 0, 0))
sphere = bpy.context.object

# Add a particle system to the sphere
mod = sphere.modifiers.new(name="Galaxy Particles", type='PARTICLE_SYSTEM')
particle_system = sphere.particle_systems[0]
ps_settings = particle_system.settings

# Set particle settings for a galaxy-like effect
ps_settings.count = 10000
ps_settings.emit_from = 'VOLUME'
ps_settings.physics_type = 'NO'
ps_settings.particle_size = 0.01

# Hide the emitter in the render
sphere.hide_render = True

# Set display as dots for faster visualization
ps_settings.display_method = 'DOT'

# Add a force field for gravity
bpy.ops.object.effector_add(type='FORCE', enter_editmode=False, location=(0, 0, 0))
force_field = bpy.context.object
force_field.field.strength = -10  # Negative value for attraction

# Run the simulation
bpy.ops.screen.animation_play()
