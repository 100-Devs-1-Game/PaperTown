extends Node

@export var battle_scene : PackedScene
@export var screen_transistion : PackedScene

func _ready():
	Signals.battle_started.connect(start_battle)
	
	
func start_battle(body):
	var screen_transistion_instance = screen_transistion.instantiate()
	get_tree().root.add_child(screen_transistion_instance)
	screen_transistion_instance.do_transition(ScreenTransition.TransitionType.BATTLE_START)
	await screen_transistion_instance.transition_halfway
	get_tree().change_scene_to_packed(battle_scene)
