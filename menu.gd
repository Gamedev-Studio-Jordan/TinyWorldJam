extends Control

@export var car_start_animation: AnimationPlayer
@export var fade_out_animation: AnimationPlayer

func _on_start_pressed() -> void:
	visible = false
	car_start_animation.play("Start Driving")
	fade_out_animation.play("Fade Out")

func _on_exit_pressed() -> void:
	get_tree().quit()
