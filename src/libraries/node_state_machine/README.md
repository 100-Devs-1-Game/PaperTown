# Node Finite State Machine

State machine where each state is added as a child that is a subclass of NodeStateMachineState

Each state can then implement various lifecycle methods based on their needs, eg.:
- on_init called in a deferred call
- on_process and on_physics_process called each _process and _physics_process tick unles paused
- on_enter and on_leave called on state change
- many more...

state_entered, state_exited and finshed signals are emitted on various state changes

NodeStateMachineState implements empty methods for all of these

See res://tests/unit/test_node_state_machine.gd for sample usage
