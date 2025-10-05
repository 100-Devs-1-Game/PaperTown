class_name BattleManager extends Node3D

const PLAYER = preload("uid://px8n52y05giq")
const BOAR = preload("uid://c8x3kcryc0xtb")
const BATTLE_MENU = preload("uid://ca65elqv0fxhy")
const QTE_INDICATOR = preload("uid://k2fu5rlm10mf")

@onready var player_spawn: Vector3 = $PlayerSpawn.global_position
@onready var enemy_spawn: Array[Vector3] = [
	$EnemySpawn1.global_position,
	$EnemySpawn2.global_position,
	$EnemySpawn3.global_position
]
@onready var player_character := PLAYER.instantiate()
@onready var enemy_character: Array[Enemy] = []
@onready var camera_3d: Camera3D = $Camera3D

var screen_transition = preload("res://game/ui/screen_transition.tscn")
var overworld_scene

# Battle variables
var player_action: GlobalUtils.PlayerAction
var battle_menu_instance: BattleMenu
var qte_indicator_instance: QuickTimeEvent
var dodge_success: bool
var current_enemy_index: int = 0
var alive_enemies: Array[Enemy] = []
var is_battle_active: bool = true

func _ready() -> void:
	# TODO: This SHOULD NOT be one static thing
	overworld_scene = "res://game/overworld/overworld_test2.tscn"
	
	# Generate boars
	for i in range(3):
		var boar = BOAR.instantiate()
		enemy_character.append(boar)
	setup_battle()

func setup_battle() -> void:
	# Initialize Player Character
	add_child(player_character)
	player_character.position = player_spawn
	player_character.change_state(player_character.State.BATTLE)

	# Initialize Enemy Characters
	for i in range(enemy_character.size()):
		add_child(enemy_character[i])
		enemy_character[i].position = enemy_spawn[i]
		enemy_character[i].change_state(enemy_character[i].State.BATTLE)

	# Instantiate UI elements
	battle_menu_instance = BATTLE_MENU.instantiate()
	add_child(battle_menu_instance)
	battle_menu_instance.target_selection.setup_target_buttons(enemy_character, camera_3d)
	qte_indicator_instance = QTE_INDICATOR.instantiate()
	battle_menu_instance.add_child(qte_indicator_instance)

	# Connect Signals
	battle_menu_instance.action_selected.connect(handle_player_action)

	# Start the battle
	start_battle()

func start_battle() -> void:
	player_character.stats.hit_counter = 0
	update_alive_enemies()
	start_player_turn()

func update_alive_enemies() -> void:
	alive_enemies.clear()
	for enemy in enemy_character:
		# ✅ Check for null AND valid instance AND hp > 0
		if is_instance_valid(enemy) and enemy.stats.current_hp > 0:
			alive_enemies.append(enemy)

func start_player_turn() -> void:
	if not is_battle_active:
		return

	print("Player's turn!")
	battle_menu_instance.show_menu()

func handle_player_action(selected_action: GlobalUtils.PlayerAction, selected_target: int) -> void:
	if not is_battle_active:
		return

	player_action = selected_action

	if player_action == GlobalUtils.PlayerAction.RUN_AWAY:
		execute_run_attempt()
	else:
		execute_attack(selected_target)

func execute_attack(target: int) -> void:
	var damage: int = 0

	match player_action:
		GlobalUtils.PlayerAction.TONGUE_SLAP:
			damage = player_character.stats.attack
			print("Player used Tongue Slap!")
		GlobalUtils.PlayerAction.TAIL_WHIP:
			damage = player_character.stats.attack * 2
			print("Player used Tail Whip!")

	if damage > 0 and target < enemy_character.size():
		enemy_character[target].stats.current_hp -= damage
		print("Dealt %d damage to enemy %d!" % [damage, target + 1])

		if enemy_character[target].stats.current_hp <= 0:
			print("Enemy %d defeated!" % (target + 1))
			enemy_character[target].queue_free()

			# Check if all enemies defeated
			update_alive_enemies()
			if alive_enemies.size() == 0:
				win_battle()
				return

	# Player turn finished, start enemy turns
	start_enemy_turns()

func execute_run_attempt() -> void:
	var run_chance := randi() % 100
	if run_chance < 50:
		print("Successfully ran away!")
		end_battle("won")
	else:
		print("Failed to run away!")
		start_enemy_turns()

func start_enemy_turns() -> void:
	if not is_battle_active:
		return

	update_alive_enemies()
	current_enemy_index = 0
	print("Enemy turns begin!")
	execute_next_enemy_turn()

func execute_next_enemy_turn() -> void:
	if not is_battle_active:
		return

	# Check if all enemies have acted
	if current_enemy_index >= alive_enemies.size():
		# All enemies finished, back to player turn
		await get_tree().create_timer(1.0).timeout
		start_player_turn()
		return

	# Get current enemy
	var current_enemy = alive_enemies[current_enemy_index]
	var enemy_number = enemy_character.find(current_enemy) + 1
	print("Enemy %d's turn!" % enemy_number)

	# Enemy AI decision
	var enemy_ai = randi_range(0, 2)
	match enemy_ai:
		0:
			print("Boar %d attacks!" % enemy_number)
			qte_indicator_instance.start_qte()
			await qte_indicator_instance.qte_finished
			if qte_indicator_instance.qte_result:
				print("You dodged the enemy attack!")
			else:
				print("Oh no! The enemy hit you!")
				player_character.stats.hit_counter += 1
				var hits_left: int = 3 - player_character.stats.hit_counter
				print("You can take %d more hits!" % hits_left)

			# Check if Player is defeated.
			if player_character.stats.hit_counter >= 3:
				lose_battle()
				return
		1:
			print("Boar %d stares at you!" % enemy_number)

		2:
			print("Boar %d flourishes weapon!" % enemy_number)


	# Move to next enemy
	current_enemy_index += 1
	execute_next_enemy_turn()


func win_battle() -> void:
	is_battle_active = false
	end_battle("won")

func lose_battle() -> void:
	is_battle_active = false
	print("Defeat! You were overwhelmed!")
	end_battle("lost")

func end_battle(result : String) -> void:
	print("Battle ends.")
	
	var screen_transition_instance = screen_transition.instantiate()
	get_tree().root.add_child(screen_transition_instance)
	
	if result == "won":
		screen_transition_instance.do_transition(ScreenTransition.TransitionType.BATTLE_WON)
	elif result == "lost":
		screen_transition_instance.do_transition(ScreenTransition.TransitionType.BATTLE_LOST)
		
	
	# TODO: clear battle scene, play victory or defeat splash, exit to OW
	# TODO: We need to track the player's position in the overworld after this
	await screen_transition_instance.transition_halfway
	get_tree().change_scene_to_file(overworld_scene)
