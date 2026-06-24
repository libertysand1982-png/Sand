# Hud.gd — interface : barres XP/PV, chrono, kills, et les écrans menu / niveau / fin / pause.
class_name VSHud
extends CanvasLayer

signal play_pressed
signal retry_pressed
signal upgrade_chosen(id: String)

const GOLD := Color(1.0, 0.847, 0.420)
const CREAM := Color(0.957, 0.925, 0.776)

var bars: Control
var xp_fill: ColorRect
var xp_label: Label
var hp_fill: ColorRect
var hp_label: Label
var timer_label: Label
var kills_label: Label
var mute_label: Label
var hp_full_w := 240.0
var xp_full_w := 700.0

var overlay_menu: Control
var overlay_levelup: Control
var overlay_gameover: Control
var overlay_pause: Control
var cards_box: HBoxContainer
var go_stats: Label

# ----- Construction -----
func build() -> void:
	bars = _full_control()
	bars.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bars)

	# Barre d'XP (haut, centrée)
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

	# Barre de vie (bas-gauche)
	var hp_bg := ColorRect.new()
	hp_bg.color = Color(0, 0, 0, 0.55)
	_anchor(hp_bg, 0.0, 1.0, 0.0, 1.0, 18.0, -42.0, 18.0 + hp_full_w, -18.0)
	bars.add_child(hp_bg)
	hp_fill = ColorRect.new()
	hp_fill.color = Color(0.85, 0.26, 0.31)
	_anchor(hp_fill, 0.0, 1.0, 0.0, 1.0, 20.0, -40.0, 20.0 + hp_full_w, -20.0)
	bars.add_child(hp_fill)
	hp_label = _label("PV 100 / 100", 14, Color(1, 1, 1))
	_anchor(hp_label, 0.0, 1.0, 0.0, 1.0, 28.0, -41.0, 28.0 + hp_full_w, -19.0)
	bars.add_child(hp_label)

	# Indicateur muet (haut-droite)
	mute_label = _label("Muet", 14, Color(0.72, 0.66, 0.81))
	_anchor(mute_label, 1.0, 0.0, 1.0, 0.0, -110.0, 12.0, -12.0, 34.0)
	mute_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	mute_label.visible = false
	bars.add_child(mute_label)

	# ----- Overlays -----
	overlay_menu = _overlay()
	var mp := _panel(560, 360)
	overlay_menu.add_child(mp)
	var mv := _vbox(mp)
	mv.add_child(_label("CRÉPUSCULE", 44, GOLD, true))
	mv.add_child(_label("Survis aux vagues. Ton arme frappe toute seule :\nramasse les gemmes, monte en niveau, deviens surpuissant.", 16, CREAM, true))
	mv.add_child(_label("Déplacement : WASD / ZQSD / flèches   ·   Pause : P   ·   Son : M", 13, Color(0.72, 0.66, 0.81), true))
	var play_btn := _button("JOUER")
	play_btn.pressed.connect(func(): play_pressed.emit())
	mv.add_child(play_btn)
	add_child(overlay_menu)

	overlay_levelup = _overlay()
	var lp := _panel(640, 320)
	overlay_levelup.add_child(lp)
	var lv := _vbox(lp)
	lv.add_child(_label("NIVEAU SUPÉRIEUR !", 32, GOLD, true))
	lv.add_child(_label("Choisis une amélioration", 16, CREAM, true))
	cards_box = HBoxContainer.new()
	cards_box.alignment = BoxContainer.ALIGNMENT_CENTER
	cards_box.add_theme_constant_override("separation", 14)
	lv.add_child(cards_box)
	overlay_levelup.visible = false
	add_child(overlay_levelup)

	overlay_gameover = _overlay()
	var gp := _panel(520, 300)
	overlay_gameover.add_child(gp)
	var gv := _vbox(gp)
	gv.add_child(_label("TU ES TOMBÉ", 32, GOLD, true))
	go_stats = _label("", 17, CREAM, true)
	gv.add_child(go_stats)
	var retry_btn := _button("REJOUER")
	retry_btn.pressed.connect(func(): retry_pressed.emit())
	gv.add_child(retry_btn)
	overlay_gameover.visible = false
	add_child(overlay_gameover)

	overlay_pause = _overlay()
	var pp := _panel(420, 200)
	overlay_pause.add_child(pp)
	var pv := _vbox(pp)
	pv.add_child(_label("PAUSE", 32, GOLD, true))
	pv.add_child(_label("Appuie sur P pour reprendre", 16, CREAM, true))
	overlay_pause.visible = false
	add_child(overlay_pause)

	bars.visible = false

# ----- API appelée par Main -----
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

func hide_overlays() -> void:
	overlay_menu.visible = false
	overlay_levelup.visible = false
	overlay_gameover.visible = false
	overlay_pause.visible = false

func show_menu() -> void:
	hide_overlays()
	bars.visible = false
	overlay_menu.visible = true

func show_levelup(choices: Array) -> void:
	for c in cards_box.get_children():
		c.queue_free()
	for choice in choices:
		var card := _button("%s\n%s" % [choice["name"], choice["desc"]])
		card.custom_minimum_size = Vector2(170, 96)
		card.pressed.connect(func(): upgrade_chosen.emit(choice["id"]))
		cards_box.add_child(card)
	overlay_levelup.visible = true

func show_gameover(time_str: String, level: int, kills: int) -> void:
	go_stats.text = "Temps survécu : %s\nNiveau atteint : %d\nMonstres vaincus : %d" % [time_str, level, kills]
	overlay_gameover.visible = true

func show_pause(b: bool) -> void:
	overlay_pause.visible = b

# ----- Helpers de construction -----
func _full_control() -> Control:
	var c := Control.new()
	c.anchor_right = 1.0
	c.anchor_bottom = 1.0
	return c

func _overlay() -> Control:
	var c := _full_control()
	var dim := ColorRect.new()
	dim.color = Color(0.03, 0.024, 0.055, 0.72)
	dim.anchor_right = 1.0
	dim.anchor_bottom = 1.0
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	c.add_child(dim)
	return c

func _panel(w: float, h: float) -> Panel:
	var p := Panel.new()
	_anchor(p, 0.5, 0.5, 0.5, 0.5, -w / 2.0, -h / 2.0, w / 2.0, h / 2.0)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.141, 0.110, 0.180)
	sb.border_color = Color(0.354, 0.282, 0.435)
	sb.set_border_width_all(4)
	sb.set_corner_radius_all(14)
	sb.set_content_margin_all(18)
	p.add_theme_stylebox_override("panel", sb)
	return p

func _vbox(parent: Control) -> VBoxContainer:
	var v := VBoxContainer.new()
	v.anchor_right = 1.0
	v.anchor_bottom = 1.0
	v.offset_left = 24
	v.offset_top = 24
	v.offset_right = -24
	v.offset_bottom = -24
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override("separation", 14)
	parent.add_child(v)
	return v

func _label(text: String, size: int, color: Color, center: bool = false) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if center:
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return l

func _button(text: String) -> Button:
	var b := Button.new()
	b.text = text
	b.add_theme_font_size_override("font_size", 18)
	b.custom_minimum_size = Vector2(160, 48)
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
