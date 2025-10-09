extends Node

@export var screen_transistion: PackedScene

var num_rainbow_scales : int = 0

var in_battle := false

func _ready():
	Signals.battle_started.connect(
		func(_enemy: ICharacter):
			print("starting battle")
			if in_battle:
				print("already in battle!")
				assert(false)
				print_stack()
				return

			if not SceneManager.started:
				assert(false)
				return

			in_battle = true

			var screen_transistion_instance = screen_transistion.instantiate()
			get_tree().root.add_child(screen_transistion_instance)
			screen_transistion_instance.do_transition(ScreenTransition.TransitionType.BATTLE_START)
			print("waiting for transition, before battle")
			await screen_transistion_instance.transition_halfway
			print("finished transition, going to battle")
			SceneManager.switch_to_battle()

	)

	Signals.battle_lost.connect(
		func(_enemy: ICharacter):
			print("battle lost")
			if !in_battle:
				assert(false)
				return

			# cool-down before next combat can start
			await get_tree().create_timer(1.0).timeout
			in_battle = false
	)

	Signals.battle_won.connect(
		func(enemy: ICharacter):
			print("battle won")
			if !in_battle:
				assert(false)
				return

			# SUPER HACKY
			if SceneManager.game_scene:
				var game := SceneManager.game_scene as Game
				if game:
					game.everything.hostile_boar.queue_free()
					game.everything.hostile_boar_2.queue_free()
					game.everything.hostile_boar_3.queue_free()
				else:
					if enemy:
						enemy.queue_free()
			else:
				if enemy:
					enemy.queue_free()

			# cool-down before next combat can start
			await get_tree().create_timer(1.0).timeout
			in_battle = false
	)

	await get_parent().ready
	if not SceneManager.started:
		SceneManager.game_scene = owner
		SceneManager.start(owner.get_parent())

func start_battle(enemy) -> void:
	Signals.battle_started.emit(enemy)

func add_rainbow_scale():
	num_rainbow_scales += 1
	print("current rainbow scales: " + str(num_rainbow_scales))
