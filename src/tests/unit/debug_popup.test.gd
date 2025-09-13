extends GutTest

var called_times: int


func _fake_button_func():
	called_times += 1


func test_debug_popup() -> void:
	var debug_popup = load("res://libraries/debug/debug_popup.tscn").instantiate()
	debug_popup.default_debug_buttons = DebugButtonCollection.new()
	var fake_debug_button = DebugButton.new()
	fake_debug_button.func_or_path = "_fake_button_func"
	fake_debug_button.hotkey = "7"
	debug_popup.default_debug_buttons.collection.append(fake_debug_button)
	var sender = InputSender.new(debug_popup)
	add_child_autofree(debug_popup)

	sender.action_down("toggle_debug_popup")

	await wait_seconds(0.1)
	assert_eq(debug_popup.visible, true, "Visible on start busted")

	sender.key_down("7")
	await wait_seconds(0.1)
	assert_eq(called_times, 1, "Shortcut not registered")

	var tree: Tree = debug_popup.get_child(0)
	var navigation_column: TreeItem = tree.get_root().get_next_in_tree()
	assert_eq(navigation_column.get_text(0), "Navigation and functions")
	var fake_debug_button_node: TreeItem = navigation_column.get_next_in_tree()
	assert_eq(fake_debug_button_node.get_text(0), "[7] _fake_button_func()")
	tree.set_selected(fake_debug_button_node, 0)

	await wait_seconds(0.1)
	assert_eq(called_times, 2, "Button not found")

	debug_popup.queue_free()
