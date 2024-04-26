extends KinematicBody


onready var pause_menu = preload("res://scenes/pause_menu.tscn")

onready var viewport = $"%viewport"
onready var camera = $"%camera"
onready var head = $"head"
onready var ray : RayCast = $"%RayCast"
onready var gunshot_sound : AudioStreamPlayer = $"gunshot_sound"

export var camera_acceleration := 40.0
export var rotation_factor := 0.005
export var min_angle := -1.57 # deg2rad(-89.9544)
export var max_angle := 1.57 # deg2rad(89.9544)

export var weight := 50
export var friction := 25
export var speed_factor := 0.75
export var walk_speed := 6
export var sprint_speed := 12
export var crouch_speed := 3
export var jump_strength := 15

var speed := 0
var sprinting := false
var crouching := false
var velocity := Vector3()
var direction := Vector3()
var acceleration := Vector3()

var high_score = 0
var score = 0


func _exit_tree():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var data := {
		"high_score": score if score > high_score else high_score,
		"score": score
	}
	fs.save_json("user://score.json", data)


func _input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.pressed && event.button_index == 1:
			shot()
	if event is InputEventKey:
		if event.is_action_pressed("ui_cancel"):
			get_tree().set_input_as_handled()
			on_back()
		if event.is_action("sprint"):
			sprinting = event.is_pressed()
		if event.is_action("crouch"):
			crouching = event.is_pressed()


func shot():
	if ray.is_colliding():
		var collider = ray.get_collider()
		if collider is KinematicBody:
			if collider.is_in_group("enemies"):
				collider.queue_free()
				score += 1
				$score.text = "Score: " + str(score)
				gunshot_sound.pitch_scale = rand_range(0.90, 1.10) # Slight pitch variation
				gunshot_sound.play()


func on_back():
	if !has_node("pause_menu"):
		add_child(pause_menu.instance())


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_on_size_changed()
	
	# warning-ignore:return_value_discarded
	get_viewport().connect("size_changed", self, "_on_size_changed")
	# warning-ignore:return_value_discarded
	Settings.connect("updated", self, "_on_settings_updated")
	
	var data = fs.load_json("user://score.json")
	
	if data is GDScriptFunctionState:
		yield(data, "completed")
	
	if data:
		high_score = data["high_score"]


func _physics_process(delta):
	if is_on_floor():
		direction = Vector3()
		velocity.y += Input.get_action_strength("jump") * jump_strength
	else:
		direction = direction.linear_interpolate(Vector3(), friction * delta)
		
		velocity.y -= weight * delta
	
	direction += (Input.get_action_strength("move_right") - Input.get_action_strength("move_left")) * head.global_transform.basis.x
	direction += (Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")) * head.global_transform.basis.z
	
	direction.y = 0; direction = direction.normalized()
	
	if sprinting:
		speed = lerp(speed, sprint_speed, speed_factor)
	elif crouching:
		speed = lerp(speed, crouch_speed, speed_factor)
	else:
		speed = lerp(speed, walk_speed, speed_factor)
	
	var target = direction * speed; direction.y = 0
	var temp_velocity = velocity.linear_interpolate(target, speed * delta)
	
	velocity.x = temp_velocity.x
	velocity.z = temp_velocity.z
	
	velocity = move_and_slide(velocity, Vector3.UP);


func _process(delta):
	$fps.set_text("FPS: " + str(Engine.get_frames_per_second()))
	if Engine.get_frames_per_second() > Engine.get_iterations_per_second():
		camera.global_transform.origin = camera.global_transform.origin.linear_interpolate(
			head.global_transform.origin, delta * camera_acceleration
		)
	else:
		camera.global_transform = head.global_transform
	camera.rotation.y = rotation.y
	camera.rotation.x = head.rotation.x


func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * rotation_factor * Settings.sensitivity)
		head.rotate_x(-event.relative.y * rotation_factor * Settings.sensitivity)
		head.rotation.x = clamp(head.rotation.x, min_angle, max_angle)


func _on_settings_updated():
	_on_size_changed()


func _on_size_changed():
	viewport.size = OS.window_size * Settings.render_scale


func _on_gunshot_sound_finished():
	gunshot_sound.stop()
