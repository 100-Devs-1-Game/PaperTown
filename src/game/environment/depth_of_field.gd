@tool
extends MeshInstance3D


func _ready() -> void:
	# turn it off in the editor view since it's annoying
	visible = not Engine.is_editor_hint()
