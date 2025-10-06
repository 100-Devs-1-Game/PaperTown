extends Node

const SFX_PLACEHOLDER: AudioStream = preload("res://assets/100devs/warp-306033.mp3")
# TODO: add other SFX/UI/Music etc sounds

# TODO add music playing and fading


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
