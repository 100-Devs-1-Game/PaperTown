extends Node
# The idea of this is to allow us to "save" a scene outside of the scene tree, and add it back later, so we don't lose any data
# It's a bit scuffed but I think it'll work
# hopefully it can work with F6 on any other scene... maybe?

var root_parent: Node

var current_scene: Node3D
var battle_scene: Node3D
var game_scene: Node3D
var started: bool = false

func _exit_tree() -> void:
	# let's not leak the nodes. whichever scene is not "current" is not in the tree, so we have to free it
	# using free vs queue_free because I don't think there is an opportunity next frame to free them? idk
	if current_scene == battle_scene:
		game_scene.free()
	else:
		battle_scene.free()

func start(root: Node) -> void:
	if started:
		assert(false)
		return

	if not root:
		assert(false)
		return

	root_parent = root

	if !battle_scene:
		battle_scene = preload("res://game/battle/battle.tscn").instantiate()

	if !game_scene:
		game_scene = preload("res://game/game.tscn").instantiate()

	if !current_scene:
		current_scene = game_scene
		if current_scene.get_parent() == null:
			root_parent.add_child(current_scene)

	started = true

func switch_to_battle() -> void:
	print("SWITCHING TO BATTLE")
	assert(started)
	assert(current_scene)
	if current_scene == battle_scene:
		print("BUT ALREADY IN BATTLE")
		return

	if current_scene != game_scene:
		assert(false)
		return

	current_scene.process_mode = Node.PROCESS_MODE_DISABLED
	current_scene.set_physics_process(false)

	root_parent.remove_child(current_scene)
	current_scene = battle_scene
	root_parent.add_child(current_scene)

	current_scene.process_mode = Node.PROCESS_MODE_PAUSABLE
	current_scene.set_physics_process(true)
	print("FINISHED SWITCHING TO BATTLE")


func switch_to_game() -> void:
	print("SWITCHING TO GAME")
	assert(started)
	assert(current_scene)
	if current_scene == game_scene:
		print("BUT ALREADY IN GAME")
		return

	if current_scene != battle_scene:
		assert(false)
		return

	current_scene.process_mode = Node.PROCESS_MODE_DISABLED
	current_scene.set_physics_process(false)

	root_parent.remove_child(current_scene)
	current_scene = game_scene
	root_parent.add_child(current_scene)

	current_scene.process_mode = Node.PROCESS_MODE_PAUSABLE
	current_scene.set_physics_process(true)
	print("FINISHED SWITCHING TO GAME")
