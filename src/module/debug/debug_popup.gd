class_name DebugPopup
extends Control

## Title for the popup
@export var title: String = "DebugPopup"

## Optional functions node where the callable functions live
@export var functions_node: Node:
	set = set_functions_node

## Show the debug panel on start
@export var visible_on_start: bool = false

## Define a collection of default debug buttons
@export var default_debug_buttons: DebugButtonCollection

## Define debug buttons by providing the names of functions to call on press.
@export var custom_debug_buttons: Array[DebugButton]

## Set this to [code]false[/code] if we want DebugPopup to work on release (non-debug) builds.
## Recommended to leave this [code]true[/code] so players can't cheat the final game.
var _disable_on_release: bool = false

## An array of dictionary objects with text_keycode and button properties.
var _hotkeys: Array = []

var _tree: Tree
var _tree_root: TreeItem
var _tree_shortcuts: TreeItem
var _tree_callables: Dictionary = {}

var _last_input_event: InputEvent


func _ready() -> void:
	# Don't allow the DebugPopup to work on release builds.
	if _disable_on_release and not OS.is_debug_build():
		visible = false
		return

	# By default, the debug popup is not visible. Press 'X' to bring it up.
	visible = visible_on_start
	position = Vector2.ZERO
	_tree = $Tree
	_tree.allow_rmb_select = true
	_tree.gui_input.connect(_on_gui_input)
	_tree.item_selected.connect(_on_item_selected)

	_setup_shortcuts_tree()
	_setup_debug_buttons()

	# By default, the functions_node is just the parent of this popup.
	if !functions_node:
		functions_node = get_parent()


func _exit_tree() -> void:
	if _tree_shortcuts != null:
		_tree_shortcuts.free()


func set_functions_node(node: Node) -> void:
	functions_node = node
	if functions_node:
		get_tree_root().set_text(0, title + " (" + functions_node.name + ")")


func get_tree_root() -> TreeItem:
	if !_tree_root:
		_tree_root = $Tree.create_item()
	return _tree_root


func register_hotkey(text_keycode: String, callable: Callable) -> void:
	_hotkeys.append({"text_keycode": text_keycode, "callable": callable})


func link_callable(tree_item: TreeItem, callable: Callable) -> void:
	_tree_callables[tree_item.get_instance_id()] = callable


func was_rmb() -> bool:
	assert(_last_input_event)
	if _last_input_event is InputEventMouseButton and _last_input_event.pressed:
		var mb_event := _last_input_event as InputEventMouseButton
		if mb_event.button_index == MOUSE_BUTTON_RIGHT:
			return true

	return false


func _setup_shortcuts_tree() -> void:
	_tree_shortcuts = get_tree_root().create_child()
	_tree_shortcuts.set_text(0, "Navigation and functions")


func _get_debug_buttons() -> Array[DebugButton]:
	if default_debug_buttons && default_debug_buttons.collection:
		return default_debug_buttons.collection + custom_debug_buttons

	return custom_debug_buttons


func _setup_debug_buttons() -> void:
	for debug_button in _get_debug_buttons():
		var new_item = _tree_shortcuts.create_child()
		_setup_item(debug_button, new_item)


func _on_gui_input(event: InputEvent) -> void:
	_last_input_event = event


func _on_item_selected():
	var selected: TreeItem = $Tree.get_selected()
	if _tree_callables.has(selected.get_instance_id()):
		$Tree.deselect_all()
		$Tree.release_focus()
		var callable: Callable = _tree_callables[selected.get_instance_id()]
		# Why deferred?
		# As a rule of thumb, never call change_scene* during the same frame
		#  as GUI event handlers (e.g., _on_item_selected, _pressed,
		# _input_event, etc.). Always defer or delay it.
		callable.call_deferred()


func _setup_item(debug_button: DebugButton, new_item: TreeItem) -> void:
	if debug_button.func_or_path.begins_with("res://"):
		_add_change_scene_item(debug_button, new_item)
	else:
		_add_function_call_item(debug_button, new_item)


func _add_change_scene_item(debug_button: DebugButton, new_item: TreeItem) -> void:
	var scene_path = debug_button.func_or_path
	var scene_filename = scene_path.get_file()

	var item_pressed = Callable(self, "_change_scene").bind(scene_path)
	link_callable(new_item, item_pressed)

	if debug_button.hotkey != "":
		register_hotkey(debug_button.hotkey, item_pressed)
		new_item.set_text(0, "[" + debug_button.hotkey + "] go to " + scene_filename)
	else:
		new_item.set_text(0, "go to " + scene_filename)


func _add_function_call_item(debug_button: DebugButton, new_item: TreeItem) -> void:
	var function_name = debug_button.func_or_path
	var item_pressed = Callable(self, "_call_function").bind(function_name)
	link_callable(new_item, item_pressed)
	if debug_button.hotkey != "":
		register_hotkey(debug_button.hotkey, item_pressed)
		new_item.set_text(0, "[" + debug_button.hotkey + "] " + function_name + "()")
	else:
		new_item.set_text(0, function_name + "()")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_debug_popup"):
		print("Toggling the DebugPopup")
		visible = !visible
	elif event is InputEventKey and event.is_pressed():
		if visible:
			print("Pressed " + event.as_text_keycode())

		for hotkey in _hotkeys:
			if event.as_text_keycode().to_lower() == hotkey.text_keycode.to_lower():
				hotkey.callable.call()


func _call_function(function_name: String) -> void:
	if function_name == "":
		push_error("No function name set for debug button.")
		return

	if functions_node == null:
		push_error("Missing parent node - cannot call function " + function_name + "()")
		return

	print("Calling " + functions_node.name + "." + function_name + "()")
	if not functions_node.has_method(function_name):
		push_error("Tried to call non-existing function %s" % function_name)
		return

	functions_node.call(function_name)


func _change_scene(scene_path: String) -> void:
	if scene_path == "":
		push_error("No scene_path defined for placeholder button target")
		return

	print("Changing scene to: " + scene_path)
	get_tree().change_scene_to_packed(load(scene_path))
