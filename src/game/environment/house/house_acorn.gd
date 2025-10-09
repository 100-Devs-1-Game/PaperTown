class_name House extends Node3D


@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var door_zone: Area3D = %DoorZone
@onready var camera_target: Node3D = $CameraTarget
@onready var indoor_zone: Area3D = %IndoorZone

var camera: Camera

signal opening
signal opened
signal closing
signal closed

var is_open := false

func _ready() -> void:
	door_zone.body_entered.connect(
		func(body: Node3D):
			if not body:
				return

			var player := body as Player
			if not player:
				return

			if not is_open:
				open()
	)

	door_zone.body_exited.connect(
		func(body: Node3D):
			if not body:
				return

			var player := body as Player
			if not player:
				return

			if is_open and not is_indoors(player):
				close()
	)

func is_indoors(body: CharacterBody3D) -> bool:
	return body in indoor_zone.get_overlapping_bodies()

func _physics_process(_delta: float) -> void:
	if !camera:
		camera = get_tree().get_first_node_in_group("camera")

func open() -> void:
	if is_open:
		return
	assert(camera)

	var old_player_state := Dialogue.player.current_state
	if old_player_state == Player.State.CUTSCENE:
		old_player_state = Player.State.MOVEMENT

	Dialogue.player.change_state(Player.State.CUTSCENE)

	animation_player.play(&"house")
	opening.emit()
	camera.state = Camera.State.MANUAL
	camera.target = camera_target
	Audio.play_sfx_atnode(self, Audio.SFX_DOOR_OPEN)
	await animation_player.animation_finished
	is_open = true
	opened.emit()

	Dialogue.player.change_state(old_player_state)


func close() -> void:
	if not is_open:
		return

	var old_player_state := Dialogue.player.current_state
	if old_player_state == Player.State.CUTSCENE:
		old_player_state = Player.State.MOVEMENT

	Dialogue.player.change_state(Player.State.CUTSCENE)

	animation_player.play_backwards(&"house")
	closing.emit()
	camera.state = Camera.State.FOLLOW_PLAYER
	camera.target = null
	Audio.play_sfx_atnode(self, Audio.SFX_DOOR_CLOSE)
	await animation_player.animation_finished
	is_open = false
	closed.emit()

	Dialogue.player.change_state(old_player_state)
