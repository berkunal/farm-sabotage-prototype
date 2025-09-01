@tool
extends EditorScript

# Folder containing all the GLBs
const SOURCE_DIR = "res://models/"
# Where to save the MeshLibrary
const LIBRARY_PATH = "res://resources/tiles.tres"

func _run():
	print("Starting MeshLibrary generation...")
	print("1. This script will ADD new items if LIBRARY_PATH exists")
	print("2. To REPLACE all items, delete the file first: ", LIBRARY_PATH)
	
	# Load existing MeshLibrary or create new one
	var mesh_library: MeshLibrary
	if ResourceLoader.exists(LIBRARY_PATH):
		mesh_library = load(LIBRARY_PATH)
		print("Loaded existing MeshLibrary with ", mesh_library.get_last_unused_item_id(), " items")
	else:
		mesh_library = MeshLibrary.new()
		print("Creating new MeshLibrary")
	
	# Get all GLB files from the source directory
	var glb_files = get_glb_files(SOURCE_DIR)
	
	if glb_files.is_empty():
		print("No GLB files found in ", SOURCE_DIR)
		return
	
	print("Found ", glb_files.size(), " GLB files")
	
	# Process each GLB file
	var start_id = mesh_library.get_last_unused_item_id()
	
	for i in range(glb_files.size()):
		var file_path = glb_files[i]
		var file_name = file_path.get_file().get_basename()
		var item_id = start_id + i
		
		print("Processing: ", file_name, " (", i + 1, "/", glb_files.size(), ") -> ID: ", item_id)
		
		# Check if item already exists (by name)
		if item_already_exists(mesh_library, file_name):
			print("  ⚠ Item '", file_name, "' already exists, skipping...")
			continue
		
		# Load and process the GLB
		if process_glb_file(mesh_library, item_id, file_path, file_name):
			print("  ✓ Successfully added to library")
		else:
			print("  ✗ Failed to process")
	
	# Ensure the resources directory exists
	if not DirAccess.dir_exists_absolute("res://resources/"):
		DirAccess.open("res://").make_dir("resources")
	
	# Save the MeshLibrary
	var result = ResourceSaver.save(mesh_library, LIBRARY_PATH)
	if result == OK:
		print("✓ MeshLibrary saved successfully to: ", LIBRARY_PATH)
		print("Total items in library: ", mesh_library.get_last_unused_item_id())
	else:
		print("✗ Failed to save MeshLibrary")

func get_glb_files(directory: String) -> Array[String]:
	var files: Array[String] = []
	var dir = DirAccess.open(directory)
	
	if dir == null:
		print("Failed to open directory: ", directory)
		return files
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name.ends_with(".glb"):
			files.append(directory + file_name)
		file_name = dir.get_next()
	
	return files

func process_glb_file(mesh_library: MeshLibrary, item_id: int, file_path: String, name: String) -> bool:
	# Load the GLB scene
	var scene = load(file_path)
	if scene == null:
		print("    Failed to load: ", file_path)
		return false
	
	# Instantiate to get the mesh
	var instance = scene.instantiate()
	if instance == null:
		print("    Failed to instantiate: ", name)
		return false
	
	# Find the MeshInstance3D node (usually the first child or the root)
	var mesh_instance = find_mesh_instance(instance)
	if mesh_instance == null:
		print("    No MeshInstance3D found in: ", name)
		instance.queue_free()
		return false
	
	var mesh = mesh_instance.mesh
	if mesh == null:
		print("    No mesh found in MeshInstance3D: ", name)
		instance.queue_free()
		return false
	
	# Create the library item
	mesh_library.create_item(item_id)
	mesh_library.set_item_name(item_id, name)
	mesh_library.set_item_mesh(item_id, mesh)
	
	# Create collision shape
	var collision_shape = create_collision_shape(mesh, name)
	if collision_shape:
		mesh_library.set_item_shapes(item_id, [collision_shape])
		print("    Added collision shape: ", collision_shape.get_class())
	else:
		print("    Warning: No collision shape created for: ", name)
	
	# Generate a preview texture (optional)
	var preview_texture = generate_preview_texture(mesh_instance)
	if preview_texture:
		mesh_library.set_item_preview(item_id, preview_texture)
	
	# Clean up
	instance.queue_free()
	return true

func find_mesh_instance(node: Node) -> MeshInstance3D:
	# Check if current node is a MeshInstance3D
	if node is MeshInstance3D:
		return node
	
	# Search children recursively
	for child in node.get_children():
		var result = find_mesh_instance(child)
		if result != null:
			return result
	
	return null

func create_collision_shape(mesh: Mesh, name: String) -> Shape3D:
	# Determine the best collision shape based on the platform type
	var lower_name = name.to_lower()
	
	# For most Kenney platforms, use a simple box collision
	if should_use_box_collision(lower_name):
		return create_box_collision(mesh)
	# For ramps, curved pieces, use convex
	elif should_use_convex_collision(lower_name):
		return mesh.create_convex_shape()
	# For complex geometry, use trimesh (static only)
	else:
		return mesh.create_trimesh_shape()

func should_use_box_collision(name: String) -> bool:
	# Most Kenney platform pieces are simple boxes
	var box_keywords = ["tile", "block", "platform", "straight", "corner"]
	for keyword in box_keywords:
		if keyword in name:
			return true
	return false

func should_use_convex_collision(name: String) -> bool:
	# Pieces that need more accurate collision but still need to be dynamic-friendly
	var convex_keywords = ["ramp", "curve", "slope", "wedge", "round"]
	for keyword in convex_keywords:
		if keyword in name:
			return true
	return false

func create_box_collision(mesh: Mesh) -> BoxShape3D:
	# Get the mesh's bounding box
	var aabb = mesh.get_aabb()
	
	# Create box shape with the same size
	var box_shape = BoxShape3D.new()
	box_shape.size = aabb.size
	
	return box_shape

func generate_preview_texture(mesh_instance: MeshInstance3D) -> Texture2D:
	# For now, skip preview generation to avoid complexity
	# You can manually set previews later in the MeshLibrary editor
	return null

func item_already_exists(mesh_library: MeshLibrary, name: String) -> bool:
	# Check if an item with this name already exists
	for i in range(mesh_library.get_last_unused_item_id()):
		if mesh_library.get_item_name(i) == name:
			return true
	return false
