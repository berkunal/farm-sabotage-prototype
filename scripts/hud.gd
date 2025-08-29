extends CanvasLayer

@onready var player_1_score: Label = $HBoxContainer/Player1Score
@onready var player_2_score: Label = $HBoxContainer/Player2Score

func _ready() -> void:
	add_to_group("hud")

func update_score(player_id: int, score: int):
	match player_id:
		1:
			player_1_score.text = "Player 1: %d" % score
		2:
			player_2_score.text = "Player 2: %d" % score
