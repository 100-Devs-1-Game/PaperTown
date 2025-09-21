class_name Screen
extends CanvasLayer

signal started_fadeout
signal started_fadein
signal finished_fadeout
signal finished_fadein

const MAIN_MENU_SCENE := preload("res://game/ui/main_menu.tscn")

var first_time: bool = true

@onready var mouse_filter: Control = %MouseFilter
@onready var blur_backdrop: TextureRect = %BlurBackdrop
@onready var color_rect: ColorRect = %ColorRect

var active_screen: Node
var tweening: bool = false


func _ready() -> void:
	spawn_mainmenu()


func spawn_mainmenu() -> void:
	var main_menu = MAIN_MENU_SCENE.instantiate()
	active_screen = main_menu
	add_child(main_menu)
	main_menu.finished.connect(fadeout)


func despawn_mainmenu() -> void:
	if active_screen:
		active_screen.queue_free()


func fadeout(_btn: Button) -> void:
	started_fadeout.emit()
	tweening = true

	if first_time:
		var first_time_tween := color_rect.create_tween()
		first_time_tween.tween_property(color_rect, ^"modulate:a", 0.0, 1.5)
		first_time_tween.tween_callback(color_rect.queue_free)
		first_time_tween.play()

	await get_tree().create_timer(0.5).timeout

	var tween := blur_backdrop.create_tween()
	tween.tween_property(blur_backdrop, ^"modulate:a", 0.0, 1.0)
	tween.tween_callback(
		func(): mouse_filter.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_DISABLED
	)
	tween.tween_callback(finished_fadeout.emit)
	tween.tween_callback(despawn_mainmenu)
	tween.tween_callback(func(): tweening = false)
	tween.play()

	first_time = false


func fadein(_btn: Button) -> void:
	started_fadein.emit()
	tweening = true

	mouse_filter.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_ENABLED

	var tween := blur_backdrop.create_tween()
	tween.tween_property(blur_backdrop, ^"modulate:a", 1.0, 0.5)
	tween.tween_callback(finished_fadein.emit)
	tween.tween_callback(func(): tweening = false)
	tween.play()


func _input(event: InputEvent) -> void:
	if !event.is_action_pressed(&"ui_cancel") || tweening:
		return

	if active_screen:
		var mainmenu := active_screen as MainMenu
		if mainmenu:
			mainmenu.play.button_pressed = true
			mainmenu.play.pressed.emit()
	else:
		fadein(null)
		finished_fadein.connect(spawn_mainmenu, CONNECT_ONE_SHOT)
