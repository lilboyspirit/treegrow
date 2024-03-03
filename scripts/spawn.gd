extends Timer


var spawn_interval = 2.5  # Initial time between spawns (seconds)
var spawn_rate_decrease = 0.05 # How much to decrease spawn interval each time
var min_spawn_interval = 0.5   # Minimum time between spawns


func spawn():
	var random_angle = rand_range(0, 2 * PI)  # Angle between 0 and 2*PI (full circle)
	var random_radius = rand_range(15, 50)  # Distance between inner and outer radius

	var spawn_position = Vector3(
		random_radius * cos(random_angle),
		0,
		random_radius * sin(random_angle)
	)

	var enemy = preload("res://scenes/alien.tscn").instance()
	enemy.set_translation(spawn_position)
	add_child(enemy)

	spawn_interval = max(spawn_interval - spawn_rate_decrease, min_spawn_interval)
	wait_time = spawn_interval 
