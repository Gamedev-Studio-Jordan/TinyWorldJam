extends StaticBody3D

@export var planet_radius: float = 10.0
@export var gravity_strength: float = 20.0  # Stronger default gravity

func _ready():
	# Automatically set radius based on collision shape if available
	var collision_shape = get_node_or_null("CollisionShape3D")
	if collision_shape and collision_shape.shape is SphereShape3D:
		planet_radius = collision_shape.shape.radius
		
	# Add the gravity area if it doesn't exist
	if not has_node("GravityArea"):
		var gravity_area = Area3D.new()
		gravity_area.name = "GravityArea"
		var collision = CollisionShape3D.new()
		collision.shape = SphereShape3D.new()
		collision.shape.radius = planet_radius * 2.0  # Much larger gravity field
		gravity_area.add_child(collision)
		add_child(gravity_area)
		
		# Add gravity area script
		gravity_area.set_script(load("res://gravity_area.gd"))
		gravity_area.gravity_strength = gravity_strength

func get_planet_radius():
	return planet_radius

func get_gravity_strength():
	return gravity_strength
