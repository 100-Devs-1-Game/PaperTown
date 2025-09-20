extends Node

const FLOATING_TEXT_3D_SCENE = preload("res://game/other/floating_text/floating_text_3d.tscn")


# make sure you pass global position! not local!
func spawn(pos: Vector3, text: String) -> FloatingText3D:
	var floating_text_3d: FloatingText3D = FLOATING_TEXT_3D_SCENE.instantiate()
	add_child(floating_text_3d)

	floating_text_3d.floating_text.rtl.clear()
	floating_text_3d.floating_text.rtl.append_text("[tilt]%s[/tilt]" % text.to_upper())
	floating_text_3d.global_position = pos
	floating_text_3d.reset_physics_interpolation()

	return floating_text_3d


func animate(ft3d: FloatingText3D, distance: float, duration: float) -> FloatingText3D:
	ft3d.modulate.a = 0.0

	var tween := ft3d.create_tween()
	tween.set_parallel(true)
	tween.tween_property(ft3d, "modulate:a", 1.0, 0.3)
	tween.tween_property(ft3d, "position:y", ft3d.position.y + distance, duration)
	tween.tween_property(ft3d, "modulate:a", 0.0, duration - 0.6).set_delay(0.6)
	tween.finished.connect(ft3d.queue_free)
	return ft3d
