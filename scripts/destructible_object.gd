class_name DestructibleObject extends RigidBody3D

@export var destruction_node: Destruction
@export var explosion_power: float = 7
@export var points_upon_destruction: int = 10
@export var speed_needed_to_destroy: float = 1.0

signal destroyed(points: int)

func destroy_object(explosion_power_multiplier: float = 1.0) -> void:
    destruction_node.destroy(explosion_power * explosion_power_multiplier)
    destroyed.emit(points_upon_destruction)

func _on_body_entered(body: Node) -> void:
    if body is CarBody:
        if body.get_car_speed() > speed_needed_to_destroy:
            destroy_object()