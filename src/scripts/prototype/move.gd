extends CharacterBody3D

var move_dir = Vector3.ZERO
var move_speed = 10
var jump_speed = 30
var gravity = -80
var acceleration = 5
var flip_speed = 13
var flip = false

var _velocity = Vector3.ZERO

@onready var player_anim = $player/AnimationPlayer
@onready var sprite = $player


func _physics_process(delta):
	move_and_slide()
	walk()
	jump(delta)
	anim()
	turn()


func walk():
	_velocity = velocity.move_toward(move_dir * move_speed, acceleration)
	velocity.x = _velocity.x
	velocity.z = _velocity.z
	move_dir.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	move_dir.z = Input.get_action_strength("down") - Input.get_action_strength("up")


func turn():
	if Input.get_action_strength("right"):
		flip = false

	elif Input.get_action_strength("left"):
		flip = true

	if flip:
		sprite.rotation_degrees.y = move_toward(sprite.rotation_degrees.y, 0.0, flip_speed)
	else:
		sprite.rotation_degrees.y = move_toward(sprite.rotation_degrees.y, 180, flip_speed)


func jump(delta):
	velocity.y += gravity * delta
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_speed


func anim():
	if move_dir.length() > 0.0 && is_on_floor():
		player_anim.play("02_walk")

	elif is_on_floor():
		player_anim.play("01_Idle")

	else:
		player_anim.play("00_TPose")
