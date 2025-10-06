extends CharacterBody3D

enum State { NPC, FOLLOWER, BATTLE }

@export var player: CharacterBody3D

var current_state : State
var facing_behind := false

@onready var npc_component = $NPCComponent
@onready var follower_component = $FollowerComponent
@onready var movement_component = $MovementComponent
@onready var navigation_agent_3d = $NavigationAgent3D
@onready var animated_sprite_3d = $Visuals/AnimatedSprite3D

signal rudolph_state_changed

func _ready():
	npc_component.interacted_with.connect(on_interacted_with)

func _physics_process(delta):
	movement_component.apply_gravity(delta, self)
	
	match current_state:
		State.NPC:
			pass
		State.FOLLOWER:
			follow_player()
		State.BATTLE:
			pass

func follow_player():
	follower_component.follow_player(navigation_agent_3d, movement_component, player, self)
	facing_behind = true if velocity.z < 0 else false
	play_animations()

func on_interacted_with():
	npc_component.is_talkable = false
	change_state(State.FOLLOWER) # TODO: full code has to be a bit more complex

func change_state(new_state: State) -> void:
	if current_state == new_state:
		return
	current_state = new_state
	rudolph_state_changed.emit(current_state)
	
func play_animations():	
	var string_prefix := ""
	var string_suffix := ""
	var full_string := ""
	
	if facing_behind:
		string_suffix = "_behind"
	
	if not follower_component.following_player:
		string_prefix = "idle"
	else:
		string_prefix = "walk"
	
	full_string = string_prefix + string_suffix
	
	animated_sprite_3d.play(full_string)
