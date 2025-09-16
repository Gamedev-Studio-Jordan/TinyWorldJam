## Handles score and time limit
class_name Level extends Node3D

@export var points_to_win: int = 100
@export var time_limit: float = 100

var current_points: int = 0

var timer: SceneTreeTimer

func _ready() -> void: 
    var objects = get_tree().get_nodes_in_group("destructible")
    for object in objects:
        object.destroyed.connect(_on_object_destroyed)

    timer = get_tree().create_timer(time_limit)
    timer.timeout.connect(lose)

func _on_object_destroyed(points: int) -> void:
    current_points += points
    if current_points >= points_to_win:
        win()

func win() -> void:
    timer.stop()
    print("won")

func lose() -> void:
    print("lost")

func get_time_remaining() -> float:
    return timer.time_left

func get_points() -> int:
    return current_points

func get_points_to_win() -> int:
    return points_to_win