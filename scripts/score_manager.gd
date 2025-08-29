extends Node

var scores = {1: 0, 2: 0}

func register_drop_zone(drop_zone):
	drop_zone.connect("crop_delivered", Callable(self, "_on_crop_delivered"))

func _on_crop_delivered(player_id: int):
	if scores.has(player_id):
		scores[player_id] += 1
