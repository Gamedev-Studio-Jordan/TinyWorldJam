extends Node3D

# Camera references
@onready var third_person_camera: Camera3D = $"3rd-person"
@onready var top_down_camera: Camera3D = $"Top-Down"

# Camera transition properties
@export var transition_speed: float = 5.0
var current_camera: Camera3D
var target_camera: Camera3D

func _ready():
	# Set up initial camera states
	third_person_camera.current = true
	top_down_camera.current = false
	
	# Set current and target cameras
	current_camera = third_person_camera
	target_camera = third_person_camera

func _input(event):
	if event.is_action_pressed("switchcam"):  # You'll need to set up this input in Project Settings
		switch_camera()

func _process(delta):
	# Smooth camera transition
	if current_camera != target_camera:
		# You can add smooth transition effects here if desired
		current_camera.current = false
		target_camera.current = true
		current_camera = target_camera

func switch_camera():
	# Toggle between cameras
	if target_camera == third_person_camera:
		target_camera = top_down_camera
	else:
		target_camera = third_person_camera
	
	print("Switching to: ", target_camera.name)

# Optional: Smooth transition with interpolation (more advanced)
func smooth_switch_camera():
	if target_camera == third_person_camera:
		target_camera = top_down_camera
	else:
		target_camera = third_person_camera
	
	# If you want smooth transitions, you could:
	# 1. Store the starting and target positions/rotations
	# 2. Use a Tween to interpolate between them
	# 3. Enable the target camera at the end
	
	print("Smooth switching to: ", target_camera.name)

# Function to directly set a specific camera
func set_camera(camera_name: String):
	match camera_name:
		"3rd-person":
			target_camera = third_person_camera
		"Top-Down":
			target_camera = top_down_camera
		_:
			push_error("Unknown camera name: " + camera_name)
