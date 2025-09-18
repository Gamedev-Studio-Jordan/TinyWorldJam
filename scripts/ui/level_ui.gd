class_name LevelUI extends Control

@export var level: Level

@onready var score_label: RichTextLabel = %ScoreRTL
@onready var timer_label: RichTextLabel = %TimerRTL

var points_to_win: int = 0

func _ready() -> void:
	points_to_win = level.get_points_to_win()

func _process(_delta: float) -> void:
	score_label.text = "Points: %s/%s" % [level.get_points(), points_to_win]
	var time_remaining = level.get_time_remaining()
	var minutes = int(time_remaining / 60)
	var seconds = int(time_remaining) % 60
	var milliseconds = int((time_remaining - seconds) * 100) % 100
	timer_label.text = "Timer: %02d:%02d.%02d" % [minutes, seconds, milliseconds]
