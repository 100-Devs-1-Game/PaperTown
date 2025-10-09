class_name BattleMenu extends Control

signal action_selected(action_type: GlobalUtils.PlayerAction, target_index: int)
signal menu_state_changed(menu_state: GlobalUtils.MenuState)

@onready var tongue_button: Button = $BattleMenu/ActionSelection/TongueButton
@onready var tail_button: Button = $BattleMenu/ActionSelection/TailButton
@onready var run_button: TextureButton = $BattleMenu/RunButton
@onready var target_selection: Container = $TargetSelection

var current_state: GlobalUtils.MenuState
var selected_action: GlobalUtils.PlayerAction


func change_state(new_state: GlobalUtils.MenuState) -> void:
	if current_state == new_state:
		return
	current_state = new_state
	menu_state_changed.emit(current_state)


func _ready() -> void:
	# Connect Signals
	tongue_button.pressed.connect(_on_action_selected.bind(GlobalUtils.PlayerAction.TONGUE_SLAP))
	tail_button.pressed.connect(_on_action_selected.bind(GlobalUtils.PlayerAction.TAIL_WHIP))
	run_button.pressed.connect(_on_action_selected.bind(GlobalUtils.PlayerAction.RUN_AWAY))

	target_selection.target_selected.connect(_on_target_selected)

	hide_menu()


func _on_action_selected(action: GlobalUtils.PlayerAction) -> void:
	if action == GlobalUtils.PlayerAction.RUN_AWAY:
		# Run away doesn't need target selection
		action_selected.emit(action, -1)
		hide_menu()
	else:
		# Attack actions need target selection
		selected_action = action
		hide_menu()
		show_target_selection()


func show_target_selection() -> void:
	change_state(GlobalUtils.MenuState.TARGET_SELECTION)
	target_selection.activate()


func _on_target_selected(target_index: int) -> void:
	# Emit the complete action with target
	action_selected.emit(selected_action, target_index)
	hide_target_selection()
	hide_menu()


func hide_target_selection() -> void:
	target_selection.hide()
	show_menu()


func show_menu() -> void:
	if $BattleMenu.is_visible_in_tree():
		pass
	change_state(GlobalUtils.MenuState.ACTIVE)
	$BattleMenu.show()


func hide_menu() -> void:
	if not $BattleMenu.is_visible_in_tree():
		pass
	change_state(GlobalUtils.MenuState.INACTIVE)
	$BattleMenu.hide()
