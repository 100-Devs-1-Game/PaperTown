extends Node3D

const BALLOON := preload("res://game/dialogue/balloon.tscn")
const DIALOGUE := preload("res://game/dialogue/test_dialogue_01.dialogue")

var super_cool_test_var: bool = false


func _ready() -> void:
	$FloatingText3D.hide()
	DialogueManager.show_dialogue_balloon_scene(BALLOON, DIALOGUE, "start", [self])

	while true:
		await get_tree().create_timer(0.02).timeout
		if get_tree().paused:
			continue

		var ft3d := FloatingText.spawn($FloatingText3D.global_position, "+%s" % randi_range(0, 99))
		ft3d.position.x += randf_range(-10, 10)
		ft3d.position.y += randf_range(-1, 1)
		ft3d.position.z += randf_range(-1, 1)
		ft3d.reset_physics_interpolation()
		FloatingText.animate(ft3d, 2, 1.2)


func _physics_process(delta: float) -> void:
	$FloatingText3D.position.z -= 4 * delta
	pass
