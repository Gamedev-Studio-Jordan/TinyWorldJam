extends RigidBody3D

@onready var car: Node3D = $Car
@onready var carMesh: MeshInstance3D = $Car/Car

@export var speedForce: float
@export var turnDegree: float

@export var acceleration: float = 30
@export var steering: float = 1.5
@export var effectTurnSpeed: float = 0.1
@export var effectTurnTilt: float = 0.75

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	car.top_level = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	car.global_position = global_position - Vector3(0, 0.1, 0)
	
	speedForce = Input.get_axis("front", "back") * acceleration
	turnDegree = Input.get_axis("right", "left") * deg_to_rad(steering)
	
	_curve_effect(delta)
	
	car.rotate_y(turnDegree)
	
	apply_force(-car.global_transform.basis.z * speedForce)

func _curve_effect(delta) -> void:
	var turnStrengthValue = turnDegree * linear_velocity.length() / effectTurnSpeed
	var turnTiltValue = -turnDegree * linear_velocity.length() / effectTurnTilt
	var changeSpeed = 1
	
	if turnDegree == 0: changeSpeed = 3
	
	carMesh.rotation.y = lerp(carMesh.rotation.y, turnStrengthValue, changeSpeed * delta)
	carMesh.rotation.z = lerp(carMesh.rotation.z, turnTiltValue, changeSpeed * delta)
