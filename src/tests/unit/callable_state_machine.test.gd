extends GutTest

var idle_normal_calls: int
var idle_enter_calls: int
var idle_leave_calls: int
var walking_normal_calls: int
var walking_enter_calls: int
var walking_leave_calls: int


func _idle_normal():
	idle_normal_calls += 1


func _idle_enter():
	idle_enter_calls += 1


func _idle_leave():
	idle_leave_calls += 1


func _walking_normal():
	walking_normal_calls += 1


func _walking_enter():
	walking_enter_calls += 1


func _walking_leave():
	walking_leave_calls += 1


func test_callable_state_machine() -> void:
	var csm = CallableStateMachine.new()

	csm.add_state(_idle_normal, _idle_enter, _idle_leave)
	csm.add_state(_walking_normal, _walking_enter, _walking_leave)
	csm.set_initial_state(_idle_normal)

	assert_eq(idle_enter_calls, 1, "Enter not called on set initial state")
	assert_eq(walking_enter_calls, 0, "Enter called on wrong state")
	assert_eq(idle_leave_calls, 0, "Leave called on set inital state")
	assert_eq(walking_enter_calls, 0, "Leave called on set inital state")

	for i in range(5):
		csm.update()

	assert_eq(idle_normal_calls, 5, "Update callable not called")
	assert_eq(walking_normal_calls, 0, "Update callable called on wrong state")

	csm.change_state(_walking_normal, true)

	assert_eq(idle_enter_calls, 1, "Enter called on wrong state")
	assert_eq(walking_enter_calls, 1, "Enter not called on change state")
	assert_eq(idle_leave_calls, 1, "Leave not called on change state")
	assert_eq(walking_leave_calls, 0, "Leave called on wrong state")

	for i in range(3):
		csm.update()

	assert_eq(idle_normal_calls, 5, "Update callable called on wrong state")
	assert_eq(walking_normal_calls, 3, "Update callable not called")
