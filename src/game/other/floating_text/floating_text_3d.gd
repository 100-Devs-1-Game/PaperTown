@tool
class_name FloatingText3D
extends Sprite3D

@onready var floating_text: FloatingTextLabel = $SubViewport/CanvasLayer/UI/FloatingText
@onready var sub_viewport: SubViewport = $SubViewport


func _ready() -> void:
	sub_viewport.size = floating_text.rtl.size
	floating_text.rtl.resized.connect(func(): sub_viewport.size = floating_text.rtl.size)
