class_name BattleMenu extends Container

@onready var tongue_button: Button = $MarginContainer/Actions/Tongue
@onready var tail_button: Button = $MarginContainer/Actions/Tail
@onready var run_button: Button = $MarginContainer/Actions/Run

signal action_selected(action_type: BattleEnums.ActionType)


func _ready() -> void:
	setup_button_connections()


func setup_button_connections() -> void:
	if tongue_button:
		tongue_button.pressed.connect(_on_tongue_pressed)
	else:
		print("[Action Menu] ERROR: Tongue button not found!")

	if tail_button:
		tail_button.pressed.connect(_on_tail_pressed)
	else:
		print("[Action Menu] ERROR: Tail button not found!")

	if run_button:
		run_button.pressed.connect(_on_run_pressed)
	else:
		print("[Action Menu] ERROR: Run button not found!")


func _on_tongue_pressed() -> void:
	print("[Action Menu] BattleEnums.ActionType.TONGUE_SLAP = ", BattleEnums.ActionType.TONGUE_SLAP)
	action_selected.emit(BattleEnums.ActionType.TONGUE_SLAP)


func _on_tail_pressed() -> void:
	print("[Action Menu] BattleEnums.ActionType.TAIL_WHIP = ", BattleEnums.ActionType.TAIL_WHIP)
	action_selected.emit(BattleEnums.ActionType.TAIL_WHIP)


func _on_run_pressed() -> void:
	print("[Action Menu] BattleEnums.ActionType.RUN_AWAY = ", BattleEnums.ActionType.RUN_AWAY)
	action_selected.emit(BattleEnums.ActionType.RUN_AWAY)
