extends RigidBody3D

var is_held := false
var holder: Node3D = null

func _ready() -> void:
	add_to_group("rocks")

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
