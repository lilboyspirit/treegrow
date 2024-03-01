extends VBoxContainer


func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		on_exit()


func on_start():
	get_tree().change_scene("res://scenes/realm.tscn")


func on_settings():
	pass


func on_exit():
	get_tree().quit()
