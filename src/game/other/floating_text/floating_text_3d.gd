@tool
class_name FloatingText3D
extends Sprite3D

@onready var floating_text: FloatingTextLabel = $SubViewport/CanvasLayer/UI/FloatingText
@onready var sub_viewport: SubViewport = $SubViewport


func _ready() -> void:
	sub_viewport.size = floating_text.rtl.size
	floating_text.rtl.resized.connect(func(): sub_viewport.size = floating_text.rtl.size)


func randomize_position(rand_range: Vector3) -> void:
	position.x += randf_range(-rand_range.x, rand_range.x)
	position.y += randf_range(-rand_range.y, rand_range.y)
	position.z += randf_range(-rand_range.z, rand_range.z)
	reset_physics_interpolation()
