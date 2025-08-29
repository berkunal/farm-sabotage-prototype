extends Node

var player_scores = {1: 0, 2: 0}
var running = false

func _on_hud_time_up() -> void:
	running = false
	print("Game Over!")
	
	for player in get_tree().get_nodes_in_group("players"):
		player.set_process(false)
		player.set_physics_process(false)

	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		var p1 = player_scores[1]
		var p2 = player_scores[2]

		if p1 > p2:
			hud.player_1_score.text = "🏆 Player 1 Wins! (%d)" % p1
			hud.player_2_score.text = "Player 2: %d" % p2
		elif p2 > p1:
			hud.player_2_score.text = "🏆 Player 2 Wins! (%d)" % p2
			hud.player_1_score.text = "Player 1: %d" % p1
		else:
			hud.player_1_score.text = "Draw! %d - %d" % [p1, p2]
			hud.player_2_score.text = ""

func _on_drop_zone_crop_delivered(player_id: int) -> void:
	if player_id in player_scores:
		player_scores[player_id] += 1

	var hud = get_tree().get_first_node_in_group("hud")
	if hud:
		hud.update_score(player_id, player_scores[player_id])
