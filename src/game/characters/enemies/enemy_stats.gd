class_name Enemy extends Resource

@export var enemy_name: String = "" # the Enemy's name
@export var level: int = 1 # Enemy's level
@export var max_HP: int = 20 # Maximum Health Points
@export var current_HP: int = max_HP # Current Health Points
@export var attack: int = 4 # Attack Power
@export var defense: int = 1 # Damage Resistance
@export var speed: int = 2 # Determines first turn in battle
@export var luck: int = 1 # Critical hit chance
