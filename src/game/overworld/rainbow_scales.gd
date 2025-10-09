extends Node3D

@onready var area_3d = $Area3D

func _ready():
	area_3d.body_entered.connect(on_body_entered)

func _physics_process(delta: float) -> void:
	global_rotation.y += delta

func on_body_entered(body) -> void:
	if not body == get_tree().get_first_node_in_group(&"player"):
		return
	
	var overworld_manager = get_tree().get_first_node_in_group(&"overworld")
	
	overworld_manager.add_rainbow_scale()
	
	# TODO: VFX
	
	self.queue_free()
