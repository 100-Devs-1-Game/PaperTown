class_name QuickTimeEvent extends Control

signal qte_result(qte_success: bool)
signal qte_finished  # ✅ Add this signal to indicate QTE is completely done

@onready var qte_ring: Sprite2D = $QTERing
@onready var sweet_spot: Sprite2D = $SweetSpot
@onready var timer: Timer = $Timer
@onready var button: Button = $Button

var is_active: bool = false
var required_input = "ui_accept"
var initial_ring_scale: Vector2 = Vector2(0.7, 0.7)


func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)
	button.pressed.connect(_on_button_pressed)
	reset_qte()


func _process(delta: float) -> void:
	if is_active:
		var shrink_rate = 0.7 / timer.wait_time
		qte_ring.scale.x -= shrink_rate * delta
		qte_ring.scale.y -= shrink_rate * delta


func _on_timer_timeout() -> void:
	if not is_active:  # ✅ Safety check
		return

	print("QTE timeout - failed!")
	qte_result.emit(false)
	reset_qte()
	qte_finished.emit()  # ✅ Signal that QTE is completely done


func _on_button_pressed() -> void:
	if not is_active:  # ✅ Safety check
		return

	print("Button pressed during QTE!")
	stop_qte()
	check_for_success()


func check_for_success() -> void:
	var current_ring_scale = qte_ring.scale
	print("Ring scale: %s, Sweet spot scale: %s" % [current_ring_scale, sweet_spot.scale])

	# Check if ring is smaller than or equal to sweet spot (successful hit)
	if current_ring_scale.x <= sweet_spot.scale.x:
		print("QTE SUCCESS!")
		qte_result.emit(true)
	else:
		print("QTE FAILED - too early!")
		qte_result.emit(false)

	reset_qte()
	qte_finished.emit()  # ✅ Signal that QTE is completely done


func start_qte() -> void:
	if is_active:  # ✅ Don't start if already active
		print("QTE already active - ignoring start request")
		return

	print("Starting QTE...")
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
