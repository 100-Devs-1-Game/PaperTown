@abstract
class_name BaseStatResource extends Resource

# Base stats that all characters have
@export var max_health: int
@export var attack: int
@export var defense: int
@export var speed: int

<<<<<<< Updated upstream
@export_group("Enemy Stats")
@export var max_hp: int = 10
@export var current_hp: int = max_hp
=======
@abstract func _init()
@abstract func take_damage(amount: int)
@abstract func heal(amount: int)
@abstract func is_alive()
@abstract func get_health_percentage()
>>>>>>> Stashed changes
