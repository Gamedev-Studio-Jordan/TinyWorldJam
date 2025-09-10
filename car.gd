class_name Car extends RigidBody3D

## This is the container of the car model and the camera
@onready var car: Node3D = $Car
@onready var car_mesh: MeshInstance3D = $Car/Car

@export_category("Car")
@export var speed_force: float
@export var turn_degree: float
@export var acceleration: float = 30
@export var steering: float = 1.5
@export var effect_turn_speed: float = 0.1
@export var effect_turn_tilt: float = 0.75

@export_category("Debug")
@export var debug_force: bool = false
@export var debug_force_line: Line3D = null

var planet: Planet = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	car.top_level = true

	planet = get_tree().get_first_node_in_group("planet")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	car.global_position = global_position - Vector3(0, 0.1, 0)
	
	speed_force = Input.get_axis("front", "back") * acceleration
	turn_degree = Input.get_axis("right", "left") * deg_to_rad(steering)
	
	_curve_effect(delta)
	
	car.rotate_y(turn_degree)

	var force: Vector3 = -car.global_transform.basis.z * speed_force

	if planet:
		var gravity_centre: Vector3 = planet.get_gravity_centre()
		var direction_to_planet: Vector3 = (gravity_centre - global_position).normalized()
		
		# This creates a rotation that aligns the car with the planet
		var up_direction: Vector3 = direction_to_planet
		var forward_direction: Vector3 = car.global_transform.basis.z
		var right_direction: Vector3 = up_direction.cross(forward_direction).normalized()
		var corrected_forward: Vector3 = right_direction.cross(up_direction).normalized()
		
		# Creates a new basis with the corrected directions
		var surface_basis: Basis = Basis()
		surface_basis.x = right_direction
		surface_basis.y = up_direction
		surface_basis.z = corrected_forward
		
		if car.global_position.y - gravity_centre.y <= 0:
			surface_basis.z = -surface_basis.z
			
		force = surface_basis * Vector3(0, 0, -speed_force)

		car_mesh.global_transform.basis = Basis(surface_basis.x, -surface_basis.y, surface_basis.z)
	
	if debug_force:
		draw_line(force)
	
	apply_force(force)

func _curve_effect(delta) -> void:
	var turnStrengthValue = turn_degree * linear_velocity.length() / effect_turn_speed
	var turnTiltValue = -turn_degree * linear_velocity.length() / effect_turn_tilt
	var changeSpeed = 1
	
	if turn_degree == 0: changeSpeed = 3
	
	car_mesh.rotation.y = lerp(car_mesh.rotation.y, turnStrengthValue, changeSpeed * delta)
	car_mesh.rotation.z = lerp(car_mesh.rotation.z, turnTiltValue, changeSpeed * delta)

func draw_line(force: Vector3) -> void:
	if debug_force_line:
		debug_force_line.set_start(global_position)
		debug_force_line.set_end(global_position + force)
