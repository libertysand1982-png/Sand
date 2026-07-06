# Hud.gd — interface : HUD de jeu (barres + roue de sorts) + menus
# (accueil, options, scores, niveau, fin avec saisie du nom, pause).
class_name VSHud
extends CanvasLayer

signal play_pressed
signal retry_pressed
signal to_menu_pressed
signal upgrade_chosen(id: String)
signal sfx_changed(v: float)
signal music_changed(v: float)
signal hero_selected(hero_id: String)
signal name_submitted(player_name: String)
signal intro_done(to_menu: bool)
signal history_pressed

const GOLD := Color(1.0, 0.847, 0.420)
const CREAM := Color(0.957, 0.925, 0.776)
const LILAC := Color(0.72, 0.66, 0.81)

# Polices du pack RPG MMO UI
var font_title: FontFile   # Ringbearer — titres & boutons
var font_text: FontFile    # Palatino — texte courant

var bars: Control
var menu_bg: Control
var wheel: VSWheel
var buff_bar: VSBuffBar
var xp_bar: TextureProgressBar
var xp_label: Label
var timer_label: Label
var kills_label: Label
var mute_label: Label
var boss_bar: TextureProgressBar
var boss_label: Label
var hp_full_w := 250.0
var xp_full_w := 720.0
var boss_full_w := 520.0

var overlay_menu: Control
var overlay_options: Control
var overlay_scores: Control
var overlay_select: Control
var overlay_levelup: Control
var overlay_gameover: Control
var overlay_pause: Control
var overlay_intro: Control
var overlay_bossintro: Control
var bi_name: Label
var bi_line: Label
var bi_portrait: TextureRect
var cards_box: HBoxContainer
var go_box: VBoxContainer
var sfx_pct: Label
var music_pct: Label
var last_won := false

# Cinématique d'intro
var intro_slides: Array = []
var intro_idx := 0
var intro_t := 0.0
var intro_to_menu := false
var intro_box: VBoxContainer
const INTRO_SLIDE_TIME := 5.2

# ============================================================
func build() -> void:
	font_title = load("res://assets/ui/mmo/font_title.ttf")
	font_text = load("res://assets/ui/mmo/font_text.ttf")
	_build_menu_bg()
	_build_bars()
	_build_menu()
	_build_options()
	_build_scores()
	_build_select()
	_build_levelup()
	_build_gameover()
	_build_pause()
	_build_intro()
	_build_bossintro()
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

	# XP (haut centré) — barre à pointes de flèche (RPG UI Elements)
	xp_bar = _tex_bar("res://assets/ui/rpg/xp_frame.png", "res://assets/ui/rpg/xp_fill.png", Color(0.55, 0.95, 0.55))
	xp_bar.stretch_margin_left = 44
	xp_bar.stretch_margin_right = 44
	xp_bar.stretch_margin_top = 28
	xp_bar.stretch_margin_bottom = 28
	_anchor(xp_bar, 0.5, 0.0, 0.5, 0.0, -xp_full_w / 2.0, 2.0, xp_full_w / 2.0, 54.0)
	bars.add_child(xp_bar)
	xp_label = _label("Niv. 1", 14, CREAM)
	_anchor(xp_label, 0.5, 0.0, 0.5, 0.0, -60.0, 16.0, 60.0, 38.0)
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

	# La vie est affichée dans le GLOBE de la barre d'action (voir Wheel).
	mute_label = _label("Muet", 14, LILAC)
	_anchor(mute_label, 1.0, 0.0, 1.0, 0.0, -110.0, 12.0, -12.0, 34.0)
	mute_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	mute_label.visible = false
	bars.add_child(mute_label)

	# Barre de vie du boss (haut, sous le chrono) — bannière ornée violette
	boss_bar = _tex_bar("res://assets/ui/rpg/boss_frame.png", "res://assets/ui/rpg/boss_fill.png", Color(0.82, 0.42, 1.0))
	boss_bar.stretch_margin_left = 58
	boss_bar.stretch_margin_right = 58
	boss_bar.stretch_margin_top = 34
	boss_bar.stretch_margin_bottom = 34
	_anchor(boss_bar, 0.5, 0.0, 0.5, 0.0, -boss_full_w / 2.0 - 20.0, 70.0, boss_full_w / 2.0 + 20.0, 128.0)
	boss_bar.visible = false
	bars.add_child(boss_bar)
	boss_label = _label("", 12, Color(1, 1, 1))
	_anchor(boss_label, 0.5, 0.0, 0.5, 0.0, -boss_full_w / 2.0, 89.0, boss_full_w / 2.0, 109.0)
	boss_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_label.visible = false
	bars.add_child(boss_label)

	# Roue de sorts (bas-gauche)
	wheel = VSWheel.new()
	wheel.anchor_right = 1.0
	wheel.anchor_bottom = 1.0
	wheel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(wheel)

	# Marques de buff (haut-droite)
	buff_bar = VSBuffBar.new()
	buff_bar.anchor_right = 1.0
	buff_bar.anchor_bottom = 1.0
	buff_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bars.add_child(buff_bar)

func set_buffs(b: Array) -> void:
	if buff_bar:
		buff_bar.set_buffs(b)

func _build_menu() -> void:
	overlay_menu = _overlay(false)
	var p := _panel(600, 560)
	overlay_menu.add_child(p)
	var v := _vbox(p)
	v.add_child(_title("CRÉPUSCULE"))
	v.add_child(_divider())
	v.add_child(_label("Atteins le niveau 99 et vaincs le Seigneur du Crépuscule.", 16, CREAM, true))
	v.add_child(_spacer(6))
	var b1 := _button("NOUVELLE PARTIE")
	b1.pressed.connect(func(): play_pressed.emit())
	v.add_child(b1)
	var b2 := _button("HISTOIRE")
	b2.pressed.connect(func(): history_pressed.emit())
	v.add_child(b2)
	var b3 := _button("OPTIONS")
	b3.pressed.connect(func(): show_options())
	v.add_child(b3)
	var b4 := _button("SCORES")
	b4.pressed.connect(func(): show_scoreboard())
	v.add_child(b4)
	var b5 := _button("QUITTER")
	b5.pressed.connect(func(): get_tree().quit())
	v.add_child(b5)
	v.add_child(_spacer(2))
	v.add_child(_label("WASD/ZQSD/flèches ou manette  ·  Sorts : 1-5  ·  Ultime : 6/Espace  ·  Pause : P  ·  Son : M", 12, LILAC, true))
	add_child(overlay_menu)
	overlay_menu.visible = false

func _build_options() -> void:
	overlay_options = _overlay(false)
	var p := _panel(560, 380)
	overlay_options.add_child(p)
	var v := _vbox(p)
	v.add_child(_title2("OPTIONS"))
	v.add_child(_spacer(6))
	sfx_pct = _label("Effets : 85%", 16, CREAM, true)
	v.add_child(sfx_pct)
	var ss := _slider(0.85)
	ss.value_changed.connect(func(val):
		sfx_pct.text = "Effets : %d%%" % int(round(val * 100))
		sfx_changed.emit(val))
	v.add_child(ss)
	v.add_child(_spacer(8))
	music_pct = _label("Musique : 50%", 16, CREAM, true)
	v.add_child(music_pct)
	var ms := _slider(0.5)
	ms.value_changed.connect(func(val):
		music_pct.text = "Musique : %d%%" % int(round(val * 100))
		music_changed.emit(val))
	v.add_child(ms)
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

func _build_select() -> void:
	overlay_select = _overlay(false)
	var p := _panel(1240, 660)
	overlay_select.add_child(p)
	var v := _vbox(p)
	v.name = "box"
	add_child(overlay_select)
	overlay_select.visible = false

func _build_levelup() -> void:
	overlay_levelup = _overlay(true)
	var p := _panel(760, 430)
	overlay_levelup.add_child(p)
	var v := _vbox(p)
	v.add_child(_paper_title("NIVEAU SUPÉRIEUR !", 500.0, 58.0, 26))
	v.add_child(_label("Choisis une amélioration", 16, CREAM, true))
	v.add_child(_spacer(6))
	cards_box = HBoxContainer.new()
	cards_box.alignment = BoxContainer.ALIGNMENT_CENTER
	cards_box.add_theme_constant_override("separation", 18)
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

# ----- Cinématique d'introduction -----
func _build_intro() -> void:
	overlay_intro = _full_control()
	overlay_intro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var black := ColorRect.new()
	black.color = Color(0.02, 0.015, 0.04, 1.0)
	black.anchor_right = 1.0
	black.anchor_bottom = 1.0
	black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay_intro.add_child(black)
	intro_box = VBoxContainer.new()
	intro_box.anchor_right = 1.0
	intro_box.anchor_bottom = 1.0
	intro_box.offset_left = 80
	intro_box.offset_top = 60
	intro_box.offset_right = -80
	intro_box.offset_bottom = -80
	intro_box.alignment = BoxContainer.ALIGNMENT_CENTER
	intro_box.add_theme_constant_override("separation", 22)
	intro_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay_intro.add_child(intro_box)
	var hint := _label("clic / touche : suite", 13, LILAC)
	_anchor(hint, 0.0, 1.0, 0.0, 1.0, 24.0, -44.0, 320.0, -18.0)
	overlay_intro.add_child(hint)
	var skip := _button("PASSER  ▶")
	skip.custom_minimum_size = Vector2(170, 44)
	_anchor(skip, 1.0, 1.0, 1.0, 1.0, -200.0, -66.0, -24.0, -22.0)
	skip.pressed.connect(func(): _end_intro())
	overlay_intro.add_child(skip)
	add_child(overlay_intro)
	overlay_intro.visible = false

func show_intro(slides: Array, to_menu: bool) -> void:
	hide_overlays()
	bars.visible = false
	wheel.visible = false
	intro_slides = slides
	intro_to_menu = to_menu
	intro_idx = 0
	intro_t = 0.0
	_show_slide(0)
	overlay_intro.visible = true

func intro_active() -> bool:
	return overlay_intro != null and overlay_intro.visible

func intro_next() -> void:
	intro_idx += 1
	intro_t = 0.0
	if intro_idx >= intro_slides.size():
		_end_intro()
	else:
		_show_slide(intro_idx)

func _end_intro() -> void:
	overlay_intro.visible = false
	intro_done.emit(intro_to_menu)

# ----- Intro cinématique du BOSS FINAL -----
func _build_bossintro() -> void:
	overlay_bossintro = _full_control()
	overlay_bossintro.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.0, 0.05, 0.62)
	dim.anchor_right = 1.0
	dim.anchor_bottom = 1.0
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay_bossintro.add_child(dim)
	# bandes cinéma (haut / bas)
	var topbar := ColorRect.new()
	topbar.color = Color(0, 0, 0, 0.92)
	_anchor(topbar, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 74.0)
	overlay_bossintro.add_child(topbar)
	var botbar := ColorRect.new()
	botbar.color = Color(0, 0, 0, 0.92)
	_anchor(botbar, 0.0, 1.0, 1.0, 1.0, 0.0, -74.0, 0.0, 0.0)
	overlay_bossintro.add_child(botbar)
	# bande centrale rougeoyante
	var band := ColorRect.new()
	band.color = Color(0.12, 0.01, 0.10, 0.70)
	_anchor(band, 0.0, 0.5, 1.0, 0.5, 0.0, -150.0, 0.0, 150.0)
	band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay_bossintro.add_child(band)
	# contenu : portrait + nom + réplique
	var hb := HBoxContainer.new()
	_anchor(hb, 0.5, 0.5, 0.5, 0.5, -520.0, -140.0, 520.0, 140.0)
	hb.alignment = BoxContainer.ALIGNMENT_CENTER
	hb.add_theme_constant_override("separation", 28)
	hb.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay_bossintro.add_child(hb)
	bi_portrait = TextureRect.new()
	bi_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bi_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	bi_portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	bi_portrait.custom_minimum_size = Vector2(210, 210)
	bi_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hb.add_child(bi_portrait)
	var tv := VBoxContainer.new()
	tv.alignment = BoxContainer.ALIGNMENT_CENTER
	tv.add_theme_constant_override("separation", 12)
	tv.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hb.add_child(tv)
	bi_name = _label("", 40, Color(1.0, 0.28, 0.42), false)
	if font_title:
		bi_name.add_theme_font_override("font", font_title)
	bi_name.add_theme_color_override("font_shadow_color", Color(0.3, 0.0, 0.1))
	bi_name.add_theme_constant_override("shadow_offset_x", 2)
	bi_name.add_theme_constant_override("shadow_offset_y", 2)
	tv.add_child(bi_name)
	bi_line = _label("", 20, Color(0.95, 0.88, 0.82), false)
	bi_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bi_line.custom_minimum_size = Vector2(660, 0)
	tv.add_child(bi_line)
	var hint := _label("clic / touche : engager le combat", 14, LILAC, true)
	_anchor(hint, 0.5, 1.0, 0.5, 1.0, -200.0, -52.0, 200.0, -28.0)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay_bossintro.add_child(hint)
	add_child(overlay_bossintro)
	overlay_bossintro.visible = false

func show_boss_intro(boss_name: String, line: String, portrait: Texture2D) -> void:
	bi_name.text = "☠  " + boss_name + "  ☠"
	bi_line.text = "« " + line + " »"
	bi_portrait.texture = portrait
	overlay_bossintro.visible = true
	overlay_bossintro.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(overlay_bossintro, "modulate:a", 1.0, 0.35)

func hide_boss_intro() -> void:
	overlay_bossintro.visible = false

func _show_slide(i: int) -> void:
	for c in intro_box.get_children():
		c.queue_free()
	var slide: Dictionary = intro_slides[i]
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 30)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var h: float = slide.get("h", 160.0)
	for tex in slide.get("texs", []):
		if tex == null:
			continue
		var tr := TextureRect.new()
		tr.texture = tex
		tr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		var aspect := float(tex.get_width()) / float(maxf(1.0, tex.get_height()))
		tr.custom_minimum_size = Vector2(h * aspect, h)
		tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(tr)
	intro_box.add_child(row)
	intro_box.add_child(_spacer(4))
	var t := _label(str(slide.get("title", "")), 34, GOLD, true)
	t.add_theme_color_override("font_shadow_color", Color(0.48, 0.29, 0.08))
	t.add_theme_constant_override("shadow_offset_x", 2)
	t.add_theme_constant_override("shadow_offset_y", 2)
	intro_box.add_child(t)
	var sub := _label(str(slide.get("sub", "")), 17, CREAM, true)
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sub.custom_minimum_size = Vector2(760, 0)
	sub.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	intro_box.add_child(sub)
	var dots := ""
	for k in intro_slides.size():
		dots += "●" if k == i else "○"
		if k < intro_slides.size() - 1:
			dots += "  "
	intro_box.add_child(_spacer(2))
	intro_box.add_child(_label(dots, 14, LILAC, true))
	intro_box.modulate.a = 0.0

func _process(delta: float) -> void:
	if not intro_active():
		return
	intro_t += delta
	# fondu d'entrée / de sortie du tableau
	var a := 1.0
	if intro_t < 0.5:
		a = intro_t / 0.5
	elif intro_t > INTRO_SLIDE_TIME - 0.5:
		a = maxf(0.0, (INTRO_SLIDE_TIME - intro_t) / 0.5)
	intro_box.modulate.a = a
	if intro_t >= INTRO_SLIDE_TIME:
		intro_next()

# ----- API jeu -----
func set_xp(pct: float, level: int) -> void:
	xp_bar.value = clampf(pct, 0.0, 1.0)
	xp_label.text = "Niv. %d" % level

func set_hp(_hp: float, _maxhp: float) -> void:
	# La vie est affichée par le globe de la barre d'action (Wheel). Rien à faire ici.
	pass

func set_time(t: String) -> void:
	timer_label.text = t

func set_kills(k: int) -> void:
	kills_label.text = "Tués %d" % k

func set_muted(m: bool) -> void:
	mute_label.visible = m

# Barre du boss : frac < 0 = cachée.
func set_boss(frac: float, boss_name: String) -> void:
	var show := frac >= 0.0
	boss_bar.visible = show
	boss_label.visible = show
	if show:
		boss_bar.value = clampf(frac, 0.0, 1.0)
		boss_label.text = boss_name

# Barre "flèche" du pack RPG UI Elements (cadre + remplissage alignés)
func _arrow_bar(tint: Color) -> TextureProgressBar:
	var b := _tex_bar("res://assets/ui/rpg/arrow_frame.png", "res://assets/ui/rpg/arrow_fill.png", tint)
	b.stretch_margin_left = 44
	b.stretch_margin_right = 44
	b.stretch_margin_top = 26
	b.stretch_margin_bottom = 26
	return b

# Barre texturée MMO (fond + remplissage nine-patch)
func _tex_bar(bg_path: String, fill_path: String, tint: Color) -> TextureProgressBar:
	var b := TextureProgressBar.new()
	b.texture_under = load(bg_path)
	b.texture_progress = load(fill_path)
	b.nine_patch_stretch = true
	b.stretch_margin_left = 12
	b.stretch_margin_right = 12
	b.stretch_margin_top = 6
	b.stretch_margin_bottom = 6
	b.min_value = 0.0
	b.max_value = 1.0
	b.value = 1.0
	b.tint_progress = tint
	b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return b

func show_hud(b: bool) -> void:
	bars.visible = b
	wheel.visible = b

func hide_overlays() -> void:
	menu_bg.visible = false
	overlay_menu.visible = false
	overlay_options.visible = false
	overlay_scores.visible = false
	overlay_select.visible = false
	overlay_levelup.visible = false
	overlay_gameover.visible = false
	overlay_pause.visible = false
	overlay_intro.visible = false
	overlay_bossintro.visible = false

func show_menu() -> void:
	hide_overlays()
	bars.visible = false
	wheel.visible = false
	menu_bg.visible = true
	overlay_menu.visible = true
	_focus_first_button(overlay_menu)

func show_options() -> void:
	hide_overlays()
	menu_bg.visible = true
	overlay_options.visible = true
	_focus_first_button(overlay_options)

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
	back.grab_focus()

func _scores_box() -> VBoxContainer:
	# le VBox a été ajouté au Panel dans _build_scores ; on le retrouve
	for c in overlay_scores.get_children():
		if c is Panel:
			for cc in c.get_children():
				if cc is VBoxContainer:
					return cc
	return null

# ----- Sélection du héros -----
func show_select(heroes: Array) -> void:
	hide_overlays()
	bars.visible = false
	wheel.visible = false
	menu_bg.visible = true
	var box := _select_box()
	if box == null:
		return
	for c in box.get_children():
		c.queue_free()
	box.add_child(_title2("CHOISIS TON HÉROS"))
	box.add_child(_divider())
	box.add_child(_spacer(4))
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	for h in heroes:
		row.add_child(_hero_card(h))
	box.add_child(row)
	box.add_child(_spacer(8))
	var back := _button("RETOUR")
	back.custom_minimum_size = Vector2(220, 44)
	back.pressed.connect(func(): show_menu())
	box.add_child(back)
	overlay_select.visible = true
	_focus_first_button(box)   # 1er "CHOISIR" (navigation manette)

func _select_box() -> VBoxContainer:
	for c in overlay_select.get_children():
		if c is Panel:
			for cc in c.get_children():
				if cc is VBoxContainer:
					return cc
	return null

func _hero_card(h: Dictionary) -> Control:
	var card := _card_panel()
	var v := VBoxContainer.new()
	v.anchor_right = 1.0
	v.anchor_bottom = 1.0
	v.offset_left = 12
	v.offset_top = 12
	v.offset_right = -12
	v.offset_bottom = -12
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override("separation", 6)
	card.add_child(v)
	# portrait animé (1re frame d'idle)
	var tex: Texture2D = h.get("tex", null)
	if tex != null:
		var tr := TextureRect.new()
		tr.texture = tex
		tr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tr.custom_minimum_size = Vector2(0, 100)
		tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		v.add_child(tr)
	v.add_child(_label(str(h.get("name", "?")), 18, GOLD, true))
	var style_lbl := _label(str(h.get("style", "")), 12, LILAC, true)
	style_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	style_lbl.custom_minimum_size = Vector2(192, 0)
	v.add_child(style_lbl)
	v.add_child(_spacer(2))
	v.add_child(_label("Capacités", 12, GOLD, true))
	var skills_lbl := _label(str(h.get("skills", "")), 12, CREAM, true)
	skills_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	skills_lbl.custom_minimum_size = Vector2(192, 0)
	v.add_child(skills_lbl)
	v.add_child(_spacer(2))
	var ult_lbl := _label("Ultime : %s" % str(h.get("ult", "")), 13, Color(1.0, 0.82, 0.32), true)
	ult_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ult_lbl.custom_minimum_size = Vector2(192, 0)
	v.add_child(ult_lbl)
	v.add_child(_spacer(4))
	var pick := _button("CHOISIR")
	pick.custom_minimum_size = Vector2(170, 40)
	var hid := str(h.get("id", ""))
	pick.pressed.connect(func(): hero_selected.emit(hid))
	v.add_child(pick)
	return card

func _card_panel() -> Panel:
	var p := Panel.new()
	p.custom_minimum_size = Vector2(224, 442)
	var sb := StyleBoxTexture.new()
	sb.texture = load("res://assets/ui/rpg/panel.png")
	sb.texture_margin_left = 16
	sb.texture_margin_right = 16
	sb.texture_margin_top = 16
	sb.texture_margin_bottom = 16
	sb.modulate_color = Color(1.1, 1.05, 1.2, 0.99)
	sb.set_content_margin_all(6)
	p.add_theme_stylebox_override("panel", sb)
	return p

func show_levelup(choices: Array) -> void:
	for c in cards_box.get_children():
		c.queue_free()
	for choice in choices:
		cards_box.add_child(_levelup_card(choice))
	overlay_levelup.visible = true
	_focus_first_button(cards_box)   # 1re carte (navigation manette)

# Carte de niveau : plaque cliquable avec icône + nom + description.
func _levelup_card(choice: Dictionary) -> Control:
	var b := _button("")
	b.custom_minimum_size = Vector2(210, 224)
	var kind: String = choice.get("kind", "")
	var accent := GOLD
	if kind == "off":
		accent = Color(1.0, 0.55, 0.45)
	elif kind == "def":
		accent = Color(0.55, 0.8, 1.0)
	var v := VBoxContainer.new()
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.anchor_right = 1.0
	v.anchor_bottom = 1.0
	v.offset_left = 12
	v.offset_top = 14
	v.offset_right = -12
	v.offset_bottom = -14
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override("separation", 8)
	var tr := TextureRect.new()
	tr.texture = load("res://assets/ui/upgrades/%s.png" % choice.get("icon", "dmg"))
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tr.custom_minimum_size = Vector2(0, 88)
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(tr)
	v.add_child(_label(str(choice["name"]), 18, accent, true))
	var d := _label(str(choice["desc"]), 13, CREAM, true)
	d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	d.custom_minimum_size = Vector2(180, 0)
	v.add_child(d)
	b.add_child(v)
	var uid: String = choice["id"]
	b.pressed.connect(func(): upgrade_chosen.emit(uid))
	return b

# Écran de fin : phase 1 = saisie du nom (défaite… ou victoire !)
func show_gameover_entry(time_str: String, level: int, kills: int, score: int, last_name: String, won: bool = false) -> void:
	last_won = won
	hide_overlays()
	menu_bg.visible = true
	for c in go_box.get_children():
		c.queue_free()
	if won:
		go_box.add_child(_paper_title("★  VICTOIRE  ★"))
		go_box.add_child(_label("Le Seigneur du Crépuscule est vaincu. La forêt respire à nouveau.", 14, GOLD, true))
	else:
		go_box.add_child(_paper_title("TU ES TOMBÉ"))
	go_box.add_child(_label("Temps %s   ·   Niveau %d   ·   %d tués" % [time_str, level, kills], 14, CREAM, true))
	# Rang gagné (emblème Fantasy Ranks)
	var ridx := VSScores.rank_for(score)
	var rrow := HBoxContainer.new()
	rrow.alignment = BoxContainer.ALIGNMENT_CENTER
	rrow.add_theme_constant_override("separation", 14)
	var remb := TextureRect.new()
	remb.texture = VSScores.rank_icon(ridx)
	remb.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	remb.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	remb.custom_minimum_size = Vector2(120, 61)
	rrow.add_child(remb)
	var rv := VBoxContainer.new()
	rv.alignment = BoxContainer.ALIGNMENT_CENTER
	rv.add_child(_label("Score : %d" % score, 20, GOLD))
	rv.add_child(_label("Rang : %s" % VSScores.rank_name(ridx), 16, CREAM))
	rrow.add_child(rv)
	go_box.add_child(rrow)
	go_box.add_child(_spacer(4))
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 10)
	var edit := LineEdit.new()
	edit.text = last_name
	edit.max_length = 14
	edit.custom_minimum_size = Vector2(230, 42)
	edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	edit.placeholder_text = "Ton nom"
	if font_text:
		edit.add_theme_font_override("font", font_text)
	var ebox := StyleBoxTexture.new()
	ebox.texture = load("res://assets/ui/rpg/panel.png")
	ebox.texture_margin_left = 16
	ebox.texture_margin_right = 16
	ebox.texture_margin_top = 16
	ebox.texture_margin_bottom = 16
	ebox.modulate_color = Color(0.7, 0.62, 0.55)
	ebox.set_content_margin_all(8)
	var efocus: StyleBoxTexture = ebox.duplicate()
	efocus.modulate_color = Color(1.0, 0.88, 0.6)
	edit.add_theme_stylebox_override("normal", ebox)
	edit.add_theme_stylebox_override("focus", efocus)
	edit.add_theme_color_override("font_color", CREAM)
	edit.add_theme_color_override("caret_color", GOLD)
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
	go_box.add_child(_paper_title("★  VICTOIRE  ★" if last_won else "TU ES TOMBÉ", 480.0, 58.0, 26))
	go_box.add_child(_label("Score : %d (%s) — enregistré !" % [score, VSScores.rank_name(VSScores.rank_for(score))], 17, GOLD, true))
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
	r.grab_focus()   # REJOUER par défaut (manette)

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
		var sc := int(e.get("score", 0))
		var ridx := int(e.get("rank", VSScores.rank_for(sc)))
		var row := HBoxContainer.new()
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		row.add_theme_constant_override("separation", 10)
		var ric := TextureRect.new()
		ric.texture = VSScores.rank_icon(ridx)
		ric.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		ric.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		ric.custom_minimum_size = Vector2(44, 22)
		ric.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(ric)
		var txt := "%2d.  %-14s %6d   %s · Niv %d · %d tués · %s" % [
			i + 1, str(e.get("name", "?")), sc,
			str(e.get("time", "00:00")), int(e.get("level", 1)), int(e.get("kills", 0)),
			VSScores.rank_name(ridx)]
		var col := GOLD if i == highlight else CREAM
		row.add_child(_label(txt, 14, col))
		parent.add_child(row)

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
	# Panneau sombre du pack RPG UI Elements (nine-patch)
	var p := Panel.new()
	_anchor(p, 0.5, 0.5, 0.5, 0.5, -w / 2.0, -h / 2.0, w / 2.0, h / 2.0)
	var sb := StyleBoxTexture.new()
	sb.texture = load("res://assets/ui/rpg/panel.png")
	sb.texture_margin_left = 16
	sb.texture_margin_right = 16
	sb.texture_margin_top = 16
	sb.texture_margin_bottom = 16
	sb.modulate_color = Color(1.0, 1.0, 1.0, 0.99)
	sb.set_content_margin_all(26)
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
	var l := _label(text, 54, GOLD, true)
	if font_title:
		l.add_theme_font_override("font", font_title)
	l.add_theme_color_override("font_shadow_color", Color(0.48, 0.29, 0.08))
	l.add_theme_constant_override("shadow_offset_x", 3)
	l.add_theme_constant_override("shadow_offset_y", 3)
	return l

func _title2(text: String) -> Label:
	var l := _label(text, 34, GOLD, true)
	if font_title:
		l.add_theme_font_override("font", font_title)
	l.add_theme_color_override("font_shadow_color", Color(0.48, 0.29, 0.08))
	l.add_theme_constant_override("shadow_offset_x", 2)
	l.add_theme_constant_override("shadow_offset_y", 2)
	return l

func _spacer(h: int) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(0, h)
	return c

# Titre sur bannière parchemin (RPG UI Elements)
func _paper_title(text: String, w: float = 520.0, h: float = 64.0, fsize: int = 30) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(w, h)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tr := TextureRect.new()
	tr.texture = load("res://assets/ui/rpg/paper.png")
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_SCALE
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_anchor(tr, 0.5, 0.0, 0.5, 0.0, -w / 2.0, 0.0, w / 2.0, h)
	c.add_child(tr)
	var l := _label(text, fsize, Color(0.30, 0.20, 0.10), true)
	if font_title:
		l.add_theme_font_override("font", font_title)
	_anchor(l, 0.5, 0.0, 0.5, 0.0, -w / 2.0, 0.0, w / 2.0, h)
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	c.add_child(l)
	c.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	return c

# Séparateur décoratif Kenney (teinté or), centré sous les titres
func _divider() -> TextureRect:
	var d := TextureRect.new()
	d.texture = load("res://assets/ui/divider.png")
	d.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	d.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	d.custom_minimum_size = Vector2(0, 30)
	d.self_modulate = Color(1.0, 0.84, 0.46)
	d.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return d

func _label(text: String, size: int, color: Color, center: bool = false) -> Label:
	var l := Label.new()
	l.text = text
	if font_text:
		l.add_theme_font_override("font", font_text)
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
	s.custom_minimum_size = Vector2(340, 30)
	s.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	# habillage RPG UI : piste en flèche + zone parcourue dorée + poignée diamant
	var track := StyleBoxTexture.new()
	track.texture = load("res://assets/ui/rpg/slider_frame.png")
	track.texture_margin_left = 44
	track.texture_margin_right = 44
	track.texture_margin_top = 18
	track.texture_margin_bottom = 18
	track.content_margin_top = 9.0
	track.content_margin_bottom = 9.0
	s.add_theme_stylebox_override("slider", track)
	var area := StyleBoxTexture.new()
	area.texture = load("res://assets/ui/rpg/arrow_fill.png")
	area.texture_margin_left = 44
	area.texture_margin_right = 44
	area.texture_margin_top = 16
	area.texture_margin_bottom = 16
	area.modulate_color = Color(1.0, 0.84, 0.42)
	s.add_theme_stylebox_override("grabber_area", area)
	s.add_theme_stylebox_override("grabber_area_highlight", area)
	var hnd: Texture2D = load("res://assets/ui/rpg/handle.png")
	s.add_theme_icon_override("grabber", hnd)
	s.add_theme_icon_override("grabber_highlight", hnd)
	s.add_theme_icon_override("grabber_disabled", hnd)
	return s

func _button(text: String) -> Button:
	var b := Button.new()
	b.text = text
	b.add_theme_font_override("font", font_title)
	b.add_theme_font_size_override("font_size", 20)
	b.custom_minimum_size = Vector2(300, 52)
	# plaque sombre à bordure dorée (pack RPG UI Elements)
	var tex: Texture2D = load("res://assets/ui/rpg/panel.png")
	var normal := _btn_box(tex, Color(0.62, 0.55, 0.50))
	var hover := _btn_box(tex, Color(1.05, 0.9, 0.6))
	var pressed := _btn_box(tex, Color(0.42, 0.37, 0.34))
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("hover", hover)
	b.add_theme_stylebox_override("pressed", pressed)
	b.add_theme_stylebox_override("focus", hover)   # focus manette = surbrillance dorée
	b.add_theme_color_override("font_color", GOLD)
	b.add_theme_color_override("font_hover_color", Color(1, 0.97, 0.85))
	b.add_theme_color_override("font_focus_color", Color(1, 0.97, 0.85))
	b.add_theme_color_override("font_pressed_color", Color(0.8, 0.7, 0.45))
	return b

# Donne le focus au premier bouton (navigation manette).
func _focus_first_button(root: Node) -> void:
	var b := _find_button(root)
	if b:
		b.grab_focus()

func _find_button(n: Node) -> Button:
	for c in n.get_children():
		if c is Button and (c as Control).visible:
			return c
		var r := _find_button(c)
		if r:
			return r
	return null

func _btn_box(tex: Texture2D, mod: Color) -> StyleBoxTexture:
	var sb := StyleBoxTexture.new()
	sb.texture = tex
	sb.texture_margin_left = 16
	sb.texture_margin_right = 16
	sb.texture_margin_top = 16
	sb.texture_margin_bottom = 16
	sb.modulate_color = mod
	sb.content_margin_left = 14.0
	sb.content_margin_right = 14.0
	sb.content_margin_top = 8.0
	sb.content_margin_bottom = 8.0
	return sb

func _anchor(c: Control, al: float, at: float, ar: float, ab: float, ol: float, ot: float, orr: float, ob: float) -> void:
	c.anchor_left = al
	c.anchor_top = at
	c.anchor_right = ar
	c.anchor_bottom = ab
	c.offset_left = ol
	c.offset_top = ot
	c.offset_right = orr
	c.offset_bottom = ob
