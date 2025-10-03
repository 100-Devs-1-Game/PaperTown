extends IOverworldAttack

@onready var lasting_timer = %LastingTimer
@onready var area_3d: Area3D = %Area3D


func _ready():
	area_3d.body_entered.connect(
		func(body: Node3D):
			var boar: Enemy = body as Enemy
			if !body:
				return

			if !boar:
				boar = body.get_parent() as Enemy

			if !boar:
				return

			Signals.battle_started.emit(get_parent())
			queue_free()
	)

func start_timer(time: float):
	lasting_timer.wait_time = time
	lasting_timer.start()
	Audio.play_sfx_atnode(get_parent(), Audio.SFX_PLACEHOLDER)
