class_name BattleManager extends Node3D

signal battle_state_changed(new_state: GlobalUtils.BattleState)

const PLAYER = preload("uid://px8n52y05giq")
const BOAR = preload("uid://c8x3kcryc0xtb")
const BATTLE_MENU = preload("uid://ca65elqv0fxhy")
const QTE_INDICATOR = preload("uid://k2fu5rlm10mf")

@onready var player_character := PLAYER.instantiate()
@onready var enemy_character := BOAR.instantiate()

# Battle State variables
var current_state: GlobalUtils.BattleState
var player_action: GlobalUtils.PlayerAction
var enemy_action: GlobalUtils.EnemyAction
var battle_menu_instance: BattleMenu
var qte_indicator_instance: QuickTimeEvent

func _ready() -> void:
	setup_battle()

func change_state(new_state: GlobalUtils.BattleState) -> void:
	if current_state == new_state:
		return
	current_state = new_state
	battle_state_changed.emit(current_state)

# Initialize the battle scene
func setup_battle() -> void:
	add_child(player_character)
	add_child(enemy_character)
	player_character.change_state(player_character.State.BATTLE)
	enemy_character.change_state(enemy_character.State.BATTLE)

	# Position characters
	player_character.position = Vector3(-3, 0, 0)
	enemy_character.position = Vector3(3, 0, 0)

	# Instantiate UI elements
	battle_menu_instance = BATTLE_MENU.instantiate()
	add_child(battle_menu_instance)
	qte_indicator_instance = QTE_INDICATOR.instantiate()
	battle_menu_instance.add_child(qte_indicator_instance)

	# Connect Signals
	battle_menu_instance.action_selected.connect(handle_action_selected)
	qte_indicator_instance.qte_result.connect(handle_player_dodge)

	# Start the battle
	change_state(GlobalUtils.BattleState.START)
	start_battle()

# Start the Battle
func start_battle() -> void:
	if current_state == GlobalUtils.BattleState.START:
		player_character.stats.hit_counter = 0
		change_state(GlobalUtils.BattleState.PLAYER_TURN_START)
		start_player_turn()

func start_player_turn() -> void:
	if current_state == GlobalUtils.BattleState.PLAYER_TURN_START:
		change_state(GlobalUtils.BattleState.PLAYER_SELECTING_ACTION)
		battle_menu_instance.show_menu()

func handle_action_selected(selected_action: GlobalUtils.PlayerAction) -> void:
	player_action = selected_action
	change_state(GlobalUtils.BattleState.PLAYER_EXECUTING_ACTION)
	execute_player_action()

func execute_player_action() -> void:
	var damage: int
	if current_state == GlobalUtils.BattleState.PLAYER_EXECUTING_ACTION:
		match player_action:
			GlobalUtils.PlayerAction.TONGUE_SLAP:
				damage = player_character.stats.attack
				print("Player attacked with Tongue Slap!")
			GlobalUtils.PlayerAction.TAIL_WHIP:
				damage = player_character.stats.attack * 2
				print("Player attacked with Tail Whip!")
			GlobalUtils.PlayerAction.RUN_AWAY:
				execute_run_attempt()

		if damage > 0:
			enemy_character.stats.current_hp -= damage
			print("Player used Tongue Slap! Dealt %d damage." % damage)
			is_enemy_defeated(enemy_character)

func is_enemy_defeated(enemy: Enemy):
	if enemy.stats.current_hp <= 0:
		enemy.queue_free()
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
	change_state(GlobalUtils.BattleState.ENEMY_TURN_START)
	# TODO: Move Enemy AI to separate script
	handle_enemy_attack()
	# Check if player has been hit 3 times (battle lost)
	# Wait a moment then start next player turn
	await get_tree().create_timer(2.0).timeout
	start_player_turn()

func handle_enemy_attack() -> void:
	change_state(GlobalUtils.BattleState.ENEMY_ATTACKING)
	print("The enemy attacks!")
	# TODO: Enemy AI and attack animation
	qte_indicator_instance.start_qte()

func handle_player_dodge(result: bool) -> void:
	if result:
		# animate dodge
		print("Enemy attack missed!")
		# Hit counter doesn't increase
	else:
		# animate damage taken
		print("Oh no! The enemy hit you!")
		player_character.stats.hit_counter += 1

func continue_battle() -> void:
	# Check if player has been hit too many times
	if player_character.stats.hit_counter >= 3:
		end_battle(false)  # Player loses
	else:
		# Continue to next turn
		await get_tree().create_timer(1.0).timeout
		start_player_turn()

func end_battle(player_won: bool) -> void:
	if player_won: change_state(GlobalUtils.BattleState.WON)
	else: change_state(GlobalUtils.BattleState.LOST)

	# Wait a moment then return to overworld or show game over
	# await get_tree().create_timer(3.0).timeout
	# TODO: Return to overworld scene
