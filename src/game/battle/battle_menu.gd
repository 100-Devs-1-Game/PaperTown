class_name BattleMenu extends Control

@onready var tongue_button: Button = $ButtonContainer/TongueButton
@onready var tail_button: Button = $ButtonContainer/TailButton
@onready var run_button: Button = $ButtonContainer/RunButton

signal action_selected(action_type: GlobalUtils.PlayerAction)
signal menu_state_changed(menu_state: GlobalUtils.MenuState)

var current_state: GlobalUtils.MenuState

func _ready() -> void:
	# Connect Signals
	tongue_button.pressed.connect(_on_tongue_pressed)
	tail_button.pressed.connect(_on_tail_pressed)
	run_button.pressed.connect(_on_run_pressed)

	hide_menu()

func _on_tongue_pressed() -> void:
	action_selected.emit(GlobalUtils.PlayerAction.TONGUE_SLAP)

func _on_tail_pressed() -> void:
	action_selected.emit(GlobalUtils.PlayerAction.TAIL_WHIP)

func _on_run_pressed() -> void:
	action_selected.emit(GlobalUtils.PlayerAction.RUN_AWAY)

func show_menu() -> void:
	if self.is_visible_in_tree(): pass
	current_state = GlobalUtils.MenuState.ACTIVE
	menu_state_changed.emit(current_state)
	self.show()

func hide_menu() -> void:
	if not self.is_visible_in_tree(): pass
	current_state = GlobalUtils.MenuState.INACTIVE
	menu_state_changed.emit(current_state)
	self.hide()
