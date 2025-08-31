extends Node3D

@export var rock_scene: PackedScene
@export var spawn_interval = 5.0
@export var spawn_area_width = 20.0
@export var spawn_height = 30.0

func _on_rock_timer_timeout() -> void:
	var rock = rock_scene.instantiate()
	var x = randf_range(-spawn_area_width/2, spawn_area_width/2)
	var z = randf_range(-spawn_area_width/2, spawn_area_width/2)
	rock.position = Vector3(x, spawn_height, z)
	add_child(rock)
