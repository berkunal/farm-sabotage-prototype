extends CanvasLayer

signal time_up

@onready var player_1_score: Label = $HBoxContainer/Player1Score
@onready var player_2_score: Label = $HBoxContainer/Player2Score
@onready var timer_label: Label = $HBoxContainer/Timer
@onready var countdown_timer: Timer = $CountdownTimer

var remaining_time = 30

func _ready() -> void:
	add_to_group("hud")
	countdown_timer.connect("timeout", Callable(self, "_on_timer_tick"))

func update_score(player_id: int, score: int):
	match player_id:
		1:
			player_1_score.text = "Player 1: %d" % score
		2:
			player_2_score.text = "Player 2: %d" % score

func _on_timer_tick():
	remaining_time -= 1
	_update_timer_label()
	if remaining_time <= 0:
		countdown_timer.stop()
		emit_signal("time_up")

func _update_timer_label():
	timer_label.text = "%d" % remaining_time
