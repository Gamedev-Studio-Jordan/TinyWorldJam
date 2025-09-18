class_name CarBody extends StaticBody3D

@export var car: Car

func get_car_speed() -> float:
	return car.linear_velocity.length()
