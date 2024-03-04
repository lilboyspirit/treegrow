extends Area


var helth = 5
var enemies_near = 0


func on_timeout():
	$grown.show()
	$small.hide()


func _on_body_entered(body: Node):
	if body.is_in_group("enemies"):
		enemies_near += 1


func on_body_exited(body):
	if body.is_in_group("enemies"):
		enemies_near -= 1


func _process(delta: float):
	helth -= enemies_near * delta
	
	if helth < 0:
		end_game()


func end_game():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://scenes/game_over.tscn")
