class_name CarCamera extends Camera3D

@export var car: Car = null
@export var distance_from_car: float = 10
@export var enable_smoothing: bool = true
@export var smooth_speed: float = 10.0

func _process(_delta: float) -> void:
	var target_position = car.global_position + car.get_car_up() * -distance_from_car
	global_position = global_position.lerp(target_position, smooth_speed * _delta)
	
	face_car()

func face_car() -> void:
	look_at(car.global_position, -car.get_car_up())
