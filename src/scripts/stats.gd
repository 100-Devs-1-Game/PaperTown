class_name Stats extends Resource

@export_group("Player Stats")
@export var level: int = 1  # Player's level
@export var hit_counter: int = 0
@export var attack: int = 5  # Attack Power
@export var luck: int = 1  # Critical hit chance
@export var scales: int = 0  # Scales

@export_group("Enemy Stats")
@export var max_hp: int = 10
@export var current_hp: int = max_hp
