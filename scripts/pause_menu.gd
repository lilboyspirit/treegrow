extends Node


onready var settings_menu = preload("res://scenes/settings_menu.tscn")


func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		get_tree().set_input_as_handled()
		on_back()


func on_back():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	queue_free()


func on_settings():
	if !has_node("settings_menu"):
		add_child(settings_menu.instance())


func on_exit():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://scenes/main_menu.tscn")
