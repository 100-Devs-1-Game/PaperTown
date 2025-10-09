class_name BattleManager extends Node3D

const PLAYER = preload("uid://px8n52y05giq")
const BOAR = preload("uid://c8x3kcryc0xtb")
const BATTLE_MENU = preload("uid://ca65elqv0fxhy")
const QTE_INDICATOR = preload("uid://k2fu5rlm10mf")
const RUDOLPH = preload("res://game/characters/enemies/rudolph.tscn")

@onready var player_spawn: Vector3 = $PlayerSpawn.global_position
@onready var rudolph_spawn: Vector3 = $RudolphSpawn.global_position
@onready var enemy_spawn: Array[Vector3] = [
	$EnemySpawn1.global_position, $EnemySpawn2.global_position, $EnemySpawn3.global_position
]
@onready var player_character := PLAYER.instantiate() as Player
@onready var rudolph := RUDOLPH.instantiate() as Rudolph
@onready var enemy_character: Array[Enemy] = []
@onready var camera: Camera = %Camera

var screen_transition = preload("res://game/ui/screen_transition.tscn")
var overworld_scene
var center_stage_original_pos

# Battle variables
var player_action: GlobalUtils.PlayerAction
var battle_menu_instance: BattleMenu
var qte_indicator_instance: QuickTimeEvent
var turn_order: Array[ICharacter] = []
var current_turn_index: int = 0
var dodge_success: bool
var current_enemy_index: int = 0
var alive_enemies: Array[Enemy] = []
var is_battle_active: bool = true


func _ready() -> void:
	# TODO: This SHOULD NOT be one static thing
	overworld_scene = "res://game/overworld/overworld_test2.tscn"
	center_stage_original_pos = %CenterStage.global_position

	# Generate boars
	for i in range(3):
		var boar := BOAR.instantiate() as Enemy
		enemy_character.append(boar)
	setup_battle()


func setup_battle() -> void:
	# Initialize Player Character
	char_init(player_character)
	char_init(rudolph)
	for i in range(enemy_character.size()):
		char_init(enemy_character[i])

	# Position characters
	rudolph.position = rudolph_spawn
	player_character.position = player_spawn
	for i in range(enemy_character.size()):
		enemy_character[i].position = enemy_spawn[i]

	# Set turn order based on speed
	var all_combatants: Array[ICharacter] = [player_character, rudolph]
	all_combatants.append_array(enemy_character)
	set_turn_order(all_combatants)

	# Instantiate UI elements
	battle_menu_instance = BATTLE_MENU.instantiate()
	add_child(battle_menu_instance)
	battle_menu_instance.target_selection.setup_target_pointers(enemy_character)
	qte_indicator_instance = QTE_INDICATOR.instantiate()
	battle_menu_instance.add_child(qte_indicator_instance)

	# Connect Signals
	battle_menu_instance.action_selected.connect(handle_action_selected)

	# Start the battle
	start_battle()


func start_battle() -> void:
	update_alive_enemies()
	current_turn_index = 0
	execute_turn()

func char_init(c: ICharacter) -> void:
	add_child(c)
	c.reset_physics_interpolation()
	c.change_state(c.State.BATTLE)
	c.stats.current_hp = c.stats.max_hp

func update_alive_enemies() -> void:
	alive_enemies.clear()
	for enemy in enemy_character:
		# ✅ Check for null AND valid instance AND hp > 0
		if is_instance_valid(enemy) and enemy.stats.current_hp > 0:
			alive_enemies.append(enemy)

func execute_turn() -> void:
	if not is_battle_active:
		return

		# Remove dead characters from turn order
	turn_order = turn_order.filter(func(character): return is_instance_valid(character) and character.stats.current_hp > 0)

	# Reset turn index if we've gone through everyone
	if current_turn_index >= turn_order.size():
		current_turn_index = 0

	var current_character = turn_order[current_turn_index]
	print("%s's turn!" % current_character.get_script().get_global_name())

	match current_character:
		var player when player is Player:
			await player_turn()
		var ally when ally is Rudolph:
			await rudolph_turn()
		var enemy when enemy is Enemy:
			await enemy_turn(enemy)

	# Move to next turn
	current_turn_index += 1

	# Continue battle after turn is complete
	continue_battle()

func continue_battle() -> void:
	# Check win/lose conditions
	update_alive_enemies()

	if alive_enemies.size() == 0:
		win_battle()
		return

	if not player_character.stats.is_alive():
		lose_battle()
		return

	# Wait a moment before next turn
	await get_tree().create_timer(0.5).timeout

	# Continue to next turn
	execute_turn()

func player_turn() -> void:
	if not is_battle_active:
		return

	#%CenterStage.global_position = center_stage_original_pos

	print("Player's turn!")
	battle_menu_instance.target_selection.setup_target_pointers(enemy_character)
	battle_menu_instance.show_menu()

	await battle_menu_instance.action_selected

func rudolph_turn() -> void:
	print("Rudolph's turn!")

	# Check who needs healing (below 30% health)
	var player_health_percent = player_character.stats.get_health_percentage()
	var rudolph_health_percent = rudolph.stats.get_health_percentage()

	if rudolph_health_percent < 0.3:
		# Heal self
		var heal_amount = rudolph.stats.heal_amount + randi_range(-2, 2)
		heal_amount = max(1, heal_amount)
		rudolph.stats.heal(heal_amount)
		print("Rudolph heals himself for %d HP!" % heal_amount)

		var ft3d := FloatingText.spawn(rudolph.global_position + Vector3(0, 1, 2), "+" + str(heal_amount))
		ft3d.modulate = Color.GREEN
		ft3d.scale *= 0.5
		FloatingText.animate_towards(
			ft3d, ft3d.global_position + (Vector3(0, 2, 0).normalized() * 2), 1
		)

	elif player_health_percent < 0.3:
		# Heal player
		var heal_amount = rudolph.stats.heal_amount + randi_range(-2, 2)
		heal_amount = max(1, heal_amount)
		player_character.stats.heal(heal_amount)
		print("Rudolph heals the player for %d HP!" % heal_amount)

		var ft3d := FloatingText.spawn(player_character.global_position + Vector3(0, 1, 2), "+" + str(heal_amount))
		ft3d.modulate = Color.GREEN
		ft3d.scale *= 0.5
		FloatingText.animate_towards(
			ft3d, ft3d.global_position + (Vector3(0, 2, 0).normalized() * 2), 1
		)

	else:
		# Defend
		print("Rudolph defends!")

		var ft3d := FloatingText.spawn(rudolph.global_position + Vector3(0, 1, 2), "defend")
		ft3d.modulate = Color.BLUE
		ft3d.scale *= 0.5
		FloatingText.animate_towards(
			ft3d, ft3d.global_position + (Vector3(0, 1, 0).normalized() * 1), 1
		)

	await get_tree().create_timer(1.0).timeout

func handle_action_selected(selected_action: GlobalUtils.PlayerAction, selected_target: int) -> void:
	if not is_battle_active:
		return

	player_action = selected_action
<<<<<<< Updated upstream

	if player_action == GlobalUtils.PlayerAction.RUN_AWAY:
		execute_run_attempt()
	else:
		await execute_attack(selected_target)
		start_enemy_turns()
=======
	if player_action == GlobalUtils.PlayerAction.RUN_AWAY: run_attempt()
	else: await player_attack(selected_target)

>>>>>>> Stashed changes


func player_attack(target: int) -> void:
	if target >= 0 and target < alive_enemies.size() and is_instance_valid(alive_enemies[target]):
		var damage: int = 0

		match player_action:
			GlobalUtils.PlayerAction.TONGUE_SLAP:
				damage = player_character.stats.attack + ([-3, 0, 3][randi() % 3])
				await player_character.play_attack_visuals_one(alive_enemies[target])
				print("Player used Tongue Slap!")
			GlobalUtils.PlayerAction.TAIL_WHIP:
				damage = player_character.stats.attack + ([-1, 0, 1][randi() % 3])
				await player_character.play_attack_visuals_two(alive_enemies[target])
				print("Player used Tail Whip!")

		#%CenterStage.global_position.x = (center_stage_original_pos.x + alive_enemies[target].global_position.x) / 2.0
		#%CenterStage.global_position.z = (center_stage_original_pos.z + alive_enemies[target].global_position.z) / 2.0
		var ft3d := FloatingText.spawn(alive_enemies[target].global_position + Vector3(0, 3, 2), str(damage))
		ft3d.scale *= 0.5
		FloatingText.animate_towards(
			ft3d, ft3d.global_position + (Vector3(randf_range(0, 6), 2, 0).normalized() * 2), 1
		)

		match player_action:
			GlobalUtils.PlayerAction.TONGUE_SLAP:
				await player_character.end_attack_visuals_one(alive_enemies[target])
			GlobalUtils.PlayerAction.TAIL_WHIP:
				await player_character.end_attack_visuals_two(alive_enemies[target])

		alive_enemies[target].stats.current_hp -= damage
		print("Dealt %d damage to enemy %d!" % [damage, target + 1])

		if alive_enemies[target].stats.current_hp <= 0:
			print("Enemy %d defeated!" % (target + 1))
			alive_enemies[target].queue_free()

			# Check if all enemies defeated
			update_alive_enemies()
			if alive_enemies.size() == 0:
				win_battle()
				return
	else:
		print("?")

	await get_tree().create_timer(0.5).timeout


<<<<<<< Updated upstream
func execute_run_attempt() -> void:
=======
func run_attempt() -> void:
>>>>>>> Stashed changes
	lose_battle()
	#var run_chance := randi() % 100
	#if run_chance < 50:
		#print("Successfully ran away!")
	#else:
		#print("Failed to run away!")
		#start_enemy_turns()


func enemy_turn(enemy: Enemy) -> void:
	if not is_battle_active:
		return

<<<<<<< Updated upstream
	update_alive_enemies()
	current_enemy_index = 0
	print("Enemy turns begin!")
	execute_next_enemy_turn()


func start_rudolph_turn() -> void:
	assert(is_battle_active)

	await rudolph.play_attack_visuals_one(player_character)
	player_character.stats.hit_counter -= 1
	player_character.stats.hit_counter = max(player_character.stats.hit_counter, 0)

	var ft3d := FloatingText.spawn(player_character.global_position + Vector3(0, 1, 2), "+5")
	FloatingText.colour(ft3d, Color.LAWN_GREEN)
	ft3d.scale *= 0.5
	FloatingText.animate_towards(
		ft3d, ft3d.global_position + (Vector3(0, 2, 0).normalized() * 2), 2
	)

	await rudolph.end_attack_visuals_one(player_character)
	await get_tree().create_timer(0.5).timeout


func execute_next_enemy_turn() -> void:
	if not is_battle_active:
		return

	# Check if all enemies have acted
	if current_enemy_index >= alive_enemies.size():
		# All enemies finished, back to player turn
		await get_tree().create_timer(1.0).timeout
		await start_rudolph_turn()
		start_player_turn()
		return

	#%CenterStage.global_position.x = (center_stage_original_pos.x + alive_enemies[current_enemy_index].global_position.x) / 2.0
	#%CenterStage.global_position.z = (center_stage_original_pos.z + alive_enemies[current_enemy_index].global_position.z) / 2.0
	await get_tree().create_timer(0.5).timeout

	# Get current enemy
	var current_enemy = alive_enemies[current_enemy_index]
	var enemy_number = enemy_character.find(current_enemy) + 1
=======
	var enemy_number = enemy_character.find(enemy) + 1
>>>>>>> Stashed changes
	print("Enemy %d's turn!" % enemy_number)

	# Enemy AI decision
	var enemy_ai = randi_range(0, 2)
	enemy_ai = 0
	match enemy_ai:
		0:
			print("Boar %d attacks!" % enemy_number)
<<<<<<< Updated upstream
			qte_indicator_instance.start_qte()
			#%CenterStage.global_position.x = center_stage_original_pos.x
			#%CenterStage.global_position.z = center_stage_original_pos.z
			await current_enemy.play_attack_visuals_one(player_character)
			if qte_indicator_instance.is_active:
				await qte_indicator_instance.qte_finished
=======

			# Get the charge animation duration
			var charge_duration = enemy.get_animation_duration("charge")
			var qte_start_delay = 0.2  # Small delay before QTE starts
			var qte_duration = charge_duration - qte_start_delay - 0.3  # End QTE 0.3s before animation ends

			# Start the charge animation
			await enemy.play_attack_visuals_one(player_character)

			# Wait a bit, then start QTE
			await get_tree().create_timer(qte_start_delay).timeout
			qte_indicator_instance.start_qte(qte_duration)

			# Wait for QTE to finish
			await qte_indicator_instance.qte_finished

			# Small delay before ending attack animation
			await get_tree().create_timer(0.3).timeout
			await enemy.end_attack_visuals_one(player_character)

			# Process QTE results
>>>>>>> Stashed changes
			if qte_indicator_instance.success:
				print("You dodged the enemy attack!")
				var ft3d := FloatingText.spawn(player_character.global_position + Vector3(0, 1, 2), "dodge")
				FloatingText.colour(ft3d, Color.CORNFLOWER_BLUE)
				ft3d.scale *= 0.5
				FloatingText.animate_towards(
					ft3d, ft3d.global_position + (Vector3(randf_range(0, 6) * -1, 2, 0).normalized() * 2), 1
				)
				await player_character.play_dodged_visual()
			else:
				print("Oh no! The enemy hit you!")
<<<<<<< Updated upstream
				player_character.stats.hit_counter += 1
				var hits_left: int = 4 - player_character.stats.hit_counter
				print("You can take %d more hits!" % hits_left)
				var ft3d := FloatingText.spawn(player_character.global_position + Vector3(0, 1, 2), "5")
=======
				var damage = round(enemy.stats.attack - player_character.stats.defense * randf_range(.8,1.2))
				player_character.stats.take_damage(damage)

				var ft3d := FloatingText.spawn(player_character.global_position + Vector3(0, 1, 2), str(damage))
>>>>>>> Stashed changes
				ft3d.scale *= 0.5
				FloatingText.animate_towards(
					ft3d, ft3d.global_position + (Vector3(randf_range(0, 6) * -1, 2, 0).normalized() * 2), 1
				)
				await player_character.play_damaged_visual()
<<<<<<< Updated upstream

			await get_tree().create_timer(0.5).timeout
			await current_enemy.end_attack_visuals_one(player_character)

			# Check if Player is defeated.
			if player_character.stats.hit_counter >= 3:
				lose_battle()
				return
=======
>>>>>>> Stashed changes
		1:
			print("Boar %d stares at you!" % enemy_number)
		2:
			print("Boar %d flourishes weapon!" % enemy_number)

	await get_tree().create_timer(0.5).timeout


func win_battle() -> void:
	#%CenterStage.global_position.x = center_stage_original_pos.x
	#%CenterStage.global_position.z = center_stage_original_pos.z
	await get_tree().create_timer(1.0).timeout
	is_battle_active = false
	end_battle("won")
	Signals.battle_won.emit(null)


func lose_battle() -> void:
	#%CenterStage.global_position.x = center_stage_original_pos.x
	#%CenterStage.global_position.z = center_stage_original_pos.z
	await get_tree().create_timer(1.0).timeout
	is_battle_active = false
	print("Defeat! You were overwhelmed!")
	end_battle("lost")
	Signals.battle_lost.emit(null)


func end_battle(result: String) -> void:
	print("Battle ends.")

	var screen_transition_instance = screen_transition.instantiate()
	get_tree().root.add_child(screen_transition_instance)

	if result == "won":
		screen_transition_instance.do_transition(ScreenTransition.TransitionType.BATTLE_WON)
	elif result == "lost":
		screen_transition_instance.do_transition(ScreenTransition.TransitionType.BATTLE_LOST)

	await screen_transition_instance.transition_halfway
	SceneManager.switch_to_game()

func set_turn_order(active_combatants: Array[ICharacter]) -> void:
	# Clear the existing turn order
	turn_order.clear()

	# Sort by speed stat (highest to lowest) and assign to turn_order
	turn_order = active_combatants
	turn_order.sort_custom(func(a, b): return a.stats.speed > b.stats.speed)

	# Optional: Print the turn order for debugging
	print("Turn order set:")
	for i in range(turn_order.size()):
		var character = turn_order[i]
		var character_name = character.get_script().get_global_name()
		print("%d. %s (Speed: %d)" % [i + 1, character_name, character.stats.speed])
