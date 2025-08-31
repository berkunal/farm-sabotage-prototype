extends CharacterBody3D

@export var speed := 5.0
@export var player_id := 1
@export var throw_force := 20.0
@export var launch_force_multiplier = 5.0
@export var spin_force = 10.0

@onready var hold_point: Area3D = $HoldPoint
@onready var camera = get_viewport().get_camera_3d()

var held_item: Node = null
var stunned: bool = false
var stun_timer: float = 0.0
var launch_velocity = Vector3.ZERO
var spin_velocity = Vector3.ZERO
var original_gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	add_to_group("players")

func _physics_process(delta: float) -> void:
	if stunned:
		handle_stun_physics(delta)
		return

	handle_movement(delta)
	handle_interaction()
	handle_throw()

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
	
	if not is_on_floor():
		velocity.y -= original_gravity * delta

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


func handle_throw() -> void:
	var throw_pressed := false
	if player_id == 1 and Input.is_action_just_pressed("p1_throw"):
		throw_pressed = true
	elif player_id == 2 and Input.is_action_just_pressed("p2_throw"):
		throw_pressed = true

	if throw_pressed and held_item and held_item.is_in_group("rocks"):
		throw_item()


func pick_up_item() -> void:
	var nearest_item: RigidBody3D = null
	var min_dist := 1.5

	for item in get_tree().get_nodes_in_group("crops") + get_tree().get_nodes_in_group("rocks"):
		if item.has_method("is_held") and item.is_held:
			continue
		var dist = item.global_position.distance_to(global_position)
		if dist <= min_dist:
			nearest_item = item
			min_dist = dist

	if nearest_item:
		held_item = nearest_item
		nearest_item.pick_up(self)


func drop_item() -> void:
	if held_item:
		held_item.drop(hold_point.global_position)
		held_item = null


func throw_item() -> void:
	if held_item and held_item.has_method("throw_item"):
		var forward = transform.basis.x.normalized()
		held_item.throw_item(forward * throw_force)
		held_item = null

func get_stunned(impact_force):
	if stunned:
		return

	if held_item:
		drop_item()  # drop crop if holding
	stunned = true
	stun_timer = 2.0 # stunned for 2 seconds

	var launch_direction = Vector3.UP * 0.7 + Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized() * 0.3
	launch_velocity = launch_direction * impact_force.length() * launch_force_multiplier
	
	# 3. Add random spin
	spin_velocity = Vector3(
		randf_range(-spin_force, spin_force),
		randf_range(-spin_force, spin_force),
		randf_range(-spin_force, spin_force)
	)
	
	screen_shake()

func recover_from_stun():
	stunned = false
	var tween = create_tween()
	tween.tween_property(self, "rotation", Vector3.ZERO, 0.5)
	
	# Reset velocities
	launch_velocity = Vector3.ZERO
	spin_velocity = Vector3.ZERO
	velocity = Vector3.ZERO

func handle_stun_physics(delta):
	stun_timer -= delta
	
	if stun_timer <= 0:
		# Stun ended - reset to normal
		recover_from_stun()
		return
	
	# Apply launch velocity with gravity
	velocity = launch_velocity
	launch_velocity.y -= original_gravity * delta  # Apply gravity to launch velocity
	
	# Apply spinning rotation
	rotation += spin_velocity * delta
	
	# Dampen the launch velocity over time (air resistance)
	launch_velocity *= 0.98
	spin_velocity *= 0.95  # Dampen spin too
	
	# Move the character
	move_and_slide()

func screen_shake():
	if not camera:
		return

	var original_pos = camera.position
	var tween = create_tween()

	# Quick shake effect
	for i in 10:
		var shake_offset = Vector3(
			randf_range(-0.1, 0.1),
			randf_range(-0.1, 0.1),
			randf_range(-0.1, 0.1)
		)
		tween.tween_property(camera, "position", original_pos + shake_offset, 0.03)

	tween.tween_property(camera, "position", original_pos, 0.1)
