class_name BattleManager extends Control

const PLAYER = preload("res://game/characters/player/player.tscn")

@onready var player_character := PLAYER.instantiate()

func _ready() -> void:
	add_child(player_character)
	print(player_character.stats.attack)

func handle_basic_attack(attacker: Node, defender: Node) -> void:
	var damage: int = attacker.stats.attack - defender.stats.defense
	print("You deal %s damage!" % damage)
