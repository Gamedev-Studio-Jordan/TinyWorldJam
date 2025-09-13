class_name DestructibleObject extends RigidBody3D

@export var destruction_node: Destruction
@export var explosion_power: float = 7
@export var points_upon_destruction: int = 10
## The necessary speed from the car to destroy the object
@export var speed_to_destroy: float = 10.0

signal destroyed(points: int)

func destroy_object(explosion_power_multiplier: float = 1.0) -> void:
	destruction_node.destroy(explosion_power * explosion_power_multiplier)
	destroyed.emit(points_upon_destruction)

func _on_body_entered(body:Node) -> void:
	print(body)
	if body is Car:
		print(body.get_current_speed())
		if body.get_current_speed() >= speed_to_destroy:
			destroy_object(explosion_power)
