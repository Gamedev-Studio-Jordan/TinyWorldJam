class_name Car extends RigidBody3D

# Car properties
@export var engine_power = 20.0
@export var steering_power = 15.0  # Back to higher steering power
@export var brake_power = 10.0
@export var max_speed = 30.0

# Gravity control
var current_gravity = Vector3.DOWN * 9.8
var current_planet = null
@export var is_on_ground = false

# Car control vars
var steering = 0.0
var acceleration = 0.0
var brake = 0.0

# Steering improvements
@export var steering_response = 8.0
var current_steering = 0.0

# Visual effects
@export var max_tilt_angle = 15.0
@onready var car_mesh = $car

# Raycast references
@onready var front_raycast: RayCast3D = $FrontRayCast
@onready var front_left_raycast: RayCast3D = $RayCastFrontLeft
@onready var front_right_raycast: RayCast3D = $RayCastFrontRight
@onready var back_left_raycast: RayCast3D = $RayCastBackLeft
@onready var back_right_raycast: RayCast3D = $RayCastBackRight

func _ready():
	# Make sure gravity is off in the rigid body settings
	gravity_scale = 0
	# Set physics material for better traction
	physics_material_override = PhysicsMaterial.new()
	physics_material_override.bounce = 0.1
	physics_material_override.friction = 1.5

func _physics_process(delta):
	# Get input
	steering = Input.get_axis("left", "right")
	acceleration = Input.get_axis("back", "front")
	brake = 1.0 if Input.is_action_pressed("ui_accept") else 0.0
	
	# Apply engine force and steering
	apply_engine_force(delta)
	apply_steering(delta)  # This uses the WORKING steering method
	
	# Apply planetary gravity - STRONG GRAVITY
	apply_planetary_gravity(delta)
	
	# Check ground contact
	check_ground()
	
	# Align car to planet surface - PROPER ALIGNMENT
	if is_on_ground:
		align_to_gravity(delta)
	
	# Limit speed to prevent flying off
	limit_speed()
	
	# Update visual effects
	update_visual_effects()

func check_ground():
	var ground_count = 0
	var rays = [front_raycast, front_left_raycast, front_right_raycast, back_left_raycast, back_right_raycast]
	
	for ray in rays:
		if ray.is_colliding():
			var distance = global_position.distance_to(ray.get_collision_point())
			if distance < 2.0:
				ground_count += 1
	
	is_on_ground = ground_count >= 2

func apply_engine_force(delta):
	if is_on_ground:
		# Apply force in the forward direction of the car
		var forward_force = -transform.basis.z * acceleration * engine_power
		apply_central_force(forward_force)
	
	# Apply braking force
	if brake > 0:
		var brake_force = -linear_velocity * brake_power
		apply_central_force(brake_force)

# WORKING STEERING METHOD - Wheel force based steering
func apply_steering(delta):
	# Smooth steering input
	current_steering = lerp(current_steering, steering, steering_response * delta)
	
	# Only steer when moving and on ground
	if is_on_ground and linear_velocity.length() > 0.5:
		# Apply steering force at wheel positions for realistic turning
		var steering_force = transform.basis.x * current_steering * steering_power
		
		# Apply force at front wheel positions for better turning
		if front_left_raycast.is_colliding():
			var front_left_pos = front_left_raycast.global_position - global_position
			apply_force(steering_force, front_left_pos)
		
		if front_right_raycast.is_colliding():
			var front_right_pos = front_right_raycast.global_position - global_position
			apply_force(steering_force, front_right_pos)

func apply_planetary_gravity(delta):
	if current_planet:
		# Calculate direction to planet center
		var to_center = current_planet.global_position - global_position
		var distance = to_center.length()
		
		# Get planet radius safely
		var planet_radius = 10.0
		if current_planet.has_method("get_planet_radius"):
			planet_radius = current_planet.get_planet_radius()
		
		# STRONG GRAVITY - increases with distance from planet
		var gravity_strength = 25.0 * (1.0 + max(0, distance - planet_radius) * 0.3)
		current_gravity = to_center.normalized() * gravity_strength
		
		# Apply gravity force
		apply_central_force(current_gravity * mass * delta * 60.0)
	else:
		# Default gravity if no planet detected
		apply_central_force(Vector3.DOWN * 25.0 * mass * delta * 60.0)

# PROPER ALIGNMENT SYSTEM - Makes car stick to planets
func align_to_gravity(delta):
	# Calculate average normal from all raycasts
	var average_normal = Vector3.ZERO
	var valid_rays = 0
	var rays = [front_raycast, front_left_raycast, front_right_raycast, back_left_raycast, back_right_raycast]
	
	for ray in rays:
		if ray.is_colliding():
			average_normal += ray.get_collision_normal()
			valid_rays += 1
	
	if valid_rays == 0:
		return
	
	average_normal = (average_normal / valid_rays).normalized()
	
	# Calculate desired up direction (opposite of gravity)
	var desired_up = -current_gravity.normalized()
	
	# Use the surface normal for alignment
	var surface_up = average_normal
	
	# Get current basis
	var current_basis = global_transform.basis
	
	# Calculate target rotation that aligns with surface
	var target_basis = align_up(current_basis, surface_up)
	
	# Smoothly interpolate towards target rotation
	global_transform.basis = global_transform.basis.slerp(target_basis, 0.2)

# Helper function to align up vector
func align_up(basis: Basis, new_up: Vector3) -> Basis:
	var rotation_axis = basis.y.cross(new_up).normalized()
	var rotation_angle = basis.y.angle_to(new_up)
	
	if rotation_axis.length_squared() > 0:
		return basis.rotated(rotation_axis, rotation_angle)
	return basis

func limit_speed():
	# Limit speed to prevent flying off planets
	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.normalized() * max_speed

func update_visual_effects():
	if not car_mesh:
		return
	
	# Calculate tilt based on steering and speed
	var tilt_amount = -current_steering * max_tilt_angle * min(linear_velocity.length() / 10.0, 1.0)
	
	# Apply tilt to mesh
	car_mesh.rotation.z = deg_to_rad(tilt_amount)

func _on_gravity_area_entered(area):
	if area.is_in_group("planet_gravity"):
		current_planet = area.get_parent()

func _on_gravity_area_exited(area):
	if area.is_in_group("planet_gravity") and area.get_parent() == current_planet:
		current_planet = null
