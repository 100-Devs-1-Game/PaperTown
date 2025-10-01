extends IOverworldAttack

@onready var lasting_timer = %LastingTimer
@onready var area_3d: Area3D = %Area3D


func _ready():
	lasting_timer.timeout.connect(on_timer_timeout)


func start_timer(time: float):
	lasting_timer.wait_time = time
	lasting_timer.start()
	Audio.play_sfx_atnode(get_parent(), Audio.SFX_PLACEHOLDER)


func on_timer_timeout():
	self.queue_free()
