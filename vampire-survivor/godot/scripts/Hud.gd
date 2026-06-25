# Hud.gd — interface : HUD de jeu (barres + roue de sorts) + menus
# (accueil, options, scores, niveau, fin avec saisie du nom, pause).
class_name VSHud
extends CanvasLayer

signal play_pressed
signal retry_pressed
signal to_menu_pressed
signal upgrade_chosen(id: String)
signal music_changed(v: float)
signal sfx_changed(v: float)
signal name_submitted(player_name: String)

const GOLD := Color(1.0, 0.847, 0.420)
const CREAM := Color(0.957, 0.925, 0.776)
const LILAC := Color(0.72, 0.66, 0.81)

var bars: Control
var menu_bg: Control
var wheel: VSWheel
var xp_fill: ColorRect
var xp_label: Label
var hp_fill: ColorRect
var hp_label: Label
var timer_label: Label
var kills_label: Label
var mute_label: Label
var hp_full_w := 240.0
var xp_full_w := 720.0

var overlay_menu: Control
var overlay_options: Control
var overlay_scores: Control
var overlay_levelup: Control
var overlay_gameover: Control
var overlay_pause: Control
var cards_box: HBoxContainer
var go_box: VBoxContainer
var music_pct: Label
var sfx_pct: Label

# ============================================================
func build() -> void:
	_build_menu_bg()
	_build_bars()
	_build_menu()
	_build_options()
	_build_scores()
	_build_levelup()
	_build_gameover()
	_build_pause()
	bars.visible = false
	wheel.visible = false

func _build_menu_bg() -> void:
	menu_bg = _full_control()
	menu_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tex := TextureRect.new()
	tex.texture = load("res://assets/bg/forest.png")
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	tex.anchor_right = 1.0
	tex.anchor_bottom = 1.0
	tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu_bg.add_child(tex)
	var tint := ColorRect.new()
	tint.color = Color(0.06, 0.05, 0.13, 0.58)
	tint.anchor_right = 1.0
	tint.anchor_bottom = 1.0
	tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu_bg.add_child(tint)
	add_child(menu_bg)
	menu_bg.visible = false

func _build_bars() -> void:
	bars = _full_control()
	bars.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bars)

	# XP (haut centré)
	var xp_bg := ColorRect.new()
	xp_bg.color = Color(0, 0, 0, 0.55)
	_anchor(xp_bg, 0.5, 0.0, 0.5, 0.0, -xp_full_w / 2.0, 12.0, xp_full_w / 2.0, 36.0)
	bars.add_child(xp_bg)
	xp_fill = ColorRect.new()
	xp_fill.color = Color(0.36, 0.78, 1.0)
	_anchor(xp_fill, 0.5, 0.0, 0.5, 0.0, -xp_full_w / 2.0, 14.0, -xp_full_w / 2.0, 34.0)
	bars.add_child(xp_fill)
	xp_label = _label("Niv. 1", 14, CREAM)
	_anchor(xp_label, 0.5, 0.0, 0.5, 0.0, -60.0, 13.0, 60.0, 35.0)
	xp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bars.add_child(xp_label)

	# Chrono + kills
	timer_label = _label("00:00", 20, Color(1.0, 0.91, 0.66))
	_anchor(timer_label, 0.5, 0.0, 0.5, 0.0, -120.0, 42.0, -10.0, 70.0)
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	bars.add_child(timer_label)
	kills_label = _label("Tués 0", 20, Color(1.0, 0.60, 0.60))
	_anchor(kills_label, 0.5, 0.0, 0.5, 0.0, 14.0, 42.0, 140.0, 70.0)
	bars.add_child(kills_label)

	# Vie (bas centré — le coin bas-gauche est pris par la roue)
	var hp_bg := ColorRect.new()
	hp_bg.color = Color(0, 0, 0, 0.55)
	_anchor(hp_bg, 0.5, 1.0, 0.5, 1.0, -hp_full_w / 2.0, -42.0, hp_full_w / 2.0, -18.0)
	bars.add_child(hp_bg)
	hp_fill = ColorRect.new()
	hp_fill.color = Color(0.85, 0.26, 0.31)
	_anchor(hp_fill, 0.5, 1.0, 0.5, 1.0, -hp_full_w / 2.0, -40.0, -hp_full_w / 2.0, -20.0)
	bars.add_child(hp_fill)
	hp_label = _label("PV 100 / 100", 14, Color(1, 1, 1))
	_anchor(hp_label, 0.5, 1.0, 0.5, 1.0, -hp_full_w / 2.0, -41.0, hp_full_w / 2.0, -19.0)
	hp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bars.add_child(hp_label)

	mute_label = _label("Muet", 14, LILAC)
	_anchor(mute_label, 1.0, 0.0, 1.0, 0.0, -110.0, 12.0, -12.0, 34.0)
	mute_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	mute_label.visible = false
	bars.add_child(mute_label)

	# Roue de sorts (bas-gauche)
	wheel = VSWheel.new()
	wheel.anchor_right = 1.0
	wheel.anchor_bottom = 1.0
	wheel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(wheel)

func _build_menu() -> void:
	overlay_menu = _overlay(false)
	var p := _panel(600, 470)
	overlay_menu.add_child(p)
	var v := _vbox(p)
	v.add_child(_title("CRÉPUSCULE"))
	v.add_child(_label("Survis aux vagues. Ton arme frappe toute seule.", 16, CREAM, true))
	v.add_child(_spacer(6))
	var b1 := _button("NOUVELLE PARTIE")
	b1.pressed.connect(func(): play_pressed.emit())
	v.add_child(b1)
	var b2 := _button("OPTIONS")
	b2.pressed.connect(func(): show_options())
	v.add_child(b2)
	var b3 := _button("SCORES")
	b3.pressed.connect(func(): show_scoreboard())
	v.add_child(b3)
	var b4 := _button("QUITTER")
	b4.pressed.connect(func(): get_tree().quit())
	v.add_child(b4)
	v.add_child(_spacer(2))
	v.add_child(_label("WASD/ZQSD/flèches  ·  Sorts : 1 2 3 4  ·  Pause : P  ·  Son : M", 12, LILAC, true))
	add_child(overlay_menu)
	overlay_menu.visible = false

func _build_options() -> void:
	overlay_options = _overlay(false)
	var p := _panel(560, 380)
	overlay_options.add_child(p)
	var v := _vbox(p)
	v.add_child(_title2("OPTIONS"))
	v.add_child(_spacer(6))
	music_pct = _label("Musique : 55%", 16, CREAM, true)
	v.add_child(music_pct)
	var ms := _slider(0.55)
	ms.value_changed.connect(func(val):
		music_pct.text = "Musique : %d%%" % int(round(val * 100))
		music_changed.emit(val))
	v.add_child(ms)
	v.add_child(_spacer(8))
	sfx_pct = _label("Effets : 85%", 16, CREAM, true)
	v.add_child(sfx_pct)
	var ss := _slider(0.85)
	ss.value_changed.connect(func(val):
		sfx_pct.text = "Effets : %d%%" % int(round(val * 100))
		sfx_changed.emit(val))
	v.add_child(ss)
	v.add_child(_spacer(10))
	var back := _button("RETOUR")
	back.pressed.connect(func(): show_menu())
	v.add_child(back)
	add_child(overlay_options)
	overlay_options.visible = false

func _build_scores() -> void:
	overlay_scores = _overlay(false)
	var p := _panel(620, 480)
	overlay_scores.add_child(p)
	var v := _vbox(p)
	v.name = "box"
	add_child(overlay_scores)
	overlay_scores.visible = false

func _build_levelup() -> void:
	overlay_levelup = _overlay(true)
	var p := _panel(680, 320)
	overlay_levelup.add_child(p)
	var v := _vbox(p)
	v.add_child(_title2("NIVEAU SUPÉRIEUR !"))
	v.add_child(_label("Choisis une amélioration", 16, CREAM, true))
	cards_box = HBoxContainer.new()
	cards_box.alignment = BoxContainer.ALIGNMENT_CENTER
	cards_box.add_theme_constant_override("separation", 14)
	v.add_child(cards_box)
	add_child(overlay_levelup)
	overlay_levelup.visible = false

func _build_gameover() -> void:
	overlay_gameover = _overlay(false)
	var p := _panel(620, 540)
	overlay_gameover.add_child(p)
	go_box = _vbox(p)
	add_child(overlay_gameover)
	overlay_gameover.visible = false

func _build_pause() -> void:
	overlay_pause = _overlay(true)
	var p := _panel(420, 200)
	overlay_pause.add_child(p)
	var v := _vbox(p)
	v.add_child(_title2("PAUSE"))
	v.add_child(_label("Appuie sur P pour reprendre", 16, CREAM, true))
	add_child(overlay_pause)
	overlay_pause.visible = false

# ----- API jeu -----
func set_xp(pct: float, level: int) -> void:
	xp_fill.offset_right = xp_fill.offset_left + xp_full_w * clampf(pct, 0.0, 1.0)
	xp_label.text = "Niv. %d" % level

func set_hp(hp: float, maxhp: float) -> void:
	hp_fill.offset_right = hp_fill.offset_left + hp_full_w * clampf(hp / maxhp, 0.0, 1.0)
	hp_label.text = "PV %d / %d" % [maxi(0, int(ceil(hp))), int(maxhp)]

func set_time(t: String) -> void:
	timer_label.text = t

func set_kills(k: int) -> void:
	kills_label.text = "Tués %d" % k

func set_muted(m: bool) -> void:
	mute_label.visible = m

func show_hud(b: bool) -> void:
	bars.visible = b
	wheel.visible = b

func hide_overlays() -> void:
	menu_bg.visible = false
	overlay_menu.visible = false
	overlay_options.visible = false
	overlay_scores.visible = false
	overlay_levelup.visible = false
	overlay_gameover.visible = false
	overlay_pause.visible = false

func show_menu() -> void:
	hide_overlays()
	bars.visible = false
	wheel.visible = false
	menu_bg.visible = true
	overlay_menu.visible = true

func show_options() -> void:
	hide_overlays()
	menu_bg.visible = true
	overlay_options.visible = true

func show_scoreboard() -> void:
	hide_overlays()
	menu_bg.visible = true
	var box := _scores_box()
	if box == null:
		return
	for c in box.get_children():
		c.queue_free()
	box.add_child(_title2("MEILLEURS SCORES"))
	box.add_child(_spacer(4))
	_score_rows(box, VSScores.load_all(), -1, 10)
	box.add_child(_spacer(8))
	var back := _button("RETOUR")
	back.pressed.connect(func(): show_menu())
	box.add_child(back)
	overlay_scores.visible = true

func _scores_box() -> VBoxContainer:
	# le VBox a été ajouté au Panel dans _build_scores ; on le retrouve
	for c in overlay_scores.get_children():
		if c is Panel:
			for cc in c.get_children():
				if cc is VBoxContainer:
					return cc
	return null

func show_levelup(choices: Array) -> void:
	for c in cards_box.get_children():
		c.queue_free()
	for choice in choices:
		var card := _button("%s\n%s" % [choice["name"], choice["desc"]])
		card.custom_minimum_size = Vector2(190, 104)
		card.pressed.connect(func(): upgrade_chosen.emit(choice["id"]))
		cards_box.add_child(card)
	overlay_levelup.visible = true

# Écran de fin : phase 1 = saisie du nom
func show_gameover_entry(time_str: String, level: int, kills: int, score: int, last_name: String) -> void:
	hide_overlays()
	menu_bg.visible = true
	for c in go_box.get_children():
		c.queue_free()
	go_box.add_child(_title2("TU ES TOMBÉ"))
	go_box.add_child(_label("Temps %s   ·   Niveau %d   ·   %d tués" % [time_str, level, kills], 15, CREAM, true))
	go_box.add_child(_label("Score : %d" % score, 22, GOLD, true))
	go_box.add_child(_spacer(4))
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 10)
	var edit := LineEdit.new()
	edit.text = last_name
	edit.max_length = 14
	edit.custom_minimum_size = Vector2(220, 38)
	edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	edit.placeholder_text = "Ton nom"
	edit.text_submitted.connect(func(_t): name_submitted.emit(edit.text))
	row.add_child(edit)
	var ok := _button("VALIDER")
	ok.custom_minimum_size = Vector2(140, 40)
	ok.pressed.connect(func(): name_submitted.emit(edit.text))
	row.add_child(ok)
	go_box.add_child(row)
	go_box.add_child(_spacer(6))
	go_box.add_child(_label("— Meilleurs scores —", 13, LILAC, true))
	_score_rows(go_box, VSScores.load_all(), -1, 6)
	overlay_gameover.visible = true
	edit.grab_focus()
	edit.select_all()

# Écran de fin : phase 2 = tableau après enregistrement
func show_gameover_result(scores: Array, rank: int, score: int) -> void:
	for c in go_box.get_children():
		c.queue_free()
	go_box.add_child(_title2("TU ES TOMBÉ"))
	go_box.add_child(_label("Score : %d — enregistré !" % score, 18, GOLD, true))
	go_box.add_child(_spacer(2))
	_score_rows(go_box, scores, rank, 9)
	go_box.add_child(_spacer(8))
	var hb := HBoxContainer.new()
	hb.alignment = BoxContainer.ALIGNMENT_CENTER
	hb.add_theme_constant_override("separation", 12)
	var r := _button("REJOUER")
	r.custom_minimum_size = Vector2(200, 48)
	r.pressed.connect(func(): retry_pressed.emit())
	hb.add_child(r)
	var m := _button("MENU")
	m.custom_minimum_size = Vector2(200, 48)
	m.pressed.connect(func(): to_menu_pressed.emit())
	hb.add_child(m)
	go_box.add_child(hb)

func show_pause(b: bool) -> void:
	overlay_pause.visible = b

# ----- Helpers -----
func _score_rows(parent: Control, scores: Array, highlight: int, limit: int) -> void:
	if scores.is_empty():
		parent.add_child(_label("(aucun score pour l'instant)", 14, LILAC, true))
		return
	var n := mini(scores.size(), limit)
	for i in n:
		var e: Dictionary = scores[i]
		var txt := "%2d.  %-14s %6d    %s · Niv %d · %d tués" % [
			i + 1, str(e.get("name", "?")), int(e.get("score", 0)),
			str(e.get("time", "00:00")), int(e.get("level", 1)), int(e.get("kills", 0))]
		var col := GOLD if i == highlight else CREAM
		var l := _label(txt, 15, col, true)
		parent.add_child(l)

func _full_control() -> Control:
	var c := Control.new()
	c.anchor_right = 1.0
	c.anchor_bottom = 1.0
	return c

func _overlay(with_dim: bool) -> Control:
	var c := _full_control()
	if with_dim:
		var dim := ColorRect.new()
		dim.color = Color(0.03, 0.024, 0.055, 0.66)
		dim.anchor_right = 1.0
		dim.anchor_bottom = 1.0
		dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
		c.add_child(dim)
	return c

func _panel(w: float, h: float) -> Panel:
	var p := Panel.new()
	_anchor(p, 0.5, 0.5, 0.5, 0.5, -w / 2.0, -h / 2.0, w / 2.0, h / 2.0)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.118, 0.094, 0.157, 0.96)
	sb.border_color = Color(0.45, 0.36, 0.22)
	sb.set_border_width_all(3)
	sb.set_corner_radius_all(16)
	sb.set_content_margin_all(20)
	sb.shadow_color = Color(0, 0, 0, 0.5)
	sb.shadow_size = 14
	p.add_theme_stylebox_override("panel", sb)
	return p

func _vbox(parent: Control) -> VBoxContainer:
	var v := VBoxContainer.new()
	v.anchor_right = 1.0
	v.anchor_bottom = 1.0
	v.offset_left = 26
	v.offset_top = 22
	v.offset_right = -26
	v.offset_bottom = -22
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override("separation", 10)
	parent.add_child(v)
	return v

func _title(text: String) -> Label:
	var l := _label(text, 52, GOLD, true)
	l.add_theme_color_override("font_shadow_color", Color(0.48, 0.29, 0.08))
	l.add_theme_constant_override("shadow_offset_x", 3)
	l.add_theme_constant_override("shadow_offset_y", 3)
	return l

func _title2(text: String) -> Label:
	var l := _label(text, 32, GOLD, true)
	l.add_theme_color_override("font_shadow_color", Color(0.48, 0.29, 0.08))
	l.add_theme_constant_override("shadow_offset_x", 2)
	l.add_theme_constant_override("shadow_offset_y", 2)
	return l

func _spacer(h: int) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(0, h)
	return c

func _label(text: String, size: int, color: Color, center: bool = false) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if center:
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return l

func _slider(v: float) -> HSlider:
	var s := HSlider.new()
	s.min_value = 0.0
	s.max_value = 1.0
	s.step = 0.05
	s.value = v
	s.custom_minimum_size = Vector2(320, 24)
	s.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	return s

func _button(text: String) -> Button:
	var b := Button.new()
	b.text = text
	b.add_theme_font_size_override("font_size", 18)
	b.custom_minimum_size = Vector2(300, 50)
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.196, 0.490, 0.819)
	normal.set_corner_radius_all(10)
	normal.set_content_margin_all(10)
	var hover := normal.duplicate()
	hover.bg_color = Color(0.290, 0.612, 0.886)
	var pressed := normal.duplicate()
	pressed.bg_color = Color(0.141, 0.353, 0.612)
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("hover", hover)
	b.add_theme_stylebox_override("pressed", pressed)
	b.add_theme_stylebox_override("focus", hover)
	b.add_theme_color_override("font_color", Color(1, 1, 1))
	return b

func _anchor(c: Control, al: float, at: float, ar: float, ab: float, ol: float, ot: float, orr: float, ob: float) -> void:
	c.anchor_left = al
	c.anchor_top = at
	c.anchor_right = ar
	c.anchor_bottom = ab
	c.offset_left = ol
	c.offset_top = ot
	c.offset_right = orr
	c.offset_bottom = ob
