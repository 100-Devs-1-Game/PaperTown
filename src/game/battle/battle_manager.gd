class_name BattleManager extends Node3D

signal battle_state_changed(new_state: BattleEnums.BattleState)

const PLAYER = preload("res://game/characters/player/player.tscn")
const BOAR = preload("uid://c8x3kcryc0xtb")
const BATTLE_UI = preload("uid://du3tajtsd7up4")
const ACTION_MENU = preload("uid://ca65elqv0fxhy")


@onready var player_character := PLAYER.instantiate()
@onready var enemy_character := BOAR.instantiate()

# Battle State variables
var current_state: BattleEnums.BattleState
var player_action: BattleEnums.ActionType

# Quick Timing Event variables (commented out for now)
#var timing_window_active: bool = false
#var timing_success: float = 0.5
#var timing_start_time: float = 0.0

# UI References
@export var camera_3d: Camera3D

var battle_ui_instance: Control
var action_menu_instance: Control

func _ready() -> void:
	setup_battle()

# Initialize the battle scene
func setup_battle() -> void:
	add_child(player_character)
	add_child(enemy_character)
	player_character.set_battle_state(true)
	enemy_character.set_battle_state(true)

	# Position characters
	player_character.position = Vector3(-3, 0, 0)
	enemy_character.position = Vector3(3, 0, 0)

	# Instantiate UI elements
	battle_ui_instance = BATTLE_UI.instantiate()
	add_child(battle_ui_instance)
	action_menu_instance = ACTION_MENU.instantiate()
	battle_ui_instance.add_child(action_menu_instance)
	action_menu_instance.hide()

	# Connect signals
	action_menu_instance.action_selected.connect(handle_action_selected)

	# Start the battle
	current_state = BattleEnums.BattleState.START
	battle_state_changed.emit(current_state)
	start_battle()

# Start the Battle
func start_battle() -> void:
	player_character.stats.hit_counter = 0
	start_player_turn()

func start_player_turn() -> void:
	current_state = BattleEnums.BattleState.PLAYER_TURN
	battle_state_changed.emit(current_state)
	print("Battle State: %s" % current_state)
	action_menu_instance.show()
	action_menu_instance.move_to_front()
	action_menu_instance.mouse_filter = Control.MOUSE_FILTER_PASS

func handle_action_selected(action_type: BattleEnums.ActionType) -> void:
	var damage := 0
	action_menu_instance.hide()

	match action_type:
		BattleEnums.ActionType.TONGUE_SLAP:
			damage = player_character.stats.attack
			enemy_character.stats.current_hp -= damage
			print("Player used Tongue Slap! Dealt %d damage." % damage)
		BattleEnums.ActionType.TAIL_WHIP:
			damage = player_character.stats.attack * 2
			enemy_character.stats.current_hp -= damage
			print("Player used Tail Whip! Dealt %d damage." % damage)
		BattleEnums.ActionType.RUN_AWAY:
			execute_run_attempt()
			return

	# Check if enemy is defeated
	if enemy_character.stats.current_hp <= 0:
		end_battle(true)
	else:
		start_enemy_turn()

func execute_run_attempt() -> void:
	var run_chance := randi() % 100
	if run_chance < 50:
		print("Successfully ran away!")
		end_battle(false)  # Running away is not a victory
	else:
		print("Failed to run away!")
		start_enemy_turn()

func start_enemy_turn() -> void:
	current_state = BattleEnums.BattleState.ENEMY_TURN
	battle_state_changed.emit(current_state)

	# Enemy attacks player
	player_character.stats.hit_counter += 1

	# Check if player has been hit 3 times (battle lost)
	if player_character.stats.hit_counter >= 3:
		end_battle(false)
	else:
		# Wait a moment then start next player turn
		await get_tree().create_timer(2.0).timeout
		start_player_turn()

func end_battle(player_won: bool) -> void:
	if player_won:
		current_state = BattleEnums.BattleState.WON
		battle_state_changed.emit(current_state)
	else:
		current_state = BattleEnums.BattleState.LOST
		battle_state_changed.emit(current_state)

	# Hide UI elements
	if action_menu_instance:
		action_menu_instance.hide()

	# Wait a moment then return to overworld or show game over
	await get_tree().create_timer(3.0).timeout

	if player_won:
		# TODO: Return to overworld scene
		pass
	else:
		# TODO: Show game over screen or restart
		pass
