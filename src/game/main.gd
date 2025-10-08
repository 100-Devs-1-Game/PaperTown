class_name Main
extends Node

const SCREEN_TRANSITION_SCENE := preload("res://game/ui/screen_transition.tscn")

@onready var game: Game = %Game
@onready var screen: Screen = %Screen

var in_battle := false


func _ready() -> void:
	# We use the game scene we instantiated and then tell it which parent to place scenes in
	SceneManager.game_scene = game
	SceneManager.start(%Scenes)

	# spawn text to avoid shader compilation stutter later
	var ft3d := FloatingText.spawn($"preload to avoid stutters".global_position, "test")
	ft3d.modulate.a = 0.0

	# delay a couple of frames to let characters settle on the floor
	await get_tree().process_frame
	await get_tree().process_frame

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
			var defer := func():
				game.process_mode = Node.PROCESS_MODE_DISABLED
				game.set_physics_process(false)

			defer.call_deferred()
	)

	Signals.battle_lost.connect(
		func(_enemy: ICharacter):
			game.process_mode = Node.PROCESS_MODE_PAUSABLE
			game.set_physics_process(true)
	)

	Signals.battle_won.connect(
		func(_enemy: ICharacter):
			game.process_mode = Node.PROCESS_MODE_PAUSABLE
			game.set_physics_process(true)
	)


	await get_tree().process_frame
	await get_tree().process_frame

	$"preload to avoid stutters".queue_free()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"toggle_debug_popup"):
		$OverworldManager.start_battle(null)
