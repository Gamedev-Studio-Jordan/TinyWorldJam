class_name Car extends RigidBody3D

## This is the container of the car model and the camera
@onready var car: Node3D = $Car
@onready var car_mesh: MeshInstance3D = $Car/Car

@export_category("Car")
var speed_force: float
var turn_degree: float
@export var acceleration: float = 30
@export var steering: float = 1.5
@export var effect_turn_speed: float = 0.1
@export var effect_turn_tilt: float = 0.75

@export_category("Debug")
@export var debug_force: bool = false
@export var debug_force_line: Line3D = null
@export var debug_forward_line: Line3D = null

var planet: Planet = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	car.top_level = true
	planet = get_tree().get_first_node_in_group("planet")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	car.global_position = global_position - Vector3(0, 0.1, 0)
	
	var back_front_axis = Input.get_axis("back", "front")
	speed_force = back_front_axis * acceleration
	turn_degree = Input.get_axis("right", "left") * deg_to_rad(steering) if back_front_axis != 0.0 else 0.0
	
	_curve_effect(delta)
	
	# Apply turning to the car visual
	car.rotate_y(turn_degree)
	
	if planet:
		var gravity_centre: Vector3 = planet.get_gravity_centre()
		var direction_to_planet: Vector3 = (gravity_centre - global_position).normalized()
		
		# Align the car with the planet surface
		var current_basis = car.global_transform.basis
		var new_y = direction_to_planet
		var new_z = current_basis.z - new_y * current_basis.z.dot(new_y)
		new_z = new_z.normalized()
		var new_x = new_y.cross(new_z).normalized()
		
		# Create the new basis for the car
		var surface_basis = Basis(new_x, new_y, new_z)
		car.global_transform.basis = surface_basis
		
		# Apply force in the car's forward direction (relative to the planet surface)
		var force = -car.global_transform.basis.z * speed_force
		
		if debug_force:
			draw_line(force, debug_force_line)
		
		apply_force(force)

func _curve_effect(delta) -> void:
	var turnStrengthValue = turn_degree * linear_velocity.length() / effect_turn_speed
	var turnTiltValue = -turn_degree * linear_velocity.length() / effect_turn_tilt
	var changeSpeed = 1
	
	if turn_degree == 0: changeSpeed = 3
	
	car_mesh.rotation.y = lerp(car_mesh.rotation.y, turnStrengthValue, changeSpeed * delta)
	car_mesh.rotation.z = lerp(car_mesh.rotation.z, turnTiltValue, changeSpeed * delta)

func draw_line(force: Vector3, line: Line3D) -> void:
	if line:
		line.set_start(global_position)
		line.set_end(global_position + force)

func get_car_up() -> Vector3:
	return car.global_transform.basis.y

func get_direction_car_is_facing() -> Vector3:
	draw_line(car_mesh.global_transform.basis.z, debug_forward_line)
	return car_mesh.global_transform.basis.z