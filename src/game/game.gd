class_name Game
extends Node3D

@onready var everything: Everything = %Everything
@onready var scale_count: Label = %ScaleCount
@onready var animation_player: AnimationPlayer = %AnimationPlayer

var overworld_manager: OverworldManager

func _ready() -> void:
	Audio.play_music(Audio.MUSIC_OVERWORLD)
	Signals.pet_unlocked.connect(func():
		animation_player.play(&"pet_unlock")
	)

	Signals.battle_lost.connect(func(_enemy: ICharacter):
		Dialogue.player.stats.scales -= 1
		Dialogue.player.stats.scales = max(Dialogue.player.stats.scales, 0)
	)

	overworld_manager = get_tree().get_first_node_in_group(&"overworld")
	assert(overworld_manager)


func _physics_process(_delta: float) -> void:
	%Scales.visible = Dialogue.player.stats.scales > 0
	scale_count.text = str(Dialogue.player.stats.scales)
