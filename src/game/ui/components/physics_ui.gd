extends Control

var velocity = Vector2.ZERO
var gravity = 3000.0


func _process(delta):
	velocity.y += gravity * delta

	get_parent().position += velocity * delta

	var screen_size = get_viewport_rect().size
	if (
		global_position.y > screen_size.y * 2
		or global_position.y < -screen_size.y
		or global_position.x < -screen_size.x
		or global_position.x > screen_size.x * 2
	):
		queue_free()
