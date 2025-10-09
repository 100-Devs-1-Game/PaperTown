class_name HealthBar extends Control

@onready var progress_bar: ProgressBar = $TextureRect/ProgressBar

var character_stats: Stats
var character_node: Node

func _ready():
	# Find the character node this health bar belongs to
	find_character_node()
	
	if character_stats:
		update_health_display()
		# Connect to any health change signals if they exist
		connect_health_signals()

func find_character_node():
	# Look for a character node in parents or assigned reference
	var current = get_parent()
	
	while current != null:
		# Check if this node has stats (Player, Rudolph, Enemy)
		if current.has_method("get") and current.get("stats") != null:
			character_node = current
			character_stats = current.stats
			return
		
		# Check specific character types
		if current is Player or current is Rudolph or current is Enemy:
			character_node = current
			character_stats = current.stats
			return
			
		current = current.get_parent()
	
	# If not found in parents, check if it's a direct child of BattleManager
	if get_tree().current_scene.has_method("get_player_character"):
		# This would be for UI health bars in battle scene
		setup_from_battle_manager()

func setup_from_battle_manager():
	# For health bars that are UI elements in battle
	var battle_manager = get_tree().current_scene
	
	# Check the name or path to determine which character this represents
	var node_name = name.to_lower()
	
	if "player" in node_name:
		character_node = battle_manager.player_character
		character_stats = battle_manager.player_character.stats
	elif "rudolph" in node_name:
		character_node = battle_manager.rudolph
		character_stats = battle_manager.rudolph.stats
	# For enemies, you might need additional logic based on your setup

func connect_health_signals():
	# Connect to health change signals if the character has them
	if character_node and character_node.has_signal("health_changed"):
		character_node.health_changed.connect(update_health_display)
	
	# Alternative: Use a timer to periodically update (less efficient but more universal)
	var timer = Timer.new()
	timer.wait_time = 0.1
	timer.timeout.connect(update_health_display)
	add_child(timer)
	timer.start()

func update_health_display():
	if not character_stats or not progress_bar:
		return
	
	var max_hp = character_stats.max_hp
	var current_hp = character_stats.current_hp
	
	# Calculate percentage
	var health_percentage = float(current_hp) / float(max_hp) * 100.0
	
	# Update progress bar
	progress_bar.value = health_percentage
	
	# Optional: Change color based on health percentage
	update_health_bar_color(health_percentage)

func update_health_bar_color(percentage: float):
	if not progress_bar:
		return
		
	# Change tint based on health level
	var fill_style = progress_bar.get_theme_stylebox("fill")
	if fill_style is StyleBoxTexture:
		var style_box = fill_style as StyleBoxTexture
		
		if percentage > 60:
			style_box.modulate = Color.WHITE  # Normal color
		elif percentage > 30:
			style_box.modulate = Color.YELLOW  # Warning
		else:
			style_box.modulate = Color.RED     # Critical

# Public method to manually set the character reference
func set_character(character: Node):
	character_node = character
	if character.has_method("get") and character.get("stats"):
		character_stats = character.stats
		update_health_display()

# Public method to manually update (useful for immediate updates)
func force_update():
	update_health_display()
