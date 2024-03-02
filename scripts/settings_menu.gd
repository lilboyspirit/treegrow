extends Node


func _ready():
	on_settings_updated()
# warning-ignore:return_value_discarded
	Settings.connect("updated", self, "on_settings_updated")


func on_settings_updated():
	$"%sensitivity".value = Settings.sensitivity
	$"%power_saving".pressed = Settings.power_saving
	$"%fullscreen".pressed = Settings.fullscreen
	$"%vsync".pressed = Settings.vsync
	$"%resolution".value = Settings.render_scale
	$"%fps".value = Settings.fps if Settings.fps > 0 else 255
	$"%fps_count".text = str(Settings.fps) if Settings.fps > 0 else "Unlimited"


func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		get_tree().set_input_as_handled()
		on_exit()


func on_exit():
	Settings.save()
	queue_free()


func on_sensitivity_changed(value: float):
	Settings.sensitivity = value
	Settings.emit_signal("updated")


func on_power_saving_toggled(button_pressed: bool):
	Settings.power_saving = button_pressed
	Settings.emit_signal("updated")


func on_fullscreen_toggled(button_pressed: bool):
	Settings.fullscreen = button_pressed
	Settings.emit_signal("updated")


func on_vsync_toggled(button_pressed: bool):
	Settings.vsync = button_pressed
	Settings.emit_signal("updated")


func on_resolution_changed(value: float):
	Settings.render_scale = value
	Settings.emit_signal("updated")


func on_fps_changed(value: float):
	Settings.fps = int(value) if value < 255 else 0
	Settings.emit_signal("updated")
