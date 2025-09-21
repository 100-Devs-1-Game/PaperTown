extends Node

const BATTLE = preload("res://game/battle/battle.tscn")


func _ready() -> void:
	var battle = BATTLE.instantiate()
	add_child(battle)


func _process(_delta: float) -> void:
	pass
