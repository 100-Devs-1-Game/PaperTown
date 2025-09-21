class_name Screen
extends CanvasLayer

signal finished_fadeout
signal finished_fadein

var first_time: bool = true

@onready var mouse_filter: Control = %MouseFilter
@onready var blur_backdrop: TextureRect = %BlurBackdrop
@onready var main_menu: MainMenu = %MainMenu
@onready var color_rect: ColorRect = %ColorRect


func _ready() -> void:
	main_menu.finished.connect(fadeout)


func fadeout(_btn: Button) -> void:
	if first_time:
		var first_time_tween := color_rect.create_tween()
		first_time_tween.tween_property(color_rect, ^"modulate:a", 0.0, 3.0)
		first_time_tween.tween_callback(color_rect.queue_free)
		first_time_tween.play()

	await get_tree().create_timer(1).timeout

	var tween := blur_backdrop.create_tween()
	tween.tween_property(blur_backdrop, ^"modulate:a", 0.0, 2.0)
	tween.tween_callback(
		func(): mouse_filter.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_DISABLED
	)
	tween.tween_callback(finished_fadeout.emit)
	tween.play()

	first_time = false


func fadein(_btn: Button) -> void:
	mouse_filter.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_ENABLED

	await get_tree().create_timer(1).timeout

	var tween := blur_backdrop.create_tween()
	tween.tween_property(blur_backdrop, ^"modulate:a", 1.0, 2.0)
	tween.tween_callback(finished_fadein.emit)
	tween.play()
