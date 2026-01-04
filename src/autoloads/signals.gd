extends Node

signal battle_started(enemy: Node3D)
signal battle_lost(enemy: Node3D)
signal battle_won(enemy: Node3D)
signal pet_unlocked()
signal health_changed(current_hp: int, max_hp: int)

signal anim_finished()
