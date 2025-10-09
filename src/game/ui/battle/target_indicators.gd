extends Node3D

@onready var arrow_selected: Sprite3D = $ArrowSelected
@onready var arrow_unselected: Sprite3D = $ArrowUnselected

func _ready():
	set_selected(false)
	# Make the sprites clickable
	setup_clickable_sprites()

func setup_clickable_sprites():
	# Create collision shapes for mouse detection
	var area = Area3D.new()
	var collision = CollisionShape3D.new()
	var shape = BoxShape3D.new()

	# Size the collision box to cover the arrow
	shape.size = Vector3(1, 1, 0.1)
	collision.shape = shape

	area.add_child(collision)
	add_child(area)

	# Enable input events
	area.input_ray_pickable = true

func set_selected(is_selected: bool):
	arrow_selected.visible = is_selected
	arrow_unselected.visible = not is_selected
	if is_selected:
		%AnimationPlayer.play(&"selected")
	else:
		%AnimationPlayer.stop()
