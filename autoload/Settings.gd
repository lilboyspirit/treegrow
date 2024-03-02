extends Node


# warning-ignore:unused_signal
signal updated

# Controls
var sensitivity : float = 1

# Graphics
var power_saving : bool = false
var fullscreen : bool = false
var vsync : bool = true
var render_scale : float = 1
var fps : int = 0


func _ready():
# warning-ignore:return_value_discarded
	connect("updated", self, "on_update")
	
	var loading_state = fs.load_json("user://settings.json", self)
	if loading_state is GDScriptFunctionState:
		yield(loading_state, "completed")
	
	emit_signal("updated")


func on_update():
	OS.set_low_processor_usage_mode(power_saving)
	OS.window_fullscreen = fullscreen
	OS.vsync_enabled = vsync
	Engine.target_fps = fps


func save():
	fs.save_json("user://settings.json", self, Node.new())
