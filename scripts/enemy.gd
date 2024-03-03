extends KinematicBody


var speed = 10  # Movement speed


func _ready():
	look_at(Vector3.ZERO, Vector3.UP)


func _physics_process(delta):
	var direction = (Vector3.ZERO - global_transform.origin).normalized()
	var velocity = direction * speed
	velocity = move_and_slide(velocity)
