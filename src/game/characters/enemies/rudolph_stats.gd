class_name RudolphStats extends Resource

@export var level: int = 1
@export var max_hp: int = 10
@export var current_hp: int
@export var heal_amount: int = 5
@export var defense: int = 2
@export var speed: int = 4

var old_hp: int

func _init():
	if current_hp == 0:
		current_hp = max_hp

func take_damage(amount: int) -> void:
	old_hp = current_hp
	current_hp = max(0, current_hp - amount)
	# The character class should emit the signal

func heal(amount: int) -> void:
	old_hp = current_hp
	current_hp = min(max_hp, current_hp + amount)
	# The character class should emit the signal

func is_alive() -> bool:
	return current_hp > 0

func get_health_percentage() -> float:
	return float(current_hp) / float(max_hp)
