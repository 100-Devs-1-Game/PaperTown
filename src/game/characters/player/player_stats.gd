class_name PlayerStats extends Resource

@export var player_name: String = "" # the Player's name
@export var level: int = 1 # Player's level
@export var max_HP: int = 25 # Maximum Health Points
@export var current_HP: int = max_HP # Current Health Points
@export var attack: int = 5 # Attack Power
@export var defense: int = 2 # Damage Resistance
@export var speed: int = 3 # Determines first turn in battle
@export var luck: int = 1 # Critical hit chance