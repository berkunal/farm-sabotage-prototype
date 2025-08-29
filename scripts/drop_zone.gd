extends Area3D


signal crop_delivered(player_id: int)

func _ready():
	add_to_group("drop_zones")
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	# Check if the thing is a crop
	if body.is_in_group("crops") and body.get("last_owner") != null:
		var player_id = body.last_owner.player_id
		emit_signal("crop_delivered", player_id)

		# Delete crop from scene
		body.queue_free()
