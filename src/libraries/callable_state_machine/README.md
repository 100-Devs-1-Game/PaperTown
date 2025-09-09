# Callable State machine

State machine where each state provides three callable methods through CallableStareMachine.add_state:
- normal: intended to be called in _process or _physics_process
- enter: called when the state is entered
- leave: called when leaving the state(before enter of the new state)

A state_changed signal is emitted on completion of the state change

See res://tests/unit/test_callable_state_machine.gd for sample usage
