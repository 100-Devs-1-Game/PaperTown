class_name Player extends Node3D

const STATS = preload("res://game/resources/stats.tres")

var stats = STATS

func _ready() -> void:
	if stats == null:
		push_error("Player stats not loaded!")
		return

	print("Player Stats Loaded:")
	print("Player Name: %s" % stats.player_name)
	print("Level: %s" % stats.level)
	print("Max HP: %s" % stats.max_HP)
	print("Current HP: %s" % stats.current_HP)
	print("Attack: %s" % stats.attack)
	print("Defense: %s" % stats.defense)   
	print("Speed: %s" % stats.speed)
	print("Luck: %s" % stats.luck)
