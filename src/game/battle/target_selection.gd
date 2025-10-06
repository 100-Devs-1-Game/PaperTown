extends Container

signal target_selected(target_index: int)

var target_buttons: Array[Button] = []
var camera: Camera


func setup_target_buttons(enemies: Array[Enemy], battle_camera: Camera) -> void:
	camera = battle_camera

	# Clear existing buttons
	for button in target_buttons:
		if button:
			button.queue_free()
	target_buttons.clear()

	# Create buttons for each alive enemy
	for i in range(enemies.size()):
		if enemies[i].stats.current_hp > 0:
			var button = Button.new()
			button.text = "Target"
			button.size = Vector2(80, 40)
			add_child(button)
			target_buttons.append(button)

			# Position button over enemy
			position_button_over_enemy(button, enemies[i])

			# Connect button to target selection
			button.pressed.connect(handle_selection.bind(i))

	deactivate()


func position_button_over_enemy(button: Button, enemy: Enemy) -> void:
	if not camera or not enemy:
		return

	# Convert 3D world position to 2D screen position
	var world_pos = enemy.global_position
	var screen_pos = camera.unproject_position(world_pos)

	# Offset the button to be centered over the enemy
	button.position = screen_pos - (button.size * 0.5)


func handle_selection(target: int) -> void:
	target_selected.emit(target)


func deactivate() -> void:
	for b in target_buttons.size():
		target_buttons[b].disabled = true

	hide()


func activate() -> void:
	for b in target_buttons.size():
		target_buttons[b].disabled = false

	show()
