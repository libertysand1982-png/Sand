extends Control

# Clickable build bar: category tabs on top, a scrollable row of building
# "cards" (3D thumbnail + name/price) below. Thumbnails are rendered once at
# startup into an off-screen viewport. Population-locked items are disabled.

var builder
var _items: Array = [] # [{button,label,thumb,index}] for the current category
var _thumbs := {} # structure index -> Texture2D
var _viewport: SubViewport
var _holder: Node3D
var _camera: Camera3D

const THUMB_SIZE := 96

@export var tab_container: HBoxContainer
@export var item_container: HBoxContainer

func setup(b):
	builder = b
	_build_tabs()
	_generate_thumbnails() # coroutine, fills _thumbs and refreshes cards

# --- Tabs & cards --------------------------------------------------------

func _clear(container: Node):
	for c in container.get_children():
		container.remove_child(c)
		c.queue_free()

func _build_tabs():
	_clear(tab_container)
	var categories: Array = []
	for s in builder.structures:
		if not categories.has(s.category):
			categories.append(s.category)

	for cat in categories:
		var button := Button.new()
		button.text = cat
		button.add_theme_font_size_override("font_size", 18)
		button.pressed.connect(_on_tab.bind(cat))
		button.mouse_entered.connect(_play_hover)
		tab_container.add_child(button)

	if categories.size() > 0:
		_on_tab(categories[0])

func _on_tab(category: String):
	Audio.play("sounds/ui/click.ogg", -14)
	_show_category(category)

func _show_category(category: String):
	_clear(item_container)
	_items.clear()

	for i in range(builder.structures.size()):
		var s: Structure = builder.structures[i]
		if s.category != category:
			continue
		_items.append(_make_card(i, s))

	update_locks(builder.population)

func _make_card(i: int, s: Structure) -> Dictionary:
	var button := Button.new()
	button.custom_minimum_size = Vector2(104, 132)
	button.pressed.connect(_on_item.bind(i))
	button.mouse_entered.connect(_play_hover)
	item_container.add_child(button)

	# Content (ignores the mouse so clicks reach the button)
	var box := VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	box.add_theme_constant_override("separation", 2)
	button.add_child(box)

	var thumb := TextureRect.new()
	thumb.custom_minimum_size = Vector2(96, 84)
	thumb.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	thumb.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	thumb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	thumb.texture = _thumbs.get(i, null)
	box.add_child(thumb)

	var label := Label.new()
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", 13)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(label)

	return {"button": button, "label": label, "thumb": thumb, "index": i}

func _on_item(i: int):
	Audio.play("sounds/ui/click.ogg", -12)
	builder.select_index(i)

func _play_hover():
	Audio.play("sounds/ui/hover.ogg", -22)

# Enable/disable cards and update their labels based on current population

func update_locks(population: int):
	for entry in _items:
		var s: Structure = builder.structures[entry["index"]]
		var button: Button = entry["button"]
		var label: Label = entry["label"]
		if s.unlock_population > population:
			button.disabled = true
			label.text = "Locked\nPop " + str(s.unlock_population)
		else:
			button.disabled = false
			label.text = s.title + "\n$" + str(s.price)

# --- Thumbnail rendering -------------------------------------------------

func _generate_thumbnails():
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(THUMB_SIZE, THUMB_SIZE)
	_viewport.transparent_bg = true
	_viewport.own_world_3d = true
	_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(_viewport)

	_camera = Camera3D.new()
	_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	_viewport.add_child(_camera)

	var key := DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-50, -40, 0)
	_viewport.add_child(key)

	_holder = Node3D.new()
	_viewport.add_child(_holder)

	for i in range(builder.structures.size()):
		await _render_thumbnail(i)

	# Clean up the render rig
	_viewport.queue_free()

func _render_thumbnail(i: int):
	for c in _holder.get_children():
		c.queue_free()

	var inst = builder.structures[i].model.instantiate()
	_holder.add_child(inst)
	await get_tree().process_frame

	var aabb := _node_aabb(inst)
	var center := aabb.position + aabb.size * 0.5
	var extent: float = max(aabb.size.x, aabb.size.y, aabb.size.z)
	if extent <= 0.0:
		extent = 1.0

	var dir := Vector3(1, 0.85, 1).normalized()
	_camera.position = center + dir * extent * 3.0
	_camera.look_at(center, Vector3.UP)
	_camera.size = extent * 1.6

	_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	await RenderingServer.frame_post_draw

	var img := _viewport.get_texture().get_image()
	var tex := ImageTexture.create_from_image(img)
	_thumbs[i] = tex

	# Update a visible card showing this structure, if any
	for entry in _items:
		if entry["index"] == i:
			entry["thumb"].texture = tex

# Merge the AABBs of every MeshInstance3D under 'node' (in node-local space)

func _node_aabb(node: Node) -> AABB:
	var result := AABB()
	var found := false
	for child in _all_mesh_instances(node):
		var mi := child as MeshInstance3D
		var a: AABB = mi.get_aabb()
		a = mi.global_transform * a
		if not found:
			result = a
			found = true
		else:
			result = result.merge(a)
	if not found:
		return AABB(Vector3(-0.5, 0, -0.5), Vector3(1, 1, 1))
	return result

func _all_mesh_instances(node: Node) -> Array:
	var out: Array = []
	if node is MeshInstance3D:
		out.append(node)
	for child in node.get_children():
		out.append_array(_all_mesh_instances(child))
	return out
