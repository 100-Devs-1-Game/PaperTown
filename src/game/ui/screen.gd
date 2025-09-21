class_name Screen
extends CanvasLayer

@onready var blur_backdrop: TextureRect = %BlurBackdrop
@onready var main_menu: MainMenu = %MainMenu

signal finished_fadeout
signal finished_fadein


func _ready() -> void:
	main_menu.finished.connect(fadeout)


func fadeout(_btn: Button) -> void:
	var tween := blur_backdrop.create_tween()
	tween.tween_property(blur_backdrop, ^"modulate:a", 0.0, 1.0)
	tween.tween_callback(finished_fadeout.emit)
	tween.play()


func fadein(_btn: Button) -> void:
	var tween := blur_backdrop.create_tween()
	tween.tween_property(blur_backdrop, ^"modulate:a", 1.0, 0.0)
	tween.tween_callback(finished_fadein.emit)
	tween.play()
