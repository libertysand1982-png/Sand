extends Node3D

@export var structures: Array[Structure] = []

var map:DataMap

var index:int = 0 # Index of structure being built

@export var selector:Node3D # The 'cursor'
@export var selector_container:Node3D # Node that holds a preview of the structure
@export var view_camera:Camera3D # Used for raycasting mouse
@export var gridmap:GridMap
@export var cash_display:Label
@export var ground:MeshInstance3D # Terrain plane, tinted per biome
@export var structure_display:Label # Shows the name of the selected structure
@export var build_bar:Node # Clickable build bar UI
@export var population_display:Label # Shows the current population
@export var income_display:Label # Shows the net income per economy tick
@export var power_display:Label # Shows power coverage
@export var water_display:Label # Shows water coverage
@export var pause_menu:Node # In-game pause overlay
@export var warnings_container:Node3D # Holds the red markers over inactive buildings
@export var victory_banner:CanvasItem # Shown when the victory population is reached

# --- Balance knobs (tweak these freely) ---------------------------------
const POPULATION_PER_HOME := 10 # People housed by each active residential building
const VICTORY_POPULATION := 200 # Population needed to win
# ECONOMY_INTERVAL (below) sets seconds between income payouts.
# Per-structure prices, income, coverage radius and unlock thresholds live in
# the generated resources under structures_pack/.
# ------------------------------------------------------------------------

var population := 0 # Current population (cached for unlocks/victory)
var active_cells := {} # Vector3i -> bool, whether a building has its services
var victory_reached := false

var _power_sources := [] # [[Vector3i cell, int radius], ...] rebuilt each refresh
var _water_sources := []
var _fill_scale := {} # structure index -> Vector3 scale for tile_fill previews

var plane:Plane # Used for raycasting mouse

const ECONOMY_INTERVAL := 2.0 # Seconds between income payouts
var economy_timer := 0.0

# Folder of generated Structure resources and the order their tabs appear in
const STRUCTURES_DIR := "res://structures_pack"
const CATEGORY_ORDER := ["Residential", "Utility", "Roads", "Nature", "Walls", "Props", "Characters"]

func _ready():
	
	map = DataMap.new()
	plane = Plane(Vector3.UP, Vector3.ZERO)

	# Load the full catalogue of structures from the pack folder
	load_structures()

	# Create new MeshLibrary dynamically, can also be done in the editor
	# See: https://docs.godotengine.org/en/stable/tutorials/3d/using_gridmaps.html

	var mesh_library = MeshLibrary.new()

	var cell := gridmap.cell_size.x

	for i in range(structures.size()):

		var structure = structures[i]
		var id = mesh_library.get_last_unused_item_id()

		mesh_library.create_item(id)
		var mesh = get_mesh(structure.model)
		mesh_library.set_item_mesh(id, mesh)

		# Stretch flat road/ground tiles to fill the whole cell (seamless roads)
		if structure.tile_fill and mesh:
			var t = _fill_transform(mesh, cell)
			mesh_library.set_item_mesh_transform(id, t)
			_fill_scale[i] = Vector3(t.basis.x.x, 1.0, t.basis.z.z)
		else:
			mesh_library.set_item_mesh_transform(id, Transform3D())

	gridmap.mesh_library = mesh_library

	apply_terrain()
	update_structure()
	update_cash()

	# Populate the clickable build bar with the loaded catalogue
	if build_bar and build_bar.has_method("setup"):
		build_bar.setup(self)

	refresh_city()

	# Give the pause menu a reference back to us
	if pause_menu and pause_menu.has_method("setup"):
		pause_menu.setup(self)

	# Load the saved city when 'Continue' was selected in the main menu
	if Global.load_save_on_start:
		Global.load_save_on_start = false
		load_map()

# Load every Structure resource from STRUCTURES_DIR, sorted by category then name

func load_structures():
	var loaded:Array[Structure] = []
	var dir = DirAccess.open(STRUCTURES_DIR)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				# Exported builds may append '.remap' to resource files
				var res_name = file_name.trim_suffix(".remap")
				if res_name.ends_with(".tres"):
					var res = load(STRUCTURES_DIR + "/" + res_name)
					if res is Structure:
						loaded.append(res)
			file_name = dir.get_next()
		dir.list_dir_end()

	loaded.sort_custom(func(a, b):
		var ca = CATEGORY_ORDER.find(a.category)
		var cb = CATEGORY_ORDER.find(b.category)
		if ca != cb:
			return ca < cb
		return a.title < b.title)

	if loaded.size() > 0:
		structures = loaded

# Select a structure by index (called by the build bar)

func select_index(i:int):
	if i >= 0 and i < structures.size():
		# Locked structures (population-gated) can't be selected yet
		if structures[i].unlock_population > population:
			return
		index = i
		update_structure()

# True when the mouse is hovering a UI element, so we don't build through it

func _pointer_over_ui() -> bool:
	return get_viewport().gui_get_hovered_control() != null

# Tint the ground (and ambient mood) according to the selected biome

func apply_terrain():
	var data:Dictionary = Global.terrain()
	if ground:
		var material := StandardMaterial3D.new()
		material.albedo_color = data["ground"]
		material.roughness = 1.0
		ground.material_override = material
	RenderingServer.set_default_clear_color(data["sky"])

func _process(delta):

	# Controls

	action_rotate() # Rotates selection 90 degrees
	action_structure_toggle() # Toggles between structures

	action_save() # Saving
	action_load() # Loading
	action_load_resources() # Loading from resources
	
	# Map position based on mouse
	
	var world_position = plane.intersects_ray(
		view_camera.project_ray_origin(get_viewport().get_mouse_position()),
		view_camera.project_ray_normal(get_viewport().get_mouse_position()))

	var gridmap_position = Vector3(round(world_position.x), 0, round(world_position.z))
	selector.position = lerp(selector.position, gridmap_position, min(delta * 40, 1.0))
	
	action_build(gridmap_position)
	action_demolish(gridmap_position)

	# Economy: pay out accumulated income/upkeep at a fixed interval
	economy_timer += delta
	if economy_timer >= ECONOMY_INTERVAL:
		economy_timer -= ECONOMY_INTERVAL
		collect_income()

# Recompute service coverage, refresh markers, HUD and build-bar unlocks

func refresh_city():
	recompute_services()
	update_markers()
	update_stats()

# Pay out the net income of active structures, then refresh the city state

func collect_income():
	recompute_services()
	var net := 0
	for cell in gridmap.get_used_cells():
		var id := gridmap.get_cell_item(cell)
		if id >= 0 and id < structures.size() and active_cells.get(cell, false):
			net += structures[id].income
	if net != 0:
		map.cash += net
		update_cash()
	update_markers()
	update_stats()

# Decide, for every cell, whether it has the services it needs to be active.
# Buildings that don't need services are always active.

func recompute_services():
	_power_sources.clear()
	_water_sources.clear()
	for cell in gridmap.get_used_cells():
		var id := gridmap.get_cell_item(cell)
		if id < 0 or id >= structures.size():
			continue
		var s:Structure = structures[id]
		if s.provides_power:
			_power_sources.append([cell, s.service_radius])
		if s.provides_water:
			_water_sources.append([cell, s.service_radius])

	active_cells.clear()
	for cell in gridmap.get_used_cells():
		var id := gridmap.get_cell_item(cell)
		if id < 0 or id >= structures.size():
			continue
		var s:Structure = structures[id]
		if not s.needs_services:
			active_cells[cell] = true
		else:
			active_cells[cell] = _covered(cell, _power_sources) and _covered(cell, _water_sources)

# True if 'cell' is within range of any provider in 'sources'

func _covered(cell:Vector3i, sources:Array) -> bool:
	for entry in sources:
		var src:Vector3i = entry[0]
		var radius:int = entry[1]
		var dx := cell.x - src.x
		var dz := cell.z - src.z
		if dx * dx + dz * dz <= radius * radius:
			return true
	return false

# Drop a red marker over each building that needs services but lacks them

func update_markers():
	if not warnings_container:
		return
	for child in warnings_container.get_children():
		child.queue_free()
	for cell in gridmap.get_used_cells():
		var id := gridmap.get_cell_item(cell)
		if id < 0 or id >= structures.size():
			continue
		if structures[id].needs_services and not active_cells.get(cell, false):
			var missing_power := not _covered(cell, _power_sources)
			var missing_water := not _covered(cell, _water_sources)
			warnings_container.add_child(_make_marker(cell, missing_power, missing_water))

# A floating red billboard naming the missing service(s) over a building

func _make_marker(cell:Vector3i, missing_power:bool, missing_water:bool) -> Label3D:
	var parts := []
	if missing_power:
		parts.append("No Power")
	if missing_water:
		parts.append("No Water")

	var label := Label3D.new()
	label.text = "\n".join(parts)
	label.font_size = 96
	label.pixel_size = 0.005
	label.modulate = Color(1, 0.25, 0.2)
	label.outline_modulate = Color(0, 0, 0, 0.7)
	label.outline_size = 24
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.position = Vector3(cell.x, 1.4, cell.z)
	return label

# Refresh population/income/coverage labels, build-bar unlocks and victory

func update_stats():
	var pop := 0
	var net := 0
	var need_total := 0
	var powered := 0
	var watered := 0
	for cell in gridmap.get_used_cells():
		var id := gridmap.get_cell_item(cell)
		if id < 0 or id >= structures.size():
			continue
		var s:Structure = structures[id]
		if active_cells.get(cell, false):
			net += s.income
			if s.category == "Residential":
				pop += POPULATION_PER_HOME
		if s.needs_services:
			need_total += 1
			if _covered(cell, _power_sources):
				powered += 1
			if _covered(cell, _water_sources):
				watered += 1

	population = pop

	if population_display:
		population_display.text = "Pop: " + str(pop)
	if income_display:
		var sign_str := "+" if net >= 0 else ""
		income_display.text = "Income: " + sign_str + str(net) + "/t"
	if power_display:
		power_display.text = "Power: " + str(_percent(powered, need_total)) + "%"
	if water_display:
		water_display.text = "Water: " + str(_percent(watered, need_total)) + "%"

	# Let the build bar enable any newly-unlocked structures
	if build_bar and build_bar.has_method("update_locks"):
		build_bar.update_locks(pop)

	# Victory
	if not victory_reached and pop >= VICTORY_POPULATION:
		victory_reached = true
		if victory_banner:
			victory_banner.visible = true

func _percent(part:int, total:int) -> int:
	if total <= 0:
		return 100
	return int(round(100.0 * part / total))

# Retrieve the mesh from a PackedScene, used for dynamically creating a MeshLibrary

func get_mesh(packed_scene):
	var scene_state:SceneState = packed_scene.get_state()
	for i in range(scene_state.get_node_count()):
		if(scene_state.get_node_type(i) == "MeshInstance3D"):
			for j in scene_state.get_node_property_count(i):
				var prop_name = scene_state.get_node_property_name(i, j)
				if prop_name == "mesh":
					var prop_value = scene_state.get_node_property_value(i, j)
					
					return prop_value.duplicate()

# Transform that stretches a mesh's XZ footprint to fill one grid cell

func _fill_transform(mesh, cell:float) -> Transform3D:
	var aabb:AABB = mesh.get_aabb()
	var sx := (cell / aabb.size.x) if aabb.size.x > 0.0 else 1.0
	var sz := (cell / aabb.size.z) if aabb.size.z > 0.0 else 1.0
	var basis := Basis(Vector3(sx, 0, 0), Vector3(0, 1, 0), Vector3(0, 0, sz))
	var center := aabb.position + aabb.size * 0.5
	var origin := Vector3(-center.x * sx, 0.0, -center.z * sz)
	return Transform3D(basis, origin)

# Build (place) a structure

func action_build(gridmap_position):
	# Held (not just pressed) so you can drag to lay a continuous line of roads
	if Input.is_action_pressed("build"):

		if _pointer_over_ui():
			return

		var previous_tile = gridmap.get_cell_item(gridmap_position)

		# Don't allow placing a new structure we can't afford
		if previous_tile != index and map.cash < structures[index].price:
			return

		gridmap.set_cell_item(gridmap_position, index, gridmap.get_orthogonal_index_from_basis(selector.basis))

		if previous_tile != index:
			map.cash -= structures[index].price
			update_cash()
			refresh_city()

			Audio.play("sounds/placement-a.ogg, sounds/placement-b.ogg, sounds/placement-c.ogg, sounds/placement-d.ogg", -20)

# Demolish (remove) a structure

func action_demolish(gridmap_position):
	# Held so you can drag to clear a stretch in one motion
	if Input.is_action_pressed("demolish"):
		if _pointer_over_ui():
			return
		if gridmap.get_cell_item(gridmap_position) != -1:
			gridmap.set_cell_item(gridmap_position, -1)
			refresh_city()

			Audio.play("sounds/removal-a.ogg, sounds/removal-b.ogg, sounds/removal-c.ogg, sounds/removal-d.ogg", -20)

# Rotates the 'cursor' 90 degrees

func action_rotate():
	if Input.is_action_just_pressed("rotate"):
		selector.rotate_y(deg_to_rad(90))
		
		Audio.play("sounds/rotate.ogg", -30)

# Toggle between structures to build

func action_structure_toggle():
	if Input.is_action_just_pressed("structure_next"):
		index = wrap(index + 1, 0, structures.size())
		Audio.play("sounds/toggle.ogg", -30)
	
	if Input.is_action_just_pressed("structure_previous"):
		index = wrap(index - 1, 0, structures.size())
		Audio.play("sounds/toggle.ogg", -30)

	update_structure()

# Update the structure visual in the 'cursor'

func update_structure():
	# Clear previous structure preview in selector
	for n in selector_container.get_children():
		selector_container.remove_child(n)
		n.queue_free()
		
	# Create new structure preview in selector
	var _model = structures[index].model.instantiate()
	selector_container.add_child(_model)
	_model.position.y += 0.25

	# Match the stretched footprint used for road/ground tiles
	if _fill_scale.has(index):
		_model.scale = _fill_scale[index]

	# Update the on-screen label with the structure's name and price
	if structure_display:
		var s := structures[index]
		var label := s.title if s.title != "" else s.category
		structure_display.text = "%s  ($%d)" % [label, s.price]

func update_cash():
	cash_display.text = "$" + str(map.cash)

# Saving/load

func action_save():
	if Input.is_action_just_pressed("save"):
		save_map()

# Writes the current city to disk (called by F1 and the pause menu)

func save_map():
	print("Saving map...")

	map.terrain = Global.terrain_id
	map.structures.clear()
	for cell in gridmap.get_used_cells():

		var data_structure:DataStructure = DataStructure.new()

		data_structure.position = Vector2i(cell.x, cell.z)
		data_structure.orientation = gridmap.get_cell_item_orientation(cell)
		data_structure.structure = gridmap.get_cell_item(cell)

		map.structures.append(data_structure)

	ResourceSaver.save(map, "user://map.res")
	
func action_load():
	if Input.is_action_just_pressed("load"):
		load_map()

# Loads the saved city from disk into the gridmap

func load_map():
	print("Loading map...")

	gridmap.clear()

	map = ResourceLoader.load("user://map.res")
	if not map:
		map = DataMap.new()

	# Restore the biome the city was built on
	Global.terrain_id = map.terrain
	apply_terrain()

	for cell in map.structures:
		gridmap.set_cell_item(Vector3i(cell.position.x, 0, cell.position.y), cell.structure, cell.orientation)

	update_cash()
	refresh_city()

func action_load_resources():
	if Input.is_action_just_pressed("load_resources"):
		print("Loading map...")
		
		gridmap.clear()
		
		map = ResourceLoader.load("res://sample map/map.res")
		if not map:
			map = DataMap.new()
		for cell in map.structures:
			gridmap.set_cell_item(Vector3i(cell.position.x, 0, cell.position.y), cell.structure, cell.orientation)

		update_cash()
		refresh_city()
