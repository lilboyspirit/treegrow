extends RigidBody


onready var pause_menu = preload("res://scenes/pause_menu.tscn")


func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		get_tree().set_input_as_handled()
		on_back()


func on_back():
	if !has_node("pause_menu"):
		add_child(pause_menu.instance())
