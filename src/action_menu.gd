extends Container

@onready var tongue_button: Button = $MarginContainer/HBoxContainer/Tongue
@onready var tail_button: Button = $MarginContainer/HBoxContainer/Tail
@onready var run_button: Button = $MarginContainer/HBoxContainer/Run
const BattleManager = preload("uid://ckeeoresabf6t")

signal action_selected(action_type: BattleManager.ActionType)


func _ready() -> void:
	setup_button_connections()


func setup_button_connections() -> void:
	if tongue_button:
		tongue_button.pressed.connect(_on_tongue_pressed)
	if tail_button:
		tail_button.pressed.connect(_on_tail_pressed)
	if run_button:
		run_button.pressed.connect(_on_run_pressed)


func _on_tongue_pressed() -> void:
	action_selected.emit("TONGUE_SLAP")


func _on_tail_pressed() -> void:
	action_selected.emit("TAIL_WHIP")


func _on_run_pressed() -> void:
	action_selected.emit("RUN_AWAY")
