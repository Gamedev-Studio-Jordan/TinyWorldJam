class_name CarCamera extends Camera3D

@export var target_path: NodePath

@export var follow_distance := 8.0
@export var height := 2.5
@export var look_at_height := 1.5
@export var lookahead_time := 0.25

@export var position_smoothing := 8.0
@export var focus_smoothing := 8.0
@export var up_smoothing := 6.0

@export var use_collision := true
@export var collision_margin := 0.25
@export var collision_mask: int = 0xFFFFFFFF

var target: Node = null
var anchor_position: Vector3
var focus_point: Vector3
var up_direction: Vector3 = Vector3.UP

func _ready():
	_set_target_from_path()
	if target == null:
		_try_autofind_target()
	if target:
		var tp = _get_target_position()
		anchor_position = tp
		focus_point = tp + Vector3.UP * look_at_height
		up_direction = _get_target_up()

func _process(delta):
	if target == null or not is_instance_valid(target):
		_try_autofind_target()
		if target == null:
			return

	# Smoothed anchor using velocity look-ahead
	var tp = _get_target_position()
	var vel = _get_target_velocity()
	var predicted = tp + vel * lookahead_time
	anchor_position = _exp_smooth_vec3(anchor_position, predicted, position_smoothing, delta)

	# Up direction derived from gravity or the target's up basis
	var desired_up = _get_target_up()
	up_direction = _exp_smooth_vec3(up_direction, desired_up, up_smoothing, delta).normalized()
	if up_direction.length() < 0.001:
		up_direction = Vector3.UP

	# Forward projected onto the tangent plane to orbit nicely around the planet
	var forward = _get_target_forward()
	var forward_on_plane = forward.slide(up_direction).normalized()
	if forward_on_plane.length() < 0.001:
		forward_on_plane = (-global_transform.basis.z).slide(up_direction).normalized()
		if forward_on_plane.length() < 0.001:
			forward_on_plane = Vector3.FORWARD

	# Desired focus and camera positions
	var desired_focus = anchor_position + up_direction * look_at_height
	focus_point = _exp_smooth_vec3(focus_point, desired_focus, focus_smoothing, delta)

	var desired_pos = focus_point - forward_on_plane * follow_distance + up_direction * height

	# Collision avoidance to prevent clipping into terrain/objects
	if use_collision:
		desired_pos = _resolve_collision(focus_point, desired_pos)

	# Apply transform
	global_position = desired_pos
	look_at(focus_point, up_direction, false)

func _set_target_from_path():
	if target_path != NodePath():
		var node = get_node_or_null(target_path)
		if node != null:
			target = node

func _try_autofind_target():
	# Search the scene tree for a RigidBody3D that exposes `current_gravity`
	var root = get_tree().get_root()
	var found = _find_first_car_like(root)
	if found:
		target = found
		return
	# Fallback heuristic: by name
	var candidates = root.find_children("car", "", true, false)
	if candidates.size() > 0:
		target = candidates[0]


func _find_first_car_like(node: Node) -> Node:
	for child in node.get_children():
		if child is RigidBody3D:
			return child
		var nested = _find_first_car_like(child)
		if nested:
			return nested
	return null

func _get_target_position() -> Vector3:
	return (target as Node3D).global_position

func _get_target_velocity() -> Vector3:
	var lv = target.get("linear_velocity") if target else null
	if lv is Vector3:
		return lv
	return Vector3.ZERO

func _get_target_forward() -> Vector3:
	var t3d := target as Node3D
	return -t3d.global_transform.basis.z

func _get_target_up() -> Vector3:
	var cg = target.get("current_gravity") if target else null
	if cg is Vector3 and cg.length() > 0.001:
		return -cg.normalized()
	var t3d := target as Node3D
	return t3d.global_transform.basis.y

func _resolve_collision(focus_from: Vector3, desired_pos: Vector3) -> Vector3:
	var space_state := get_world_3d().direct_space_state
	var params := PhysicsRayQueryParameters3D.create(focus_from, desired_pos)
	params.collision_mask = collision_mask
	if target is PhysicsBody3D:
		params.exclude = [ (target as PhysicsBody3D).get_rid() ]
	var hit = space_state.intersect_ray(params)
	if hit.is_empty():
		return desired_pos
	return hit.position + hit.normal * collision_margin

func _exp_smooth_vec3(current_value: Vector3, target_value: Vector3, smoothing: float, delta: float) -> Vector3:
	if smoothing <= 0.0:
		return target_value
	var t = 1.0 - exp(-smoothing * delta)
	return current_value.lerp(target_value, clamp(t, 0.0, 1.0))