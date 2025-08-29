extends Node

var player_scores = {1: 0, 2: 0}

func _ready():
	# Assuming bins are already in the scene when world starts
	var drop_zones = get_tree().get_nodes_in_group("drop_zones")
	for drop_zone in drop_zones:
		drop_zone.connect("crop_delivered", Callable(self, "_on_crop_delivered"))

func _on_crop_delivered(player_id: int):
	if player_id in player_scores:
		player_scores[player_id] += 1

	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.update_score(player_id, player_scores[player_id])
