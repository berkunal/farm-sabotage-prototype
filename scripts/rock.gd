extends RigidBody3D

var is_held := false
var holder: Node3D = null
@export var min_stun_velocity = 5.0
@onready var sfx = $AudioStreamPlayer3D


func _ready() -> void:
	sfx.stream = load("res://audio/simple-whoosh-382724.mp3")
	add_to_group("rocks")
	
	contact_monitor = true
	max_contacts_reported = 1
	body_entered.connect(_on_body_entered)

func _physics_process(_delta: float) -> void:
	if is_held and holder:
		# Force-follow the holder’s HoldPoint
		var hold_point := holder.get_node("HoldPoint")
		if hold_point:
			global_transform = hold_point.global_transform

func pick_up(player: Node3D) -> void:
	is_held = true
	holder = player
	freeze = true
	collision_layer = 0
	collision_mask = 0

func drop(drop_position: Vector3) -> void:
	is_held = false
	holder = null
	freeze = false
	collision_layer = 1
	collision_mask = 1

	global_transform.origin = drop_position

func throw_item(force: Vector3):
	is_held = false
	freeze = false
	collision_layer = 1
	collision_mask = 1
	apply_impulse(force, Vector3.ZERO)
	sfx.play()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("players") and body.has_method("get_stunned"):
		var current_speed = linear_velocity.length()

		if current_speed < min_stun_velocity:
			return
		var impact_force = linear_velocity * mass
		body.get_stunned(impact_force);
		await sfx.finished
		queue_free()
