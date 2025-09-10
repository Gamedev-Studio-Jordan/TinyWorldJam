extends Node

@export var explosion_power_multiplier: float = 1.0

func _on_destroy_button_pressed() -> void:
	var destructible_objects = get_tree().get_nodes_in_group("destructible")
	for destructible_object in destructible_objects:
		destructible_object.destroy_object(explosion_power_multiplier)
