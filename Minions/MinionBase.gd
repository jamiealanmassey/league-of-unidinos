extends Node

var direction_left = 1
var direction_right = -1

export(float) var gravity = 300
export(float) var direction = direction_left
export(float) var move_speed = 250

var velocity = Vector2()

func _physics_process(delta):
	velocity.x = move_speed * direction
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2(0, -1))
