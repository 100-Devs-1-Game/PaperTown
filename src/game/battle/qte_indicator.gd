class_name QuickTimeEvent extends Control

signal qte_result(qte_success: bool)

@onready var qte_ring: Sprite2D = $QTERing
@onready var sweet_spot: Sprite2D = $SweetSpot
@onready var timer: Timer = $Timer
@onready var button: Button = $Button

var is_active: bool
var required_input = "ui_accept"
var initial_ring_scale: Vector2 = Vector2(.7, .7)
var current_ring_scale: Vector2


func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)
	button.pressed.connect(_on_button_pressed)
	is_active = false
	hide()


func _process(delta: float) -> void:
	if is_active:
		var shrink_rate = .7 / timer.wait_time
		qte_ring.scale.x -= shrink_rate * delta
		qte_ring.scale.y -= shrink_rate * delta
		if qte_ring.scale.x <= 0.01 or qte_ring.scale.y <= 0.01:
			qte_result.emit(false)
			is_active = false
			timer.stop()
			return


func start_qte() -> void:
	show()
	is_active = true
	qte_ring.scale = initial_ring_scale
	timer.start()


func check_for_success():
	print("Current Ring Size: %s" % current_ring_scale)
	print("Sweet Spot Size: %s" % sweet_spot.scale)
	if current_ring_scale <= sweet_spot.scale:
		qte_result.emit(true)
		print(qte_result)
		is_active = false
	else:
		qte_result.emit(false)
		print(qte_result)
		is_active = false


func _on_timer_timeout() -> void:
	qte_result.emit(false)
	is_active = false
	timer.stop()
	return


func _on_button_pressed() -> void:
	if is_active:
		current_ring_scale = qte_ring.get_scale()
		if current_ring_scale.length() > sweet_spot.scale.length():
			qte_ring.scale = current_ring_scale
			timer.stop()
			check_for_success()
