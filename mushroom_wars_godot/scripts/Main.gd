extends Node2D

# ── Config ─────────────────────────────────────────────────────────────────────
const W := 1152.0
const H := 648.0
const NODE_R := 44.0
const SPEED  := 140.0
const AI_INTERVAL := 3.0

const TYPES := {
	"small":  {"max_units": 12, "rate": 0.6, "img": "army-camp-tent-001",   "sz": 52},
	"medium": {"max_units": 22, "rate": 0.9, "img": "stone-watchtower-001", "sz": 68},
	"large":  {"max_units": 35, "rate": 1.4, "img": "clan-castle-001",      "sz": 84},
}

const OWNER_COL := {
	"player":  Color(0.15, 0.42, 0.95),
	"enemy":   Color(0.92, 0.15, 0.15),
	"neutral": Color(0.40, 0.58, 0.30),
}

# ── State ──────────────────────────────────────────────────────────────────────
var _forts  : Array[Dictionary] = []
var _squads : Array[Dictionary] = []
var _sel    : int  = -1
var _phase  : String = "playing"
var _ai_t   : float  = 0.0
var _hover  : Vector2 = Vector2.ZERO

# Cached resources
var _textures : Dictionary = {}  # type -> Texture2D
var _sf       : SpriteFrames     # mushroom animations

# UI refs
var _lbl_player : Label
var _lbl_enemy  : Label
var _end_panel  : Panel
var _lbl_result : Label

# ── Init ───────────────────────────────────────────────────────────────────────
func _ready() -> void:
	_load_resources()
	_build_ui()
	_start_game()


func _load_resources() -> void:
	for key in TYPES:
		var path := "res://assets/buildings/%s.png" % TYPES[key]["img"]
		if ResourceLoader.exists(path):
			_textures[key] = load(path)

	_sf = SpriteFrames.new()

	var run_tex : Texture2D = load("res://assets/Monsters_Creatures_Fantasy/Mushroom/Run.png")
	_sf.add_animation("run")
	_sf.set_animation_loop("run", true)
	_sf.set_animation_speed("run", 12.0)
	for i in 8:
		var at := AtlasTexture.new()
		at.atlas = run_tex
		at.region = Rect2(i * 150, 0, 150, 150)
		_sf.add_frame("run", at)

	var idle_tex : Texture2D = load("res://assets/Monsters_Creatures_Fantasy/Mushroom/Idle.png")
	_sf.add_animation("idle")
	_sf.set_animation_loop("idle", true)
	_sf.set_animation_speed("idle", 8.0)
	for i in 4:
		var at := AtlasTexture.new()
		at.atlas = idle_tex
		at.region = Rect2(i * 150, 0, 150, 150)
		_sf.add_frame("idle", at)


func _start_game() -> void:
	# Clear old squads
	for sq in _squads:
		var n = sq.get("node")
		if n and is_instance_valid(n):
			n.queue_free()
	_squads.clear()
	_forts.clear()
	_sel   = -1
	_phase = "playing"
	_ai_t  = 0.0
	_end_panel.hide()

	# Fortress layout: [pos, owner, units, type]
	var defs := [
		[Vector2(120, 130), "player",  18.0, "large"],
		[Vector2(120, 440), "player",  10.0, "medium"],
		[Vector2(305, 255), "neutral",  5.0, "small"],
		[Vector2(305, 400), "neutral",  4.0, "small"],
		[Vector2(480, 108), "neutral",  8.0, "medium"],
		[Vector2(480, 295), "neutral",  3.0, "small"],
		[Vector2(480, 490), "neutral",  6.0, "small"],
		[Vector2(655, 210), "neutral",  9.0, "medium"],
		[Vector2(655, 405), "neutral",  5.0, "small"],
		[Vector2(830, 130), "enemy",   18.0, "large"],
		[Vector2(830, 440), "enemy",   10.0, "medium"],
	]
	for i in defs.size():
		var d = defs[i]
		_forts.append({"id": i, "pos": d[0], "owner": d[1], "units": d[2], "type": d[3]})

	queue_redraw()


# ── Game Loop ──────────────────────────────────────────────────────────────────
func _process(delta: float) -> void:
	if _phase != "playing":
		return
	_grow(delta)
	_move_squads(delta)
	_run_ai(delta)
	_check_win()
	_refresh_ui()
	queue_redraw()


func _grow(delta: float) -> void:
	for f in _forts:
		if f["owner"] != "neutral":
			var max_u : float = TYPES[f["type"]]["max_units"]
			var rate  : float = TYPES[f["type"]]["rate"]
			f["units"] = minf(f["units"] + rate * delta, max_u)


func _move_squads(delta: float) -> void:
	var dead : Array[int] = []
	for i in _squads.size():
		var sq = _squads[i]
		sq["traveled"] += SPEED * delta
		var ratio := minf(sq["traveled"] / sq["dist"], 1.0)
		var pos : Vector2 = sq["from"].lerp(sq["to"], ratio)
		var node = sq.get("node")
		if node and is_instance_valid(node):
			node.position = pos
		if ratio >= 1.0:
			_arrive(sq)
			if node and is_instance_valid(node):
				node.queue_free()
			dead.append(i)
	for i in range(dead.size() - 1, -1, -1):
		_squads.remove_at(dead[i])


func _arrive(sq: Dictionary) -> void:
	var t = _forts[sq["to_id"]]
	if t["owner"] == sq["owner"]:
		t["units"] = minf(t["units"] + sq["count"], TYPES[t["type"]]["max_units"])
	elif sq["count"] > t["units"]:
		t["owner"] = sq["owner"]
		t["units"] = float(sq["count"]) - t["units"]
	else:
		t["units"] -= float(sq["count"])


func _launch(from_id: int, to_id: int, owner: String) -> void:
	var src = _forts[from_id]
	var tgt = _forts[to_id]
	var send := int(src["units"] * 0.6)
	if send < 1:
		return
	src["units"] -= float(send)

	# Squad node: AnimatedSprite2D for mushroom visual
	var node := Node2D.new()
	var aspr := AnimatedSprite2D.new()
	aspr.sprite_frames = _sf
	aspr.scale = Vector2(0.22, 0.22)
	aspr.offset = Vector2(0, -8)
	aspr.flip_h = tgt["pos"].x < src["pos"].x
	aspr.play("run")
	node.add_child(aspr)
	node.position = src["pos"]
	node.z_index = 2
	add_child(node)

	var dist : float = src["pos"].distance_to(tgt["pos"])
	_squads.append({
		"node"    : node,
		"owner"   : owner,
		"count"   : send,
		"from"    : Vector2(src["pos"]),
		"to"      : Vector2(tgt["pos"]),
		"to_id"   : to_id,
		"dist"    : dist,
		"traveled": 0.0,
	})


# ── AI ─────────────────────────────────────────────────────────────────────────
func _run_ai(delta: float) -> void:
	_ai_t += delta
	if _ai_t < AI_INTERVAL:
		return
	_ai_t = 0.0

	var mine := _forts.filter(func(f): return f["owner"] == "enemy" and f["units"] > 5)
	if mine.is_empty():
		return
	mine.sort_custom(func(a, b): return a["units"] > b["units"])

	var tgts := _forts.filter(func(f): return f["owner"] != "enemy")
	if tgts.is_empty():
		return
	tgts.sort_custom(func(a, b): return a["units"] < b["units"])

	_launch(mine[0]["id"], tgts[0]["id"], "enemy")


# ── Win condition ──────────────────────────────────────────────────────────────
func _check_win() -> void:
	var has_p := false
	var has_e := false
	for f in _forts:
		if f["owner"] == "player": has_p = true
		if f["owner"] == "enemy":  has_e = true
	for sq in _squads:
		if sq["owner"] == "player": has_p = true
		if sq["owner"] == "enemy":  has_e = true
	if not has_p:
		_end_game("enemy")
	elif not has_e:
		_end_game("player")


func _end_game(winner: String) -> void:
	_phase = "end"
	if winner == "player":
		_lbl_result.text = "VICTOIRE ! 🍄\nLes champignons vous appartiennent !"
		_lbl_result.add_theme_color_override("font_color", Color(0.4, 1.0, 0.25))
	else:
		_lbl_result.text = "DÉFAITE 💀\nL'ennemi contrôle tout..."
		_lbl_result.add_theme_color_override("font_color", Color(1.0, 0.35, 0.35))
	_end_panel.show()


# ── Drawing ────────────────────────────────────────────────────────────────────
func _draw() -> void:
	var font   := ThemeDB.fallback_font
	var fs_cnt := 15
	var fs_sm  := 12

	# ── Background ──
	var g_top := Color(0.06, 0.14, 0.04)
	var g_bot := Color(0.09, 0.18, 0.06)
	draw_rect(Rect2(0, 0, W, H), g_top)
	# Gradient strips (cheap gradient effect)
	for row in 12:
		var y := row * (H / 12.0)
		var t := float(row) / 11.0
		var c := g_top.lerp(g_bot, t)
		c.a = 0.25
		draw_rect(Rect2(0, y, W, H / 12.0 + 1), c)

	# Subtle grid dots
	for gx in range(0, int(W), 60):
		for gy in range(0, int(H), 60):
			draw_circle(Vector2(gx, gy), 1.5, Color(1, 1, 1, 0.04))

	# ── Fortress rings + buildings ──
	for f in _forts:
		var c: Color   = OWNER_COL[f["owner"]]
		var pos: Vector2 = f["pos"]
		var sz: float  = float(TYPES[f["type"]]["sz"])

		# Glow fill
		draw_circle(pos, NODE_R + 3, Color(c.r, c.g, c.b, 0.14))

		# Ownership ring
		draw_arc(pos, NODE_R + 2, 0.0, TAU, 48, c, 4.5)

		# Selection highlight
		if f["id"] == _sel:
			draw_circle(pos, NODE_R + 12, Color(1, 1, 0, 0.15))
			draw_arc(pos, NODE_R + 9, 0.0, TAU, 48, Color.YELLOW, 3.0)

		# Building sprite
		var tex : Texture2D = _textures.get(f["type"])
		if tex:
			draw_texture_rect(tex,
				Rect2(pos - Vector2(sz * 0.5, sz * 0.56), Vector2(sz, sz)),
				false)
		else:
			draw_circle(pos, NODE_R - 8, c)

		# Unit count badge
		var badge_pos := pos + Vector2(0, NODE_R + 10)
		draw_circle(badge_pos, 14.0, Color(0, 0, 0, 0.72))
		var count_str := str(int(f["units"]))
		var tw := font.get_string_size(count_str, HORIZONTAL_ALIGNMENT_LEFT, -1, fs_cnt).x
		draw_string(font, badge_pos + Vector2(-tw * 0.5, fs_cnt * 0.38),
			count_str, HORIZONTAL_ALIGNMENT_LEFT, -1, fs_cnt,
			c.lightened(0.45))

	# Squad count badges (drawn on top since z_index on child nodes handles sprites)
	for sq in _squads:
		var n = sq.get("node")
		if n and is_instance_valid(n):
			var nd: Node2D = n
			var badge: Vector2 = nd.position + Vector2(12, -18)
			draw_circle(badge, 10.0, Color(0, 0, 0, 0.7))
			var ct := str(sq["count"])
			var tw := font.get_string_size(ct, HORIZONTAL_ALIGNMENT_LEFT, -1, fs_sm).x
			draw_string(font, badge + Vector2(-tw * 0.5, fs_sm * 0.38),
				ct, HORIZONTAL_ALIGNMENT_LEFT, -1, fs_sm,
				OWNER_COL[sq["owner"]].lightened(0.5))

	# Preview line (selected → cursor)
	if _sel >= 0 and _hover != Vector2.ZERO:
		draw_line(_forts[_sel]["pos"], _hover, Color(1, 1, 0.3, 0.5), 2.0, true)


# ── Input ──────────────────────────────────────────────────────────────────────
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_hover = event.position
		if _phase == "playing":
			queue_redraw()
		return

	if _phase == "end":
		if event is InputEventMouseButton and event.pressed:
			_start_game()
		return

	if not (event is InputEventMouseButton and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT):
		return

	var mp  := event.position
	var hit := -1
	for f in _forts:
		if f["pos"].distance_to(mp) <= NODE_R + 12:
			hit = f["id"]
			break

	if hit == -1:
		_sel = -1
	elif _sel != -1 and _sel != hit:
		var src = _forts[_sel]
		if src["owner"] == "player" and src["units"] >= 2.0:
			_launch(_sel, hit, "player")
		_sel = -1
	elif _forts[hit]["owner"] == "player":
		_sel = hit
	else:
		_sel = -1

	queue_redraw()


# ── UI ─────────────────────────────────────────────────────────────────────────
func _refresh_ui() -> void:
	var pc := _forts.filter(func(f): return f["owner"] == "player").size()
	var ec := _forts.filter(func(f): return f["owner"] == "enemy").size()
	_lbl_player.text = "🔵 Vous : %d forteresses" % pc
	_lbl_enemy.text  = "%d forteresses : Ennemi 🔴" % ec


func _build_ui() -> void:
	var ui := CanvasLayer.new()
	add_child(ui)

	# Top bar background
	var bar := ColorRect.new()
	bar.color = Color(0, 0, 0, 0.62)
	bar.size  = Vector2(W, 38)
	ui.add_child(bar)

	_lbl_player = _mk_label(ui, Vector2(10, 9), 15, Color(0.7, 0.88, 1.0))
	_lbl_enemy  = _mk_label(ui, Vector2(770, 9), 15, Color(1.0, 0.7, 0.7))

	var hint := _mk_label(ui, Vector2(0, 9), 13, Color(0.72, 0.92, 0.55))
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.size = Vector2(W, 22)
	hint.text = "Cliquez votre forteresse (bleue) → puis la cible"

	# End panel
	_end_panel = Panel.new()
	_end_panel.position = Vector2(W * 0.5 - 280, H * 0.5 - 110)
	_end_panel.size = Vector2(560, 220)
	_end_panel.hide()
	ui.add_child(_end_panel)

	_lbl_result = Label.new()
	_lbl_result.name = "Result"
	_lbl_result.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_result.position = Vector2(30, 25)
	_lbl_result.size = Vector2(500, 120)
	_lbl_result.autowrap_mode = TextServer.AUTOWRAP_WORD
	_lbl_result.add_theme_font_size_override("font_size", 28)
	_end_panel.add_child(_lbl_result)

	var btn := Button.new()
	btn.text = "🔄 Rejouer"
	btn.position = Vector2(195, 155)
	btn.size = Vector2(170, 44)
	btn.pressed.connect(_start_game)
	_end_panel.add_child(btn)


func _mk_label(parent: Node, pos: Vector2, size: int, color: Color) -> Label:
	var l := Label.new()
	l.position = pos
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	parent.add_child(l)
	return l
