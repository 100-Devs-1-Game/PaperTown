extends GutTest


func test_node_state_machine() -> void:
	var nsm = NodeFiniteStateMachine.new()
	var idle_double = double(NodeStateMachineState).new()
	nsm.add_child(idle_double)
	var walking_double = double(NodeStateMachineState).new()
	nsm.add_child(walking_double)

	add_child_autofree(nsm)
	nsm.current_state = idle_double

	gut.simulate(nsm, 5, 0.1)

	assert_called_count(idle_double.on_enter, 1)
	assert_called_count(walking_double.on_enter, 0)
	assert_called_count(idle_double.on_exit, 0)
	assert_called_count(walking_double.on_exit, 0)

	assert_called_count(idle_double.on_process, 5)
	assert_called_count(walking_double.on_process, 0)

	nsm.current_state = walking_double

	assert_called_count(idle_double.on_enter, 1)
	assert_called_count(walking_double.on_enter, 1)
	assert_called_count(idle_double.on_exit, 1)
	assert_called_count(walking_double.on_exit, 0)

	gut.simulate(nsm, 8, 0.1)

	assert_called_count(idle_double.on_process, 5)
	assert_called_count(walking_double.on_process, 8)
