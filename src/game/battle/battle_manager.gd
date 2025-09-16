class_name BattleManager extends Node2D

@onready var character := preload("res://game/characters/character.gd")

var player_character := character.new()
var current_combatant = player_character

func _ready() -> void:
    pass