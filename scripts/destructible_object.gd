extends RigidBody3D

@export var destruction_node: Destruction
@export var explosion_power: float = 7

func destroy_object() -> void:
    destruction_node.destroy(explosion_power)