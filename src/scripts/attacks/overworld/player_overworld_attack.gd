extends Node3D

@onready var lasting_timer = $LastingTimer


func _ready():
	lasting_timer.timeout.connect(on_timer_timeout)
	lasting_timer.start()


func on_timer_timeout():
	self.queue_free()
