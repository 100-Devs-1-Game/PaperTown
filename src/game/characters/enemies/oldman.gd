extends CharacterBody3D

@onready var npc_component: NPCComponent = $NPCComponent
@onready var animated_sprite_3d: AnimatedSprite3D = $Visuals/AnimatedSprite3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	npc_component.interacted_with.connect(on_interacted_with)

func on_interacted_with():
	pass
