@tool
extends Control

const BUTTON_WIDTH = 400

@onready var button_container: VBoxContainer = %"VBoxContainer | Buttons"
@onready var play: Button = %Play
@onready var settings: Button = %Settings
@onready var quit: Button = %Quit


func get_rtl(btn: Button) -> RichTextLabel:
	return btn.get_node("Control/RichTextLabel") as RichTextLabel


func _ready() -> void:
	# control the size of our buttons, if you change it and wanna see it, then...
	# Scene -> Reload Saved Scene
	button_container.custom_minimum_size.x = BUTTON_WIDTH
	button_container.resized.connect(func(): button_container.custom_minimum_size.x = BUTTON_WIDTH)

	play.pressed.connect(animate.bind(play))
	settings.pressed.connect(animate.bind(settings))
	quit.pressed.connect(animate.bind(quit))

	play.mouse_entered.connect(mouse_enter.bind(play))
	settings.mouse_entered.connect(mouse_enter.bind(settings))
	quit.mouse_entered.connect(mouse_enter.bind(quit))

	play.mouse_exited.connect(mouse_exit.bind(play))
	settings.mouse_exited.connect(mouse_exit.bind(settings))
	quit.mouse_exited.connect(mouse_exit.bind(quit))

	mouse_exit(play)
	mouse_exit(settings)
	mouse_exit(quit)

	get_rtl(play).clear()
	get_rtl(play).append_text("[wave amp=50]" + play.name.to_upper())
	get_rtl(settings).clear()
	get_rtl(settings).append_text("[wave amp=50]" + settings.name.to_upper())
	get_rtl(quit).clear()
	get_rtl(quit).append_text("[wave amp=50]" + quit.name.to_upper())


func mouse_enter(btn: Button) -> void:
	get_rtl(btn).add_theme_color_override("font_outline_color", Color.hex(0xe55784ff))


func mouse_exit(btn: Button) -> void:
	get_rtl(btn).add_theme_color_override("font_outline_color", Color.hex(0xf8aeccff))


func animate(button_pressed: Button) -> void:
	var quitting: bool = button_pressed == quit
	var count: Array = []

	for btn: Control in button_container.get_children():
		btn.mouse_filter = MOUSE_FILTER_IGNORE

		var physcomp := preload("res://game/ui/components/physics_ui.gd").new()
		if btn == button_pressed:
			physcomp.velocity = Vector2(1000, randf_range(-600, -2000))
		else:
			physcomp.velocity = Vector2(-1000, randf_range(-600, -2000))
		btn.add_child(physcomp)
		physcomp.tree_exited.connect(func(): count.append(0))

	var physcomp := preload("res://game/ui/components/physics_ui.gd").new()
	physcomp.velocity = Vector2(0, randf_range(1200, 1200))
	physcomp.gravity *= -1
	$PanelContainer/VBoxContainer/FloatingText.add_child(physcomp)
	physcomp.tree_exited.connect(func(): count.append(0))

	var physcomp2 := preload("res://game/ui/components/physics_ui.gd").new()
	physcomp2.velocity = Vector2(0, randf_range(-600, -600))
	physcomp2.gravity /= 2.0
	$PanelContainer/VBoxContainer/Control.add_child(physcomp2)
	physcomp2.tree_exited.connect(func(): count.append(0))

	while count.size() < button_container.get_child_count() + 2:
		await get_tree().process_frame

	if quitting:
		get_tree().quit()
	else:
		queue_free()
