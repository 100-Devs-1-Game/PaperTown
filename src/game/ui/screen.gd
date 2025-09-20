extends CanvasLayer

@onready var blur_backdrop: TextureRect = %BlurBackdrop
@onready var main_menu: Control = %MainMenu


func _ready() -> void:
	main_menu.tree_exited.connect(
		func():
			var tween := blur_backdrop.create_tween()
			tween.tween_property(blur_backdrop, ^"modulate:a", 0.0, 1.0)
			tween.play()
	)
