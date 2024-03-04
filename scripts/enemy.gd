extends KinematicBody


var speed = 600  # Movement speed


func _ready():
	look_at(Vector3.ZERO, Vector3.UP)


func _physics_process(delta):
	var direction = (Vector3.ZERO - global_transform.origin).normalized()
	var velocity = direction * speed * delta
	velocity = move_and_slide(velocity)
