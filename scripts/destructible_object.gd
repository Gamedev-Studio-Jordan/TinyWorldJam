extends RigidBody3D

@export var destruction_node: Destruction
@export var explosion_power: float = 7

func destroy_object(explosion_power_multiplier: float = 1.0) -> void:
    destruction_node.destroy(explosion_power * explosion_power_multiplier)