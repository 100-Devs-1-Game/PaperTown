@tool
class_name MainMenu
extends Control

const BUTTON_WIDTH = 400

@onready var play: Button = %Play
@onready var quit: Button = %Quit
@onready var book_front: AnimatedSprite2D = %BookFront

signal finished(Button)


func get_rtl(btn: Button) -> RichTextLabel:
	return btn.get_node("Control/RichTextLabel") as RichTextLabel


func _ready() -> void:
	book_front.frame = 0
	book_front.play(&"front")
	await book_front.animation_finished

	play.pressed.connect(fadeout.bind(play))
	quit.pressed.connect(fadeout.bind(quit))

	play.mouse_entered.connect(mouse_enter.bind(play))
	quit.mouse_entered.connect(mouse_enter.bind(quit))

	play.mouse_exited.connect(mouse_exit.bind(play))
	quit.mouse_exited.connect(mouse_exit.bind(quit))

	mouse_exit(play)
	mouse_exit(quit)


func mouse_enter(btn: Button) -> void:
	var tween := create_tween()
	tween.tween_property(btn, ^"position:y", btn.position.y - 4, 0.1)
	tween.tween_property(btn, ^"position:y", btn.position.y, 0.1)
	btn.get_child(0).add_theme_constant_override("outline_size", 16)


func mouse_exit(btn: Button) -> void:
	btn.get_child(0).add_theme_constant_override("outline_size", 8)


func fadeout(button_pressed: Button) -> void:
	var quitting: bool = button_pressed == quit

	play.mouse_filter = Control.MOUSE_FILTER_IGNORE
	quit.mouse_filter = Control.MOUSE_FILTER_IGNORE

	book_front.play_backwards(&"front")

	if !quitting:
		finished.emit(button_pressed)

		var tween := create_tween()
		tween.tween_property($Control/Book/BookBack, ^"visible", false, 0.0).set_delay(0.25)
		tween.tween_property(self, ^"modulate:a", 0.0, 0.25)
		tween.play()
	else:
		await %BookFront.animation_finished
		get_tree().quit()
