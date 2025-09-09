extends Camera3D

var offset = Vector3(0, 16, 20)
@onready var player = $"../Player"


func _process(_delta: float) -> void:
	position.x = player.position.x + offset.x
	position.z = player.position.z + offset.z
