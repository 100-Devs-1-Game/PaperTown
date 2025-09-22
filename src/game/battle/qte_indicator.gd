class_name TimedInputEvent extends Control

signal qte_success
signal qte_failure

@onready var qte_bar: ColorRect = $"QTE Bar"
@onready var sweet_spot: ColorRect = $"sweet spot"
@onready var timer: Timer = $Timer

var is_active = false
var required_input = "ui_accept"

func _ready() -> void:
	hide()
	timer.timeout.connect(_on_timer_timeout)

func start_qte() -> void:
	is_active = true
	show()
	qte_bar.size.x = 200
	timer.start()

func _process(delta: float) -> void:
	if is_active:
		var shrink_rate = 200 / timer.wait_time
		qte_bar.size.x -= max(0, qte_bar.size.x - shrink_rate * delta)

		if Input.is_action_just_pressed(required_input):
			if qte_bar.get_global_rect().intersects(sweet_spot.get_global_rect()):
				check_for_success()
			else:
				qte_failure.emit()
				is_active = false
				timer.stop()
				hide()

func check_for_success():
	var bar_end_x = qte_bar.global_position.x + qte_bar.size.x
	var zone_start_x = sweet_spot.global_position.x
	var zone_end_x = sweet_spot.global_position.x + sweet_spot.size.x

	if bar_end_x >= zone_start_x and bar_end_x <= zone_end_x:
		qte_success.emit()
		is_active = false
		timer.stop()
		hide()
	else:
		qte_failure.emit()
		is_active = false
		timer.stop()
		hide()

func _on_timer_timeout() -> void:
	qte_failure.emit()
	is_active = false
	timer.stop()
	hide()
