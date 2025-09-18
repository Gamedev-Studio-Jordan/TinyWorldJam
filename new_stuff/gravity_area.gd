extends Area3D

@export var gravity_strength = 20.0  # Stronger default

func _ready():
	add_to_group("planet_gravity")
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)

func _on_body_entered(body):
	if body.has_method("_on_gravity_area_entered"):
		body._on_gravity_area_entered(self)

func _on_body_exited(body):
	if body.has_method("_on_gravity_area_exited"):
		body._on_gravity_area_exited(self)
