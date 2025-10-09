class_name QuickTimeEvent extends Control

signal qte_finished

@onready var qte_ring: Sprite2D = $QTERing
@onready var sweet_spot: Sprite2D = $SweetSpot
@onready var timer: Timer = $Timer
@onready var button: Button = $Button

var is_active: bool = false
var required_input = "ui_accept"
var initial_ring_scale: Vector2 = Vector2(0.7, 0.7)
var qte_duration: float = 2.0  # Default duration
var success := false

func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)
	button.pressed.connect(_on_button_pressed)
	reset_qte()

func _process(delta: float) -> void:
	if is_active:
		var shrink_rate = initial_ring_scale.x / qte_duration
		qte_ring.scale.x -= shrink_rate * delta
		qte_ring.scale.y -= shrink_rate * delta

func _on_timer_timeout() -> void:
	if not is_active:
		return

	print("QTE timeout - failed!")
	success = false
	reset_qte()
	qte_finished.emit()

func _on_button_pressed() -> void:
	if not is_active:
		return

	print("Button pressed during QTE!")
	stop_qte()
	check_for_success()

func check_for_success() -> void:
	var current_ring_scale = qte_ring.scale
	print("Ring scale: %s, Sweet spot scale: %s" % [current_ring_scale, sweet_spot.scale])

	if current_ring_scale.x <= sweet_spot.scale.x:
		print("QTE SUCCESS!")
		success = true
	else:
		print("QTE FAILED - too early!")
		success = false

	reset_qte()
	qte_finished.emit()

func start_qte(duration: float = 2.0) -> void:
	if is_active:
		print("QTE already active - ignoring start request")
		return

	print("Starting QTE with duration: %f" % duration)
	qte_duration = duration
	timer.wait_time = duration
	show()
	is_active = true
	qte_ring.scale = initial_ring_scale
	timer.start()

func stop_qte() -> void:
	is_active = false
	timer.stop()

func reset_qte() -> void:
	is_active = false
	timer.stop()
	qte_ring.scale = initial_ring_scale
	hide()
	print("QTE reset and hidden")
