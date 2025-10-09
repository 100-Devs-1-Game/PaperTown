class_name TargetSelection extends Container

signal target_selected(target_index: int)

@export var target_pointers_scene: PackedScene = preload("res://game/ui/battle/target_indicators.tscn")

var target_pointers: Array[Node3D] = []
var current_selection: int = 0
var enemies: Array[Enemy] = []
var camera: Camera3D

func _ready():
	# Get the camera for raycasting
	camera = get_viewport().get_camera_3d()

func setup_target_pointers(enemy_array: Array[Enemy]) -> void:

	# Clear existing buttons
	clear_pointers()

	enemies = enemy_array.filter(func(enemy): return is_instance_valid(enemy) and enemy.stats.current_hp > 0)

	# Create buttons for each enemy
	for i in range(enemies.size()):
		var arrow = target_pointers_scene.instantiate()
		add_child(arrow)
		target_pointers.append(arrow)

		# Position arrow above enemy
		var enemy_pos = enemies[i].global_position
		var height_offset = get_enemy_height(enemies[i]) + 1
		arrow.global_position = enemy_pos + Vector3(0, height_offset, 0) # Adjust offset as needed

		# Set initial selection state
		arrow.set_selected(i == 0)

		# Connect mouse signals for the arrow
		connect_arrow_signals(arrow, i)

	current_selection = 0
	deactivate()

func connect_arrow_signals(arrow: Node3D, index: int):
	# Make the arrow clickable
	if arrow.has_signal("input_event"):
		arrow.input_event.connect(_on_arrow_clicked.bind(index))

func _on_arrow_clicked(_camera: Node, event: InputEvent, _click_position: Vector3, _click_normal: Vector3, _shape_idx: int, target_index: int):
	if not visible:
		return

	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			handle_selection(target_index)

func _input(event: InputEvent) -> void:
	if not visible or target_pointers.is_empty():
		return

	if event is InputEventMouseMotion:
		check_mouse_hover(event.position)
	elif event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			check_mouse_click(event.position)
	elif event.is_action_pressed("ui_left"):
		move_selection(-1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_right"):
		move_selection(1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept"):
		handle_selection(current_selection)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		deactivate()
		get_viewport().set_input_as_handled()

func check_mouse_hover(mouse_pos: Vector2):
	var target_index = get_target_at_mouse_position(mouse_pos)
	if target_index != -1 and target_index != current_selection:
		# Update selection to hovered target
		target_pointers[current_selection].set_selected(false)
		current_selection = target_index
		target_pointers[current_selection].set_selected(true)

func check_mouse_click(mouse_pos: Vector2):
	var target_index = get_target_at_mouse_position(mouse_pos)
	if target_index != -1:
		handle_selection(target_index)

func get_target_at_mouse_position(mouse_pos: Vector2) -> int:
	if not camera:
		return -1

	# Cast ray from camera through mouse position
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000

	var space_state = camera.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)

	if result:
		var hit_body = result.get("collider")
		if hit_body:
			# Check if we hit an enemy
			for i in range(enemies.size()):
				if enemies[i] == hit_body or enemies[i].is_ancestor_of(hit_body):
					return i

			# Check if we hit an arrow
			for i in range(target_pointers.size()):
				if target_pointers[i] == hit_body or target_pointers[i].is_ancestor_of(hit_body):
					return i

	return -1

func get_enemy_height(enemy: Enemy) -> float:
	for child in enemy.get_children():
		if child is CollisionShape3D:
			var collision_shape := child
			if collision_shape.shape:
				if collision_shape.shape is BoxShape3D:
					return (collision_shape.shape as BoxShape3D).size.y
				elif collision_shape.shape is CapsuleShape3D:
					return (collision_shape.shape as CapsuleShape3D).height
	return 2.0

func move_selection(direction: int):
	if target_pointers.is_empty():
		return

	# Deselect current
	target_pointers[current_selection].set_selected(false)

	# Move selection
	current_selection = wrapi(current_selection + direction, 0, target_pointers.size())

	# Select new target (this line was missing!)
	target_pointers[current_selection].set_selected(true)

func handle_selection(target: int) -> void:
	Audio.play_ui(Audio.UI_BUTTON_CLICK)
	target_selected.emit(target)
	deactivate()

func clear_pointers():
	for arrow in target_pointers:
		arrow.queue_free()
	target_pointers.clear()

func deactivate() -> void:
	hide()
	# Hide all arrows
	for arrow in target_pointers:
		if is_instance_valid(arrow):
			arrow.visible = false


func activate() -> void:
	show()
	# Show all arrows and ensure first one is selected
	for i in range(target_pointers.size()):
		if is_instance_valid(target_pointers[i]):
			target_pointers[i].visible = true
			target_pointers[i].set_selected(i == 0)
	current_selection = 0
