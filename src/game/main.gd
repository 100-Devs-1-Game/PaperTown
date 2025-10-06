class_name Main
extends Node

const SCREEN_TRANSITION_SCENE := preload("res://game/ui/screen_transition.tscn")

@onready var game: Game = %Game
@onready var screen: Screen = %Screen

var in_battle := false


func _ready() -> void:
	self.process_mode = PROCESS_MODE_ALWAYS
	game.process_mode = Node.PROCESS_MODE_PAUSABLE
	screen.process_mode = PROCESS_MODE_ALWAYS
	get_tree().paused = true

	screen.started_fadeout.connect(
		func(): get_viewport().get_camera_3d().process_mode = Node.PROCESS_MODE_ALWAYS
	)

	screen.finished_fadeout.connect(func(): get_tree().paused = false)

	screen.started_fadein.connect(func(): get_tree().paused = true)

	Signals.battle_started.connect(
		func(enemy: ICharacter):
			print("starting battle")
			if in_battle:
				print("already in battle!")
				print_stack()
				return

			in_battle = true

			var transition := SCREEN_TRANSITION_SCENE.instantiate() as ScreenTransition
			assert(transition)
			screen.add_child(transition)
			transition.animated_sprite_2d.stop()
			transition.animated_sprite_2d.play(&"battle_start")

			var defer := func():
				game.process_mode = Node.PROCESS_MODE_DISABLED
				game.set_physics_process(false)

			defer.call_deferred()

			# TODO - Replace with the battle result
			await transition.animated_sprite_2d.animation_finished

			Signals.battle_won.emit(enemy)
	)

	Signals.battle_lost.connect(
		func(_enemy: ICharacter):
			print("battle lost")
			if !in_battle:
				assert(false)
				return

			var transition := SCREEN_TRANSITION_SCENE.instantiate() as ScreenTransition
			assert(transition)
			screen.add_child(transition)
			transition.animated_sprite_2d.stop()
			transition.animated_sprite_2d.play(&"battle_defeat")

			await transition.animated_sprite_2d.animation_finished

			game.process_mode = Node.PROCESS_MODE_PAUSABLE
			game.set_physics_process(true)
			transition.queue_free()

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

			enemy.queue_free()

			var transition := SCREEN_TRANSITION_SCENE.instantiate() as ScreenTransition
			assert(transition)
			screen.add_child(transition)
			transition.animated_sprite_2d.stop()
			transition.animated_sprite_2d.play(&"battle_victory")

			await transition.animated_sprite_2d.animation_finished

			game.process_mode = Node.PROCESS_MODE_PAUSABLE
			game.set_physics_process(true)
			transition.queue_free()

			# cool-down before next combat can start
			await get_tree().create_timer(1.0).timeout
			in_battle = false
	)

	await get_tree().process_frame
	await get_tree().process_frame

	$"preload to avoid stutters".queue_free()
