class_name OldPlanet extends StaticBody3D

@export var gravity: float = 9.8
@export var gravity_area: Area3D = null

func _ready() -> void:
    gravity_area.gravity = gravity

## Returns the global position of the gravity centre
func get_gravity_centre() -> Vector3:
    return gravity_area.to_global(gravity_area.gravity_point_center)