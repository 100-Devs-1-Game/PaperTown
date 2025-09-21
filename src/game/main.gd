class_name Main
extends Node

const GAME_SCENE := preload("res://game/game.tscn")

var game: Game

@onready var screen: Screen = %Screen


func _ready() -> void:
	self.process_mode = PROCESS_MODE_ALWAYS
	screen.process_mode = PROCESS_MODE_ALWAYS
	get_tree().paused = true

	screen.main_menu.finished.connect(
		func(btn: Button):
			if game || btn.name != "Play":
				return

			game = GAME_SCENE.instantiate()
			add_child(game)
	)

	screen.finished_fadeout.connect(
		func():
			get_tree().paused = false
			if game:
				game.visible = true
	)

	screen.finished_fadein.connect(
		func():
			get_tree().paused = true
			if game:
				game.visible = false
	)
