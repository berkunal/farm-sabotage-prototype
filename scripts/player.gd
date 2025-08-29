extends CharacterBody3D

@export var speed := 5.0
@export var player_id := 1
@onready var hold_point: Area3D = $HoldPoint

var held_item: Node = null

func _physics_process(delta: float) -> void:
	handle_movement(delta)
	handle_interaction()

func handle_movement(delta: float) -> void:
	var input_vector := Vector3.ZERO

	if player_id == 1:
		input_vector.x = Input.get_action_strength("p1_right") - Input.get_action_strength("p1_left")
		input_vector.z = Input.get_action_strength("p1_down") - Input.get_action_strength("p1_up")
	elif player_id == 2:
		input_vector.x = Input.get_action_strength("p2_right") - Input.get_action_strength("p2_left")
		input_vector.z = Input.get_action_strength("p2_down") - Input.get_action_strength("p2_up")

	if input_vector.length() > 1:
		input_vector = input_vector.normalized()

	var velocity_vector = Vector3(input_vector.x, 0, input_vector.z) * speed
	velocity.x = velocity_vector.x
	velocity.z = velocity_vector.z

	move_and_slide()
	
	# Rotate towards movement direction
	if input_vector.length() > 0.1:
		var target_angle = atan2(-input_vector.z, input_vector.x)
		rotation.y = lerp_angle(rotation.y, target_angle, delta * 10.0)

func handle_interaction() -> void:
	var interact_pressed := false
	if player_id == 1 and Input.is_action_just_pressed("p1_interact"):
		interact_pressed = true
	elif player_id == 2 and Input.is_action_just_pressed("p2_interact"):
		interact_pressed = true

	if interact_pressed:
		if held_item:
			drop_item()
		else:
			pick_up_item()

func pick_up_item() -> void:
	var nearest_crop: RigidBody3D = null
	var min_dist := 1.5

	for crop in get_tree().get_nodes_in_group("crops"):
		if not crop.is_held:
			var dist = crop.global_position.distance_to(global_position)
			if dist <= min_dist:
				nearest_crop = crop
				min_dist = dist

	if nearest_crop:
		held_item = nearest_crop
		nearest_crop.pick_up(self)

# -----------------------------
func drop_item() -> void:
	if held_item:
		held_item.drop(get_tree().current_scene, hold_point.global_position)
		held_item = null
