# MainMenu.gd — menu atmosphérique style Darkest Dungeon.
# Pluie, silhouettes, vignette, torches clignotantes, titre gothique.
extends Node2D

const W := 1280.0
const H := 720.0

# Palette Darkest Dungeon
const C_BG     := Color(0.030, 0.018, 0.014)
const C_MOUNT  := Color(0.048, 0.026, 0.020)
const C_CASTLE := Color(0.038, 0.020, 0.016)
const C_RED    := Color(0.50,  0.06,  0.04)
const C_GOLD   := Color(0.78,  0.63,  0.28)
const C_GOLD_H := Color(0.98,  0.86,  0.50)  # hover
const C_TAN    := Color(0.62,  0.50,  0.34)
const C_SHADOW := Color(0.40,  0.04,  0.04, 0.9)
const C_RAIN   := Color(0.22,  0.30,  0.42, 0.28)
const C_FOG    := Color(0.14,  0.09,  0.07, 0.07)

var _rain: Array     = []
var _fog: Array      = []
var _crows: Array    = []
var _crow_t          := randf_range(4.0, 10.0)
var _torches: Array  = []
var _menu_items: Array = []
var _time            := 0.0
var _last_hover_key  := ""

# Node refs
var _rain_root:    Node2D
var _fog_root:     Node2D
var _fx_root:      Node2D
var _title_shadow: Label
var _title:        Label
var _subtitle:     Label

func _ready() -> void:
	_build_bg()
	_build_silhouettes()
	_build_fx_layers()
	_build_vignette()
	_build_torches()
	_build_title()
	_build_menu()
	_spawn_rain()
	_spawn_fog()
	AudioManager.play_music("menu")

# ── Background & silhouettes ───────────────────────────────────────────────────

func _build_bg() -> void:
	_add_rect(Vector2(W, H), Vector2.ZERO, C_BG, -10)

	# Subtle red horizon glow
	var glow := ColorRect.new()
	glow.size = Vector2(W, 180)
	glow.position = Vector2(0, H - 180)
	glow.color = Color(0.12, 0.02, 0.01, 0.0)
	glow.z_index = -9
	var grad_tween := create_tween().set_loops()
	grad_tween.tween_property(glow, "color:a", 0.18, 3.0).set_ease(Tween.EASE_IN_OUT)
	grad_tween.tween_property(glow, "color:a", 0.06, 3.0).set_ease(Tween.EASE_IN_OUT)
	add_child(glow)

func _build_silhouettes() -> void:
	# Far mountains
	var mountain_data := [
		[0.0, 180], [220.0, 240], [380.0, 160], [550.0, 210],
		[720.0, 195], [900.0, 250], [1080.0, 175], [1200.0, 200]
	]
	for d in mountain_data:
		var mw := randf_range(180, 320)
		var mh: float = d[1]
		# Triangle-ish via stacked rects
		for row in 8:
			var w := mw * (1.0 - row * 0.1)
			var rr := ColorRect.new()
			rr.size = Vector2(w, mh / 8.0)
			rr.position = Vector2(d[0] + (mw - w) / 2.0, H - mh + (mh / 8.0) * row)
			rr.color = C_MOUNT
			rr.z_index = -8
			add_child(rr)

	# Castle towers (left side)
	_build_tower(130, 310)
	_build_tower(220, 260)
	_build_tower(70,  190)

	# Castle towers (right side)
	_build_tower(1100, 290)
	_build_tower(1180, 350)
	_build_tower(1230, 210)

	# Ground strip
	_add_rect(Vector2(W, 60), Vector2(0, H - 60), C_CASTLE, -7)

func _build_tower(x: float, h: float) -> void:
	var w := randf_range(55, 90)
	# Main body
	_add_rect(Vector2(w, h), Vector2(x - w / 2.0, H - h), C_CASTLE, -7)
	# Battlements
	var bat_w := w / 5.0
	for i in 5:
		if i % 2 == 0:
			_add_rect(Vector2(bat_w, 20), Vector2(x - w / 2.0 + bat_w * i, H - h - 20), C_CASTLE, -7)
	# Window (dim orange glow)
	var win := ColorRect.new()
	win.size = Vector2(8, 12)
	win.position = Vector2(x - 4, H - h + h * 0.35)
	win.color = Color(0.5, 0.3, 0.05, 0.6)
	win.z_index = -6
	_torches.append({"rect": win, "base": 0.6, "amp": 0.35, "freq": randf_range(1.2, 2.8), "phase": randf() * TAU})
	add_child(win)

# ── FX layers ──────────────────────────────────────────────────────────────────

func _build_fx_layers() -> void:
	_rain_root = Node2D.new()
	_rain_root.z_index = 5
	add_child(_rain_root)

	_fog_root = Node2D.new()
	_fog_root.z_index = 4
	add_child(_fog_root)

	_fx_root = Node2D.new()
	_fx_root.z_index = 20
	add_child(_fx_root)

func _spawn_rain() -> void:
	for i in 130:
		var r := ColorRect.new()
		r.size = Vector2(1, randf_range(9, 22))
		r.color = C_RAIN
		r.position = Vector2(randf() * (W + 100), randf() * H)
		_rain_root.add_child(r)
		_rain.append({"rect": r, "speed": randf_range(280, 520), "dx": randf_range(-0.3, -0.1)})

func _spawn_fog() -> void:
	for i in 8:
		var f := ColorRect.new()
		var fw := randf_range(300, 600)
		var fh := randf_range(30, 80)
		f.size = Vector2(fw, fh)
		f.position = Vector2(randf() * W, H - randf_range(60, 200))
		f.color = C_FOG
		_fog_root.add_child(f)
		_fog.append({"rect": f, "speed": randf_range(8, 25)})

# ── Vignette ───────────────────────────────────────────────────────────────────

func _build_vignette() -> void:
	# Corner darkening (4 gradients)
	var corners := [Vector2.ZERO, Vector2(W - 200, 0), Vector2(0, H - 200), Vector2(W - 200, H - 200)]
	for c in corners:
		var v := ColorRect.new()
		v.size = Vector2(400, 400)
		v.position = c
		v.color = Color(0, 0, 0, 0.55)
		v.z_index = 8
		add_child(v)

	# Bottom dark band
	var bot := ColorRect.new()
	bot.size = Vector2(W, 120)
	bot.position = Vector2(0, H - 120)
	bot.color = Color(0, 0, 0, 0.6)
	bot.z_index = 8
	add_child(bot)

# ── Torches ────────────────────────────────────────────────────────────────────

func _build_torches() -> void:
	_add_wall_torch(80, 320)
	_add_wall_torch(1200, 320)

func _add_wall_torch(x: float, y: float) -> void:
	# Bracket
	_add_rect(Vector2(4, 30), Vector2(x - 2, y), Color(0.28, 0.22, 0.16), 9)
	# Flame (animated)
	var flame := ColorRect.new()
	flame.size = Vector2(14, 18)
	flame.position = Vector2(x - 7, y - 18)
	flame.color = Color(0.95, 0.55, 0.1)
	flame.z_index = 9
	_torches.append({"rect": flame, "base": 0.85, "amp": 0.45, "freq": randf_range(3.0, 5.5), "phase": randf() * TAU})
	add_child(flame)
	# Glow halo
	var halo := ColorRect.new()
	halo.size = Vector2(60, 80)
	halo.position = Vector2(x - 30, y - 50)
	halo.color = Color(0.6, 0.35, 0.05, 0.0)
	halo.z_index = 8
	_torches.append({"rect": halo, "base": 0.12, "amp": 0.08, "freq": randf_range(2.5, 4.5), "phase": randf() * TAU})
	add_child(halo)

# ── Title & Menu ───────────────────────────────────────────────────────────────

func _build_title() -> void:
	# Top decorative bar
	_add_rect(Vector2(520, 2), Vector2(380, 168), C_RED, 15)

	# Shadow title (offset pour effet profondeur)
	_title_shadow = _make_label("T H E  L A S T  H O U R", 50, C_SHADOW)
	_title_shadow.position = Vector2(640 - 310 + 3, 175)
	_title_shadow.size = Vector2(620, 70)
	_title_shadow.z_index = 14
	add_child(_title_shadow)

	# Main title
	_title = _make_label("T H E  L A S T  H O U R", 50, C_GOLD)
	_title.position = Vector2(640 - 310, 172)
	_title.size = Vector2(620, 70)
	_title.z_index = 15
	add_child(_title)

	# Decorative separator with skull motif
	_add_rect(Vector2(180, 2), Vector2(380, 248), C_RED, 15)
	var sep_lbl := _make_label("— ✦ —", 20, C_RED)
	sep_lbl.position = Vector2(560, 246)
	sep_lbl.z_index = 15
	add_child(sep_lbl)
	_add_rect(Vector2(180, 2), Vector2(700, 248), C_RED, 15)

	# Subtitle
	_subtitle = _make_label("Dans l'obscurité, une heure. Pas une de plus.", 17, C_TAN)
	_subtitle.position = Vector2(380, 262)
	_subtitle.size = Vector2(520, 28)
	_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_subtitle.z_index = 15
	add_child(_subtitle)

	# Bottom separator
	_add_rect(Vector2(520, 2), Vector2(380, 300), C_RED, 15)

func _build_menu() -> void:
	var items := [
		{"text": "—  NOUVELLE PARTIE  —", "key": "new"},
		{"text": "—  QUITTER  —",          "key": "quit"},
	]
	var start_y := 370.0
	for i in items.size():
		var item: Dictionary = items[i]
		var bg := ColorRect.new()
		bg.size = Vector2(340, 42)
		bg.position = Vector2(470, start_y + i * 62)
		bg.color = Color(0, 0, 0, 0)
		bg.z_index = 15
		add_child(bg)

		var left_bar := ColorRect.new()
		left_bar.size = Vector2(3, 42)
		left_bar.position = Vector2(470, start_y + i * 62)
		left_bar.color = C_RED
		left_bar.z_index = 16
		add_child(left_bar)

		var lbl := _make_label(item.text, 22, C_GOLD)
		lbl.position = Vector2(482, start_y + i * 62 + 8)
		lbl.size = Vector2(320, 36)
		lbl.z_index = 16
		add_child(lbl)

		_menu_items.append({"bg": bg, "lbl": lbl, "left": left_bar, "key": item.key})

	# Decorative quote at bottom
	var quote := _make_label('"Rappelle-toi... tu n\'as qu\'une heure."', 13, Color(0.38, 0.28, 0.18))
	quote.position = Vector2(440, 560)
	quote.size = Vector2(400, 22)
	quote.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	quote.z_index = 15
	add_child(quote)

# ── Process ────────────────────────────────────────────────────────────────────

func _process(delta: float) -> void:
	_time += delta
	_update_rain(delta)
	_update_fog(delta)
	_update_torches()
	_update_title()
	_update_menu_hover()
	_update_crows(delta)

func _update_rain(delta: float) -> void:
	for r in _rain:
		r.rect.position.y += r.speed * delta
		r.rect.position.x += r.dx * r.speed * delta
		if r.rect.position.y > H + 30:
			r.rect.position.y = -25
			r.rect.position.x = randf() * W

func _update_fog(delta: float) -> void:
	for f in _fog:
		f.rect.position.x -= f.speed * delta
		if f.rect.position.x + f.rect.size.x < 0:
			f.rect.position.x = W + 50
			f.rect.position.y = H - randf_range(60, 200)

func _update_torches() -> void:
	for t in _torches:
		var flicker: float = t.base + sin(_time * t.freq + t.phase) * t.amp * 0.5 + sin(_time * t.freq * 2.3 + t.phase) * t.amp * 0.5
		t.rect.modulate.a = clampf(flicker, 0.0, 1.0)
		# Random pop
		if randf() < 0.004:
			t.rect.modulate.a = 0.1

func _update_title() -> void:
	# Subtle breathing effect
	var pulse := 1.0 + sin(_time * 0.9) * 0.008
	_title.scale = Vector2(pulse, pulse)
	_title_shadow.scale = Vector2(pulse, pulse)

func _update_menu_hover() -> void:
	var mouse := get_local_mouse_position()
	var hovered_key := ""
	for item in _menu_items:
		var rect := Rect2(item.bg.position, item.bg.size)
		if rect.has_point(mouse):
			hovered_key = item.key
			item.lbl.add_theme_color_override("font_color", C_GOLD_H)
			item.bg.color = Color(0.28, 0.04, 0.03, 0.55)
			item.left.color = C_GOLD_H
		else:
			item.lbl.add_theme_color_override("font_color", C_GOLD)
			item.bg.color = Color(0, 0, 0, 0)
			item.left.color = C_RED
	if hovered_key != _last_hover_key:
		_last_hover_key = hovered_key
		if hovered_key != "":
			AudioManager.play_sfx("menu_hover")

func _update_crows(delta: float) -> void:
	_crow_t -= delta
	if _crow_t <= 0.0:
		_spawn_crow()
		_crow_t = randf_range(5.0, 14.0)
	for i in range(_crows.size() - 1, -1, -1):
		var c = _crows[i]
		c.x += c.speed * delta
		c.node.position.x = c.x
		c.node.position.y = c.y + sin(_time * 2.0 + c.phase) * 12.0
		if c.x > W + 60:
			c.node.queue_free()
			_crows.remove_at(i)

func _spawn_crow() -> void:
	# Crow as "^" character or wing shapes
	var lbl := Label.new()
	lbl.text = "^  ^"
	lbl.add_theme_font_size_override("font_size", 14)
	lbl.add_theme_color_override("font_color", Color(0.12, 0.08, 0.07))
	lbl.z_index = 6
	var start_y := randf_range(60, 260)
	lbl.position = Vector2(-50, start_y)
	add_child(lbl)
	_crows.append({"node": lbl, "x": -50.0, "y": start_y, "speed": randf_range(80, 160), "phase": randf() * TAU})

# ── Input ──────────────────────────────────────────────────────────────────────

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse := get_local_mouse_position()
		for item in _menu_items:
			var rect := Rect2(item.bg.position, item.bg.size)
			if rect.has_point(mouse):
				_on_item_pressed(item.key)

func _on_item_pressed(key: String) -> void:
	AudioManager.play_sfx("menu_click")
	match key:
		"new":
			GameManager.auto_start = true
			GlobalTimer.reset_all()
			RunData.reset_persistent()
			GameManager.run_count = 0
			get_tree().change_scene_to_file("res://scenes/StoryScroll.tscn")
		"quit":
			get_tree().quit()

# ── Helpers ────────────────────────────────────────────────────────────────────

func _add_rect(sz: Vector2, pos: Vector2, color: Color, z: int) -> ColorRect:
	var r := ColorRect.new()
	r.size = sz
	r.position = pos
	r.color = color
	r.z_index = z
	add_child(r)
	return r

func _make_label(text: String, size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	return l
