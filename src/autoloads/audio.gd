extends Node

const SFX_PLAYER_DODGE: AudioStream = preload("res://assets/100devs/sfx/F0209PPTWN_action-dodge-miss.ogg")
const SFX_PLAYER_TONGUE: AudioStream = preload("res://assets/100devs/sfx/F0209PPTWN_action-punch-tongue.ogg")
const SFX_PLAYER_WHIP: AudioStream = preload("res://assets/100devs/sfx/F0209PPTWN_action-whip.ogg")
const SFX_BOAR_OINK: AudioStream = preload("res://assets/100devs/sfx/F0209PPTWN_boar-big.ogg")
const SFX_BABY_BOAR_OINK: AudioStream = preload("res://assets/100devs/sfx/F0209PPTWN_boar-small.ogg")
const SFX_ROCKING_CHAIR_START: AudioStream = preload("res://assets/100devs/sfx/F0209PPTWN_chair-a.ogg")
const SFX_ROCKING_CHAIR_STOP: AudioStream = preload("res://assets/100devs/sfx/F0209PPTWN_chair-b.ogg")
const SFX_DOOR_CLOSE: AudioStream = preload("res://assets/100devs/sfx/F0209PPTWN_door-close.ogg")
const SFX_DOOR_OPEN: AudioStream = preload("res://assets/100devs/sfx/F0209PPTWN_door-open.ogg")
const SFX_FOOTSTEP_GRASS_A: AudioStream = preload("res://assets/100devs/sfx/F0209PPTWN_steps-grass-a.ogg")
const SFX_FOOTSTEP_GRASS_B: AudioStream = preload("res://assets/100devs/sfx/F0209PPTWN_steps-grass-b.ogg")
const SFX_FOOTSTEP_GRASS_C: AudioStream = preload("res://assets/100devs/sfx/F0209PPTWN_steps-grass-c.ogg")
const SFX_FOOTSTEP_GRASS_D: AudioStream = preload("res://assets/100devs/sfx/F0209PPTWN_steps-grass-d.ogg")
const SFX_FOOTSTEP_GRASS: Array[AudioStream] = [
	SFX_FOOTSTEP_GRASS_A,
	SFX_FOOTSTEP_GRASS_B,
	SFX_FOOTSTEP_GRASS_C,
	SFX_FOOTSTEP_GRASS_D,
]


const UI_BUTTON_CLICK: AudioStream = preload("res://assets/100devs/sfx/F0209PPTWN_UI-button-click.ogg")
const UI_BUTTON_HIGHLIGHT: AudioStream = preload("res://assets/100devs/sfx/F0209PPTWN_UI-button-highlight.ogg")


const MUSIC_OVERWORLD: AudioStream = preload("res://assets/100devs/music/a_good_vibe.ogg")
const MUSIC_COMBAT: AudioStream = preload("res://assets/100devs/music/charge.ogg")


const MUSIC_FADE_TIME: float = 1.0
var music_player: AudioStreamPlayer
var next_song: AudioStream
var music_tween: Tween
var music_timer: Timer

func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(music_player)
	music_player.bus = &"Music"
	assert(AudioServer.get_bus_index(music_player.bus) >= 0)

	music_timer = Timer.new()
	music_timer.one_shot = true
	add_child(music_timer)
	music_timer.timeout.connect(_on_music_loop_timeout)


func play_music(music: AudioStream) -> void:
	if !music:
		push_error("tried to make SFX but provided invalid audio stream")
		assert(false)
		return

	if music_player.stream == music:
		print("PLAYING MUSIC THAT IS ALREADY PLAYING: ", music.resource_path)
		return

	if music_player.stream:
		print("MUSIC WILL CHANGE FROM '", music_player.stream.resource_path, "' TO '", music.resource_path, "'")
	else:
		print("MUSIC WILL CHANGE TO '", music.resource_path, "'")

	next_song = music
	_fade_music_out_in()


func _fade_music_out_in() -> void:
	if music_tween:
		music_tween.kill()

	if music_player.playing:
		music_tween = create_tween()
		music_tween.tween_property(music_player, ^"volume_db", -40, MUSIC_FADE_TIME)
		music_tween.tween_callback(
			func():
				music_player.stop()
				_start_next_song()
		)
	else:
		_start_next_song()


func _start_next_song() -> void:
	if !next_song:
		next_song = music_player.stream

	music_player.stream = next_song
	music_player.volume_db = -40
	music_player.play()

	var fade_in := create_tween()
	fade_in.tween_property(music_player, ^"volume_db", 0, MUSIC_FADE_TIME)

	_schedule_music_loop_fade()


func _schedule_music_loop_fade() -> void:
	if !music_player.stream:
		return

	var duration := music_player.stream.get_length()
	if duration <= 0:
		return

	music_timer.start(max(0.1, duration - MUSIC_FADE_TIME))


func _on_music_loop_timeout() -> void:
	if !music_player.stream:
		return

	var fade_out := create_tween()
	fade_out.tween_property(music_player, "volume_db", -40, MUSIC_FADE_TIME)
	fade_out.tween_callback(func():
		music_player.stop()
		music_player.play()
		var fade_in := create_tween()
		fade_in.tween_property(music_player, "volume_db", 0, MUSIC_FADE_TIME)
		_schedule_music_loop_fade()
	)


func make_sfx(sfx: AudioStream, pitch_offset: float) -> AudioStreamPlayer3D:
	if !sfx:
		push_error("tried to make SFX but provided invalid audio stream")
		assert(false)
		return null

	var audioplayer := AudioStreamPlayer3D.new()
	audioplayer.name = "AudioSFX " + sfx.resource_path.get_file()
	add_child(audioplayer)
	audioplayer.finished.connect(func(): audioplayer.queue_free())

	audioplayer.stream = sfx
	audioplayer.bus = &"SFX"
	audioplayer.pitch_scale = randf_range(1.0 - pitch_offset, 1.0 + pitch_offset)

	return audioplayer


# make sure the node stays alive until it stops playing! otherwise use the 'atpos' func
func play_sfx_atnode(
	node: Node3D, sfx: AudioStream, pitch_offset: float = 0.15
) -> AudioStreamPlayer3D:
	if !node:
		push_error("tried to make SFX but provided invalid node")
		assert(false)
		return null

	var audioplayer := make_sfx(sfx, pitch_offset)

	remove_child(audioplayer)
	node.add_child(audioplayer)

	audioplayer.play()
	return audioplayer


func play_sfx_atpos(
	pos: Vector3, sfx: AudioStream, pitch_offset: float = 0.15
) -> AudioStreamPlayer3D:
	var audioplayer := make_sfx(sfx, pitch_offset)
	audioplayer.global_position = pos
	audioplayer.play()
	return audioplayer


func make_ui(ui: AudioStream, pitch_offset: float) -> AudioStreamPlayer:
	if !ui:
		push_error("tried to make UI but provided invalid audio stream")
		assert(false)
		return null

	var audioplayer := AudioStreamPlayer.new()
	audioplayer.name = "AudioUI" + ui.resource_path.get_file()
	add_child(audioplayer)
	audioplayer.finished.connect(func(): audioplayer.queue_free())

	audioplayer.stream = ui
	audioplayer.bus = &"UI"
	audioplayer.pitch_scale = randf_range(1.0 - pitch_offset, 1.0 + pitch_offset)

	return audioplayer


func play_ui(ui: AudioStream, pitch_offset: float = 0.15) -> AudioStreamPlayer:
	var audioplayer := make_ui(ui, pitch_offset)
	audioplayer.play()
	return audioplayer
