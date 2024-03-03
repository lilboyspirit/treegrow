extends Node


onready var settings_menu := preload("res://scenes/settings_menu.tscn")


func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		get_tree().set_input_as_handled()
		on_exit()


func on_start():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://scenes/realm.tscn")


func on_settings():
	if !has_node("settings_menu"):
		add_child(settings_menu.instance())


func on_exit():
	get_tree().quit()
