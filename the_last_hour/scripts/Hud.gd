# Hud.gd — interface : timer géant, santé, cellules, alertes, boss bar, écrans.
class_name TLHHud
extends CanvasLayer

signal start_pressed()
signal continue_pressed()
signal retry_pressed()
signal quit_pressed()
signal menu_principal_pressed()

var _timer_lbl: Label
var _hp_fill: ColorRect
var _hp_bg: ColorRect
var _cells_lbl: Label
var _alert_lbl: Label
var _alert_t := 0.0
var _boss_container: Control
var _boss_fill: ColorRect
var _boss_phase_lbl: Label
var _boss_lbl: Label
var _revelation_panel: Control = null

var _overlay: ColorRect
var _menu_panel: Control
var _death_panel: Control
var _victory_panel: Control
var _gameover_panel: Control
var _hud_root: Control

const HP_BAR_W := 220.0
const HP_BAR_H := 18.0

func build() -> void:
	_hud_root = Control.new()
	_hud_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_hud_root)

	# ── Timer ──────────────────────────────────────────────────────────────────
	_timer_lbl = Label.new()
	_timer_lbl.text = "60:00"
	_timer_lbl.add_theme_font_size_override("font_size", 56)
	_timer_lbl.add_theme_color_override("font_color", Color(1, 1, 1))
	_timer_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_timer_lbl.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_timer_lbl.offset_top = 8
	_timer_lbl.offset_left = -100
	_timer_lbl.size = Vector2(200, 70)
	_hud_root.add_child(_timer_lbl)

	# ── HP bar ─────────────────────────────────────────────────────────────────
	_hp_bg = ColorRect.new()
	_hp_bg.size = Vector2(HP_BAR_W, HP_BAR_H)
	_hp_bg.position = Vector2(18, 18)
	_hp_bg.color = Color(0.18, 0.05, 0.05)
	_hud_root.add_child(_hp_bg)

	_hp_fill = ColorRect.new()
	_hp_fill.size = Vector2(HP_BAR_W, HP_BAR_H)
	_hp_fill.position = Vector2(18, 18)
	_hp_fill.color = Color(0.85, 0.2, 0.2)
	_hud_root.add_child(_hp_fill)

	var hp_border := ColorRect.new()
	hp_border.size = Vector2(HP_BAR_W + 2, HP_BAR_H + 2)
	hp_border.position = Vector2(17, 17)
	hp_border.color = Color(0.55, 0.55, 0.55, 0.6)
	hp_border.z_index = -1
	_hud_root.add_child(hp_border)

	var hp_lbl := Label.new()
	hp_lbl.text = "❤  HP"
	hp_lbl.add_theme_font_size_override("font_size", 12)
	hp_lbl.add_theme_color_override("font_color", Color(0.9, 0.7, 0.7))
	hp_lbl.position = Vector2(18, 2)
	_hud_root.add_child(hp_lbl)

	# ── Cells ──────────────────────────────────────────────────────────────────
	_cells_lbl = Label.new()
	_cells_lbl.text = "⚜ 0 cellules"
	_cells_lbl.add_theme_font_size_override("font_size", 14)
	_cells_lbl.add_theme_color_override("font_color", Color(0.6, 0.95, 0.6))
	_cells_lbl.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_cells_lbl.offset_right = -16
	_cells_lbl.offset_top = 18
	_cells_lbl.size = Vector2(180, 24)
	_cells_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_hud_root.add_child(_cells_lbl)

	# ── Controls hint ──────────────────────────────────────────────────────────
	var hint_lbl := Label.new()
	hint_lbl.text = "AZQD/←→: bouger  |  Espace: sauter  |  Shift: dash  |  J: épée  |  K: couteau"
	hint_lbl.add_theme_font_size_override("font_size", 11)
	hint_lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.6, 0.7))
	hint_lbl.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	hint_lbl.offset_bottom = -4
	hint_lbl.offset_left = 12
	hint_lbl.size = Vector2(700, 20)
	_hud_root.add_child(hint_lbl)

	# ── Alert ──────────────────────────────────────────────────────────────────
	_alert_lbl = Label.new()
	_alert_lbl.text = ""
	_alert_lbl.add_theme_font_size_override("font_size", 30)
	_alert_lbl.add_theme_color_override("font_color", Color(1.0, 0.6, 0.1))
	_alert_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_alert_lbl.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_alert_lbl.offset_top = 80
	_alert_lbl.size = Vector2(900, 50)
	_alert_lbl.offset_left = -450
	_alert_lbl.modulate.a = 0.0
	_hud_root.add_child(_alert_lbl)

	# ── Boss HP bar ────────────────────────────────────────────────────────────
	_boss_container = Control.new()
	_boss_container.visible = false
	_boss_container.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	_boss_container.offset_bottom = -8
	_boss_container.offset_top = -50
	_hud_root.add_child(_boss_container)

	var boss_bg := ColorRect.new()
	boss_bg.size = Vector2(600, 22)
	boss_bg.position = Vector2(340, 14)
	boss_bg.color = Color(0.15, 0.05, 0.05)
	_boss_container.add_child(boss_bg)

	_boss_fill = ColorRect.new()
	_boss_fill.size = Vector2(600, 22)
	_boss_fill.position = Vector2(340, 14)
	_boss_fill.color = Color(0.85, 0.15, 0.15)
	_boss_container.add_child(_boss_fill)

	_boss_lbl = Label.new()
	_boss_lbl.text = "LE GEÔLIER"
	_boss_lbl.add_theme_font_size_override("font_size", 13)
	_boss_lbl.add_theme_color_override("font_color", Color(1, 0.7, 0.7))
	_boss_lbl.position = Vector2(340, 0)
	_boss_container.add_child(_boss_lbl)

	_boss_phase_lbl = Label.new()
	_boss_phase_lbl.text = ""
	_boss_phase_lbl.add_theme_font_size_override("font_size", 13)
	_boss_phase_lbl.add_theme_color_override("font_color", Color(1, 0.4, 0.4))
	_boss_phase_lbl.position = Vector2(760, 0)
	_boss_container.add_child(_boss_phase_lbl)

	# ── Overlay ────────────────────────────────────────────────────────────────
	_overlay = ColorRect.new()
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.color = Color(0, 0, 0, 0.72)
	_overlay.visible = false
	_hud_root.add_child(_overlay)

	_build_menu_panel()
	_build_death_panel()
	_build_victory_panel()
	_build_gameover_panel()

# ── Panels ──────────────────────────────────────────────────────────────────────

func _build_menu_panel() -> void:
	_menu_panel = _make_panel()

	_add_label(_menu_panel, "THE LAST HOUR", 52, Color(1.0, 0.92, 0.6), Vector2(0, -200))
	_add_label(_menu_panel, "Ton fils a été enlevé et emprisonné dans le donjon du Geôlier.", 18,
			Color(0.85, 0.85, 0.95), Vector2(0, -130))
	_add_label(_menu_panel, "Tu as exactement 60 minutes — en temps réel — pour le sauver.", 18,
			Color(0.9, 0.7, 0.7), Vector2(0, -100))
	_add_label(_menu_panel, "Chaque run reprend où tu t'es arrêté. Le temps, lui, ne s'arrête jamais.", 15,
			Color(0.6, 0.6, 0.7), Vector2(0, -60))

	_add_btn(_menu_panel, "COMMENCER", Vector2(0, 60), func(): emit_signal("start_pressed"))
	_add_btn(_menu_panel, "QUITTER",   Vector2(0, 110), func(): emit_signal("quit_pressed"))

func _build_death_panel() -> void:
	_death_panel = _make_panel()
	_death_panel.visible = false

	_add_label(_death_panel, "TOMBÉ AU COMBAT", 44, Color(0.9, 0.3, 0.3), Vector2(0, -200))

	var timer_hint := _add_label(_death_panel, "", 32, Color(1.0, 0.75, 0.2), Vector2(0, -130))
	timer_hint.name = "TimerHint"

	var cells_lbl := _add_label(_death_panel, "", 22, Color(0.55, 0.9, 0.55), Vector2(0, -80))
	cells_lbl.name = "CellsLabel"

	_add_label(_death_panel, "Le timer continue. Ton fils attend.", 16,
			Color(0.65, 0.65, 0.75), Vector2(0, -40))

	_add_btn(_death_panel, "CONTINUER",      Vector2(0, 50),  func(): emit_signal("continue_pressed"))
	_add_btn(_death_panel, "MENU PRINCIPAL", Vector2(0, 100), func(): emit_signal("menu_principal_pressed"))
	_add_btn(_death_panel, "QUITTER",        Vector2(0, 150), func(): emit_signal("quit_pressed"))

func _build_victory_panel() -> void:
	_victory_panel = _make_panel()
	_victory_panel.visible = false
	_victory_panel.modulate = Color(0.8, 1.0, 0.8)

	_add_label(_victory_panel, "SAUVÉ !", 64, Color(0.9, 1.0, 0.5), Vector2(0, -220))
	_add_label(_victory_panel, "Tu as vaincu le Geôlier et libéré ton fils.", 22,
			Color(0.9, 0.95, 0.8), Vector2(0, -145))

	var time_lbl := _add_label(_victory_panel, "", 26, Color(1.0, 0.9, 0.4), Vector2(0, -100))
	time_lbl.name = "TimeLabel"

	_add_btn(_victory_panel, "REJOUER",       Vector2(0, 50),  func(): emit_signal("retry_pressed"))
	_add_btn(_victory_panel, "MENU PRINCIPAL",Vector2(0, 100), func(): emit_signal("menu_principal_pressed"))
	_add_btn(_victory_panel, "QUITTER",       Vector2(0, 150), func(): emit_signal("quit_pressed"))

func _build_gameover_panel() -> void:
	_gameover_panel = _make_panel()
	_gameover_panel.visible = false
	_gameover_panel.modulate = Color(1.0, 0.6, 0.6)

	_add_label(_gameover_panel, "TON FILS EST MORT.", 48, Color(0.95, 0.25, 0.25), Vector2(0, -200))
	_add_label(_gameover_panel, "L'heure s'est écoulée. Tu n'as pas réussi à temps.", 20,
			Color(0.85, 0.6, 0.6), Vector2(0, -130))
	_add_label(_gameover_panel, "Certains secrets ne pardonnent pas.", 16,
			Color(0.65, 0.45, 0.45), Vector2(0, -90))

	_add_btn(_gameover_panel, "REJOUER",        Vector2(0, 50),  func(): emit_signal("retry_pressed"))
	_add_btn(_gameover_panel, "MENU PRINCIPAL", Vector2(0, 100), func(): emit_signal("menu_principal_pressed"))
	_add_btn(_gameover_panel, "QUITTER",        Vector2(0, 150), func(): emit_signal("quit_pressed"))

# ── Public API ──────────────────────────────────────────────────────────────────

func show_menu() -> void:
	_overlay.visible = true
	_menu_panel.visible = true
	_death_panel.visible = false
	_victory_panel.visible = false
	_gameover_panel.visible = false
	_hud_root.visible = true

func show_hud(visible_: bool) -> void:
	_timer_lbl.visible  = visible_
	_hp_bg.visible      = visible_
	_hp_fill.visible    = visible_
	_cells_lbl.visible  = visible_

func hide_overlays() -> void:
	_overlay.visible       = false
	_menu_panel.visible    = false
	_death_panel.visible   = false
	_victory_panel.visible = false
	_gameover_panel.visible = false

func show_death(time_fmt: String, cells: int) -> void:
	_overlay.visible = true
	_death_panel.visible = true
	var th := _death_panel.get_node("TimerHint") as Label
	if th: th.text = "Temps restant : %s" % time_fmt
	var cl := _death_panel.get_node("CellsLabel") as Label
	if cl: cl.text = "%d cellules récupérées cette run" % cells

func show_victory(time_remaining: String) -> void:
	_overlay.visible = true
	_victory_panel.visible = true
	var tl := _victory_panel.get_node("TimeLabel") as Label
	if tl: tl.text = "Temps restant : %s" % time_remaining

func show_gameover() -> void:
	_overlay.visible = true
	_gameover_panel.visible = true

func update_timer(remaining: float) -> void:
	var m := int(remaining) / 60
	var s := int(remaining) % 60
	_timer_lbl.text = "%02d:%02d" % [m, s]
	# Color changes with urgency
	if remaining <= 60.0:
		var pulse := absf(sin(Time.get_ticks_msec() * 0.006))
		_timer_lbl.add_theme_color_override("font_color", Color(1.0, pulse * 0.3, pulse * 0.3))
	elif remaining <= 360.0:
		_timer_lbl.add_theme_color_override("font_color", Color(1.0, 0.35, 0.1))
	elif remaining <= 900.0:
		_timer_lbl.add_theme_color_override("font_color", Color(1.0, 0.78, 0.1))
	else:
		_timer_lbl.add_theme_color_override("font_color", Color(0.95, 0.95, 0.95))

func update_hp(current: int, maximum: int) -> void:
	var pct := float(current) / float(maximum) if maximum > 0 else 0.0
	_hp_fill.size.x = HP_BAR_W * pct
	if pct < 0.3:
		_hp_fill.color = Color(0.9, 0.1, 0.1)
	elif pct < 0.6:
		_hp_fill.color = Color(0.85, 0.45, 0.1)
	else:
		_hp_fill.color = Color(0.8, 0.2, 0.2)

func update_cells(n: int) -> void:
	_cells_lbl.text = "⚜ %d cellules" % n

func update_boss_hp(pct: float) -> void:
	if pct < 0.0:
		_boss_container.visible = false
		return
	_boss_container.visible = true
	_boss_fill.size.x = 600.0 * pct

func show_boss_phase(n: int) -> void:
	if is_instance_valid(_boss_phase_lbl):
		_boss_phase_lbl.text = "Phase %d" % n

func update_boss_name(name: String) -> void:
	if is_instance_valid(_boss_lbl):
		_boss_lbl.text = name
		_boss_lbl.add_theme_color_override("font_color", Color(0.9, 0.6, 1.0))

func show_revelation() -> void:
	if _revelation_panel == null:
		_build_revelation_panel()
	_overlay.visible = true
	_revelation_panel.visible = true
	var t := create_tween()
	t.tween_interval(5.2)
	t.tween_callback(func():
		if is_instance_valid(_revelation_panel):
			_revelation_panel.visible = false
		_overlay.visible = false
	)

func _build_revelation_panel() -> void:
	_revelation_panel = _make_panel()
	_revelation_panel.visible = false
	_add_label(_revelation_panel, "...", 28, Color(0.65, 0.55, 0.75), Vector2(0, -220))
	_add_label(_revelation_panel, "Le Geôlier n'était que le premier garde.", 24,
			Color(0.80, 0.70, 0.90), Vector2(0, -160))
	_add_label(_revelation_panel, "Une voix s'élève depuis l'obscurité :", 22,
			Color(0.72, 0.62, 0.84), Vector2(0, -108))
	_add_label(_revelation_panel, "« Mes fils... je vous attendais. »", 30,
			Color(0.96, 0.92, 1.00), Vector2(0, -50))
	_add_label(_revelation_panel, "VOTRE MÈRE EST UN VAMPIRE.", 46,
			Color(0.72, 0.06, 0.86), Vector2(0, 28))
	_add_label(_revelation_panel, "Elle a tout orchestré depuis le début.", 20,
			Color(0.68, 0.58, 0.80), Vector2(0, 100))
	_add_label(_revelation_panel, "Elle vous a abandonnés... pour devenir ceci.", 17,
			Color(0.50, 0.42, 0.62), Vector2(0, 138))

func show_alert(text: String) -> void:
	_alert_lbl.text = text
	_alert_t = 3.5
	_alert_lbl.modulate.a = 1.0

func _process(delta: float) -> void:
	if _alert_t > 0.0:
		_alert_t -= delta
		_alert_lbl.modulate.a = clampf(_alert_t / 0.8, 0.0, 1.0)

# ── Builder helpers ─────────────────────────────────────────────────────────────

func _make_panel() -> Control:
	var p := Control.new()
	p.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.add_child(p)
	return p

func _add_label(parent: Control, text: String, size: int, color: Color, offset: Vector2) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	l.offset_top    = offset.y
	l.offset_left   = -500
	l.size          = Vector2(1000, size + 10)
	parent.add_child(l)
	return l

func _add_btn(parent: Control, text: String, offset: Vector2, callback: Callable) -> void:
	var btn := Button.new()
	btn.text = text
	btn.add_theme_font_size_override("font_size", 20)
	btn.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	btn.offset_top  = offset.y
	btn.offset_left = -100
	btn.size        = Vector2(200, 40)
	btn.pressed.connect(callback)
	parent.add_child(btn)
