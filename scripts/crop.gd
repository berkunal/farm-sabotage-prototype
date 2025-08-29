extends RigidBody3D

var is_held := false
var holder: Node3D = null
var last_owner = null

func _physics_process(delta: float) -> void:
	if is_held and holder:
		# Force-follow the holder’s HoldPoint
		var hold_point := holder.get_node("HoldPoint")
		if hold_point:
			global_transform = hold_point.global_transform

func pick_up(player: Node3D) -> void:
	is_held = true
	holder = player
	last_owner = player
	freeze = true
	collision_layer = 0
	collision_mask = 0

	## Move under player scene tree
	#if get_parent():
		#get_parent().remove_child(self)
	#player.add_child(self)

func drop(world_parent: Node3D, drop_position: Vector3) -> void:
	last_owner = holder
	is_held = false
	holder = null
	freeze = false
	collision_layer = 1
	collision_mask = 1

	#if get_parent():
		#get_parent().remove_child(self)
	#world_parent.add_child(self)

	global_transform.origin = drop_position
