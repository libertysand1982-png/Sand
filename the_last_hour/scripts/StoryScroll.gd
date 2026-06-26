# StoryScroll.gd — intro cinématique pixel 2D + défilement Star Wars.
# Phase 1 : Cinématique (8 scènes animées avec sous-titres)
# Phase 2 : Texte défilant Star Wars
# Escape pour skipper à tout moment.
extends Node2D

const W := 1280.0
const H := 720.0

# Sprite scale (pixel art look)
const SP_HERO   := 52.0 / 64.0
const SP_SMALL  := 30.0 / 64.0  # petit frère
const SP_MONSTER:= 48.0 / 64.0

enum Phase { CINEMATIC, CRAWL, FADE_OUT, DONE }
var _phase: Phase = Phase.CINEMATIC

# Cinematic state
var _scene_idx   := 0
var _scene_t     := 0.0
const SCENES: Array[Dictionary] = []  # built at runtime

# Scene nodes
var _bg:          ColorRect
var _letters_root:Node2D    # letterbox bars
var _scene_root:  Node2D    # scene content
var _sub_lbl:     Label     # subtitle
var _skip_lbl:    Label

# Crawl state
var _crawl_root:  Node2D
var _crawl_y:     float = H + 20.0
const CRAWL_SPEED := 60.0

# Fade overlay
var _fade_rect:   ColorRect

var _sprites := {}  # loaded textures

const STORY_LINES := [
"",
"",
"Dans les terres oubliées du royaume...",
"",
"Deux frères, fils d'un forgeron mort",
"au combat, vivaient seuls dans une ferme.",
"",
"",
"Cette nuit-là, des bruits étranges",
"s'élevèrent de la grange.",
"",
"",
"L'aîné inspecta l'aile est.",
"Son frère cadet, l'aile ouest.",
"",
"",
"Des créatures surgirent de l'obscurité.",
"",
"",
"L'aîné fut assommé d'un coup brutal.",
"",
"",
"Quand il reprit connaissance,",
"la grange était vide.",
"Son frère... avait disparu.",
"",
"",
"Il rentra dans la maison.",
"Saisit l'épée rouillée de son père.",
"La seule chose qu'il lui restait.",
"",
"",
"Il ne savait pas où aller.",
"Mais il savait combien de temps il avait.",
"",
"",
"UNE HEURE.",
"",
"Pas une seconde de plus.",
"",
"",
"Car dans une heure,",
"son frère sera exécuté",
"lors d'un rituel ancien et sombre.",
"",
"",
"",
"",
"T H E   L A S T   H O U R",
"",
"",
]

func _ready() -> void:
	_load_sprites()
	_build_base()
	_build_cinematic()
	_build_crawl()
	_build_fade()

# ── Assets ─────────────────────────────────────────────────────────────────────

# hframes per sprite key (spritesheets show only frame 0)
const SPRITE_HFRAMES := { "hero": 8, "bandit": 10, "gobelin": 9 }

func _load_sprites() -> void:
	_sprites["hero"]    = load("res://assets/characters/hero.png")
	_sprites["bandit"]  = load("res://assets/characters/bandit.png")
	_sprites["gobelin"] = load("res://assets/characters/gobelin.png")

# ── Base layout ────────────────────────────────────────────────────────────────

func _build_base() -> void:
	_bg = ColorRect.new()
	_bg.size = Vector2(W, H)
	_bg.color = Color(0.02, 0.01, 0.01)
	add_child(_bg)

	# Cinematic letterbox bars
	_letters_root = Node2D.new()
	_letters_root.z_index = 30
	add_child(_letters_root)
	var bar_h := 88.0
	for i in 2:
		var bar := ColorRect.new()
		bar.size = Vector2(W, bar_h)
		bar.position = Vector2(0, i * (H - bar_h))
		bar.color = Color(0, 0, 0, 1)
		_letters_root.add_child(bar)

	# Subtitle
	_sub_lbl = Label.new()
	_sub_lbl.add_theme_font_size_override("font_size", 20)
	_sub_lbl.add_theme_color_override("font_color", Color(0.88, 0.84, 0.78))
	_sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_sub_lbl.position = Vector2(160, H - 70)
	_sub_lbl.size = Vector2(960, 36)
	_sub_lbl.z_index = 31
	add_child(_sub_lbl)

	# Skip hint
	_skip_lbl = Label.new()
	_skip_lbl.text = "[Échap] Passer"
	_skip_lbl.add_theme_font_size_override("font_size", 13)
	_skip_lbl.add_theme_color_override("font_color", Color(0.4, 0.35, 0.3))
	_skip_lbl.position = Vector2(W - 170, H - 30)
	_skip_lbl.z_index = 32
	add_child(_skip_lbl)

	_scene_root = Node2D.new()
	_scene_root.z_index = 10
	add_child(_scene_root)

# ── Cinematic scenes ───────────────────────────────────────────────────────────

func _build_cinematic() -> void:
	# Build all scene nodes upfront (hidden), revealed per scene
	_scene_idx = 0
	_scene_t   = 0.0
	_build_all_scenes()
	_show_scene(0)

func _build_all_scenes() -> void:
	# Each scene is a child of _scene_root, hidden by default
	_build_scene_farm_night()      # 0
	_build_scene_noise()           # 1
	_build_scene_split()           # 2
	_build_scene_attack()          # 3
	_build_scene_ko()              # 4
	_build_scene_abduction()       # 5
	_build_scene_awakening()       # 6
	_build_scene_sword()           # 7

func _show_scene(idx: int) -> void:
	for i in _scene_root.get_child_count():
		_scene_root.get_child(i).visible = (i == idx)
	var subs := [
		"La ferme des frères Aldric. Nuit calme.",
		"Des bruits dans la grange...",
		"« Toi à gauche. Moi à droite. »",
		"Une embuscade !",
		"L'aîné tombe, assommé.",
		"Le cadet est emporté dans l'obscurité.",
		"L'aîné se réveille. Seul. La grange, vide.",
		"L'épée de son père. La seule chose qui lui reste."
	]
	_sub_lbl.text = subs[idx] if idx < subs.size() else ""

# Scene 0: Farm at night
func _build_scene_farm_night() -> void:
	var root := _make_scene_root()
	# Night sky
	_add_bg(root, Color(0.04, 0.04, 0.12), Vector2.ZERO, Vector2(W, H))
	# Stars
	for i in 80:
		var star := ColorRect.new()
		star.size = Vector2(2, 2)
		star.position = Vector2(randf() * W, randf() * (H * 0.55))
		star.color = Color(0.9, 0.88, 0.95, randf_range(0.4, 0.9))
		root.add_child(star)
	# Moon
	var moon := ColorRect.new()
	moon.size = Vector2(40, 40)
	moon.position = Vector2(900, 80)
	moon.color = Color(0.88, 0.88, 0.80, 0.7)
	root.add_child(moon)
	# Ground
	_add_bg(root, Color(0.06, 0.08, 0.04), Vector2(0, H - 220), Vector2(W, 220))
	# Barn silhouette
	_add_bg(root, Color(0.10, 0.07, 0.05), Vector2(360, H - 320), Vector2(560, 320))
	_add_bg(root, Color(0.08, 0.055, 0.04), Vector2(340, H - 370), Vector2(600, 60))  # roof hint
	# Two sleeping heroes
	var hero1 := _make_sprite(root, "hero", SP_HERO, Vector2(510, H - 230))
	hero1.rotation_degrees = 90.0
	hero1.modulate = Color(0.7, 0.7, 0.75)
	var hero2 := _make_sprite(root, "hero", SP_SMALL, Vector2(600, H - 230))
	hero2.rotation_degrees = 90.0
	hero2.modulate = Color(0.65, 0.65, 0.7)
	# Z Z Z floating
	for i in 3:
		var z := Label.new()
		z.text = "z"
		z.add_theme_font_size_override("font_size", 14 + i * 4)
		z.add_theme_color_override("font_color", Color(0.7, 0.7, 0.9, 0.5 - i * 0.1))
		z.position = Vector2(490 + i * 20, H - 260 - i * 18)
		root.add_child(z)
		var t := create_tween().set_loops()
		t.tween_property(z, "position:y", z.position.y - 15, 1.5 + i * 0.3).set_ease(Tween.EASE_IN_OUT)
		t.tween_property(z, "position:y", z.position.y,      1.5 + i * 0.3).set_ease(Tween.EASE_IN_OUT)

# Scene 1: Noise in barn
func _build_scene_noise() -> void:
	var root := _make_scene_root()
	_add_bg(root, Color(0.04, 0.04, 0.12), Vector2.ZERO, Vector2(W, H))
	_add_bg(root, Color(0.06, 0.08, 0.04), Vector2(0, H - 220), Vector2(W, 220))
	_add_bg(root, Color(0.10, 0.07, 0.05), Vector2(360, H - 320), Vector2(560, 320))
	# Two heroes standing up, startled
	_make_sprite(root, "hero", SP_HERO,  Vector2(480, H - 230))
	_make_sprite(root, "hero", SP_SMALL, Vector2(620, H - 215))
	# Exclamation marks
	for pos in [Vector2(465, H - 310), Vector2(610, H - 295)]:
		var ex := Label.new()
		ex.text = "!"
		ex.add_theme_font_size_override("font_size", 36)
		ex.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
		ex.position = pos
		root.add_child(ex)
		var t := create_tween().set_loops()
		t.tween_property(ex, "scale", Vector2(1.3, 1.3), 0.3)
		t.tween_property(ex, "scale", Vector2(1.0, 1.0), 0.3)
	# Sound wave hint
	var noise := Label.new()
	noise.text = "~ ~ ~ ~"
	noise.add_theme_font_size_override("font_size", 22)
	noise.add_theme_color_override("font_color", Color(0.6, 0.5, 0.3, 0.7))
	noise.position = Vector2(400, H - 360)
	root.add_child(noise)

# Scene 2: Split — brothers go different ways
func _build_scene_split() -> void:
	var root := _make_scene_root()
	_add_bg(root, Color(0.04, 0.04, 0.10), Vector2.ZERO, Vector2(W, H))
	_add_bg(root, Color(0.08, 0.06, 0.04), Vector2(0, H - 180), Vector2(W, 180))
	# Barn background
	_add_bg(root, Color(0.09, 0.065, 0.045), Vector2(300, H - 340), Vector2(680, 340))
	# Dotted line down center
	for i in 8:
		var d := ColorRect.new()
		d.size = Vector2(3, 14)
		d.position = Vector2(W / 2.0 - 1.5, H - 340 + i * 30)
		d.color = Color(0.5, 0.4, 0.25, 0.5)
		root.add_child(d)
	# Hero (left)
	var h_big := _make_sprite(root, "hero", SP_HERO, Vector2(360, H - 230))
	h_big.scale.x = -abs(h_big.scale.x)  # face left (toward split)
	var t1 := create_tween()
	t1.tween_property(h_big, "position:x", 380.0, 1.5).set_ease(Tween.EASE_OUT)
	# Small brother (right)
	var h_small := _make_sprite(root, "hero", SP_SMALL, Vector2(880, H - 215))
	var t2 := create_tween()
	t2.tween_property(h_small, "position:x", 860.0, 1.5).set_ease(Tween.EASE_OUT)
	# Arrow indicators
	var arr_l := Label.new()
	arr_l.text = "←"
	arr_l.add_theme_font_size_override("font_size", 28)
	arr_l.add_theme_color_override("font_color", Color(0.7, 0.6, 0.35, 0.7))
	arr_l.position = Vector2(300, H - 270)
	root.add_child(arr_l)
	var arr_r := Label.new()
	arr_r.text = "→"
	arr_r.add_theme_font_size_override("font_size", 28)
	arr_r.add_theme_color_override("font_color", Color(0.7, 0.6, 0.35, 0.7))
	arr_r.position = Vector2(900, H - 255)
	root.add_child(arr_r)

# Scene 3: Monster attack flash
func _build_scene_attack() -> void:
	var root := _make_scene_root()
	_add_bg(root, Color(0.03, 0.02, 0.04), Vector2.ZERO, Vector2(W, H))
	_add_bg(root, Color(0.06, 0.04, 0.03), Vector2(0, H - 180), Vector2(W, 180))
	_add_bg(root, Color(0.08, 0.05, 0.03), Vector2(200, H - 320), Vector2(880, 320))
	# Monster rushing in
	var monster := _make_sprite(root, "gobelin", SP_MONSTER, Vector2(800, H - 240))
	monster.modulate = Color(0.6, 0.3, 0.25)
	var mt := create_tween()
	mt.tween_property(monster, "position:x", 580.0, 0.8).set_ease(Tween.EASE_IN)
	# Hero standing, about to be hit
	_make_sprite(root, "hero", SP_HERO, Vector2(440, H - 230))
	# Red slash effect
	var slash := ColorRect.new()
	slash.size = Vector2(160, 6)
	slash.position = Vector2(420, H - 260)
	slash.rotation_degrees = -35.0
	slash.color = Color(0.9, 0.1, 0.1, 0.0)
	root.add_child(slash)
	var st := create_tween()
	st.tween_interval(0.7)
	st.tween_property(slash, "color:a", 1.0, 0.05)
	st.tween_property(slash, "color:a", 0.0, 0.4)
	# Screen flash
	var flash := ColorRect.new()
	flash.size = Vector2(W, H)
	flash.color = Color(0.8, 0.1, 0.05, 0.0)
	flash.z_index = 5
	root.add_child(flash)
	var ft := create_tween()
	ft.tween_interval(0.75)
	ft.tween_property(flash, "color:a", 0.65, 0.05)
	ft.tween_property(flash, "color:a", 0.0,  0.5)
	# Question marks from small brother (offscreen right)
	var q := Label.new()
	q.text = "???"
	q.add_theme_font_size_override("font_size", 20)
	q.add_theme_color_override("font_color", Color(0.8, 0.7, 0.4, 0.7))
	q.position = Vector2(950, H - 260)
	root.add_child(q)

# Scene 4: Hero KO
func _build_scene_ko() -> void:
	var root := _make_scene_root()
	_add_bg(root, Color(0.025, 0.015, 0.015), Vector2.ZERO, Vector2(W, H))
	_add_bg(root, Color(0.055, 0.035, 0.025), Vector2(0, H - 180), Vector2(W, 180))
	# Hero fallen
	var hero := _make_sprite(root, "hero", SP_HERO, Vector2(500, H - 190))
	hero.rotation_degrees = 90.0
	hero.modulate = Color(0.6, 0.55, 0.65)
	# Stars around head (dizziness)
	for i in 5:
		var star := Label.new()
		star.text = "✦"
		star.add_theme_font_size_override("font_size", 14)
		star.add_theme_color_override("font_color", Color(0.9, 0.85, 0.3, 0.8))
		star.position = Vector2(475, H - 230)
		root.add_child(star)
		var ang := TAU / 5.0 * i
		var st := create_tween().set_loops()
		st.tween_property(star, "position", Vector2(475 + cos(ang) * 28, H - 230 + sin(ang) * 18), 1.2)
		st.tween_property(star, "position", Vector2(475 + cos(ang + 0.8) * 28, H - 230 + sin(ang + 0.8) * 18), 1.2)
	# Blood pool (dark)
	var blood := ColorRect.new()
	blood.size = Vector2(80, 12)
	blood.position = Vector2(460, H - 178)
	blood.color = Color(0.35, 0.04, 0.02, 0.7)
	root.add_child(blood)
	# Monster dragging away (small brother silhouette)
	var monster := _make_sprite(root, "gobelin", SP_MONSTER, Vector2(760, H - 230))
	monster.modulate = Color(0.4, 0.25, 0.2)
	var small := _make_sprite(root, "hero", SP_SMALL, Vector2(800, H - 210))
	small.modulate = Color(0.5, 0.5, 0.6)
	small.rotation_degrees = 45.0
	var mt := create_tween()
	mt.tween_property(monster, "position:x", 1400.0, 2.5).set_ease(Tween.EASE_IN)
	var st2 := create_tween()
	st2.tween_property(small, "position:x", 1450.0, 2.5).set_ease(Tween.EASE_IN)

# Scene 5: Abduction recap (monster walking away with brother)
func _build_scene_abduction() -> void:
	var root := _make_scene_root()
	# Night exterior
	_add_bg(root, Color(0.03, 0.03, 0.08), Vector2.ZERO, Vector2(W, H))
	_add_bg(root, Color(0.04, 0.06, 0.03), Vector2(0, H - 160), Vector2(W, 160))
	for i in 50:
		var star := ColorRect.new()
		star.size = Vector2(2, 2)
		star.position = Vector2(randf() * W, randf() * (H * 0.5))
		star.color = Color(0.85, 0.85, 0.92, 0.5)
		root.add_child(star)
	# Monsters moving away with small brother (already moving off-screen)
	var m1 := _make_sprite(root, "gobelin", SP_MONSTER, Vector2(900, H - 200))
	m1.modulate = Color(0.4, 0.25, 0.2)
	var small := _make_sprite(root, "hero", SP_SMALL, Vector2(960, H - 185))
	small.modulate = Color(0.5, 0.5, 0.7)
	small.rotation_degrees = 35.0
	# Fade them into distance
	var t1 := create_tween()
	t1.tween_property(m1, "position:x", 1350.0, 3.0).set_ease(Tween.EASE_IN)
	t1.parallel().tween_property(m1, "scale", m1.scale * 0.3, 3.0)
	var t2 := create_tween()
	t2.tween_property(small, "position:x", 1380.0, 3.0).set_ease(Tween.EASE_IN)
	t2.parallel().tween_property(small, "scale", small.scale * 0.3, 3.0)
	# "..." text
	var dots := Label.new()
	dots.text = "..."
	dots.add_theme_font_size_override("font_size", 32)
	dots.add_theme_color_override("font_color", Color(0.55, 0.45, 0.35, 0.8))
	dots.position = Vector2(350, H - 280)
	root.add_child(dots)

# Scene 6: Hero awakens alone
func _build_scene_awakening() -> void:
	var root := _make_scene_root()
	_add_bg(root, Color(0.025, 0.02, 0.02), Vector2.ZERO, Vector2(W, H))
	_add_bg(root, Color(0.05, 0.04, 0.03), Vector2(0, H - 160), Vector2(W, 160))
	_add_bg(root, Color(0.07, 0.05, 0.03), Vector2(200, H - 280), Vector2(880, 280))  # barn
	# Hero sitting/getting up
	var hero := _make_sprite(root, "hero", SP_HERO, Vector2(640, H - 230))
	hero.modulate = Color(0.8, 0.75, 0.82)
	# Hero was lying, now sitting up
	var anim_t := create_tween()
	anim_t.tween_property(hero, "rotation_degrees", 0.0, 1.2).from(80.0).set_ease(Tween.EASE_OUT)
	# Empty grange, silence
	var silence := Label.new()
	silence.text = ". . ."
	silence.add_theme_font_size_override("font_size", 28)
	silence.add_theme_color_override("font_color", Color(0.5, 0.45, 0.42, 0.6))
	silence.position = Vector2(560, H - 310)
	root.add_child(silence)
	# Red light dawn through window
	var dawn := ColorRect.new()
	dawn.size = Vector2(60, 100)
	dawn.position = Vector2(800, H - 300)
	dawn.color = Color(0.6, 0.18, 0.06, 0.25)
	root.add_child(dawn)

# Scene 7: Hero picks up father's sword
func _build_scene_sword() -> void:
	var root := _make_scene_root()
	# Interior of house (warm dark)
	_add_bg(root, Color(0.07, 0.04, 0.02), Vector2.ZERO, Vector2(W, H))
	_add_bg(root, Color(0.10, 0.06, 0.03), Vector2(0, H - 160), Vector2(W, 160))
	# Wall with sword mounted
	_add_bg(root, Color(0.12, 0.08, 0.05), Vector2(480, H - 400), Vector2(320, 400))
	# Sword (mounted on wall)
	var sword_blade := ColorRect.new()
	sword_blade.size = Vector2(8, 120)
	sword_blade.position = Vector2(636, H - 380)
	sword_blade.color = Color(0.78, 0.82, 0.88)
	root.add_child(sword_blade)
	var sword_guard := ColorRect.new()
	sword_guard.size = Vector2(30, 6)
	sword_guard.position = Vector2(625, H - 280)
	sword_guard.color = Color(0.60, 0.50, 0.20)
	root.add_child(sword_guard)
	var sword_handle := ColorRect.new()
	sword_handle.size = Vector2(8, 36)
	sword_handle.position = Vector2(636, H - 275)
	sword_handle.color = Color(0.40, 0.28, 0.14)
	root.add_child(sword_handle)
	# Glow around sword
	var glow := ColorRect.new()
	glow.size = Vector2(50, 140)
	glow.position = Vector2(615, H - 390)
	glow.color = Color(0.5, 0.6, 0.8, 0.0)
	root.add_child(glow)
	var gt := create_tween()
	gt.tween_property(glow, "color:a", 0.15, 1.0).set_ease(Tween.EASE_IN_OUT)
	gt.tween_property(glow, "color:a", 0.05, 1.0).set_ease(Tween.EASE_IN_OUT)
	gt.set_loops()
	# Hero approaching
	var hero := _make_sprite(root, "hero", SP_HERO, Vector2(440, H - 230))
	var ht := create_tween()
	ht.tween_property(hero, "position:x", 580.0, 1.8).set_ease(Tween.EASE_OUT)
	# Inscription
	var inscription := Label.new()
	inscription.text = "— L'épée du père —"
	inscription.add_theme_font_size_override("font_size", 14)
	inscription.add_theme_color_override("font_color", Color(0.55, 0.45, 0.28, 0.7))
	inscription.position = Vector2(590, H - 400)
	root.add_child(inscription)

# ── Star Wars crawl ────────────────────────────────────────────────────────────

func _build_crawl() -> void:
	_crawl_root = Node2D.new()
	_crawl_root.visible = false
	_crawl_root.z_index = 25
	add_child(_crawl_root)

	# Starfield background
	var bg := ColorRect.new()
	bg.size = Vector2(W, H)
	bg.color = Color(0.01, 0.01, 0.02)
	_crawl_root.add_child(bg)
	for i in 200:
		var star := ColorRect.new()
		star.size = Vector2(randi() % 2 + 1, randi() % 2 + 1)
		star.position = Vector2(randf() * W, randf() * H)
		star.color = Color(0.8, 0.8, 0.9, randf_range(0.2, 0.7))
		_crawl_root.add_child(star)

	# Top gradient fade (text disappears into perspective)
	var fade_top := ColorRect.new()
	fade_top.size = Vector2(W, 160)
	fade_top.position = Vector2(0, 0)
	fade_top.color = Color(0.01, 0.01, 0.02, 0.95)
	fade_top.z_index = 5
	_crawl_root.add_child(fade_top)

	# Bottom gradient fade
	var fade_bot := ColorRect.new()
	fade_bot.size = Vector2(W, 80)
	fade_bot.position = Vector2(0, H - 80)
	fade_bot.color = Color(0.01, 0.01, 0.02, 0.9)
	fade_bot.z_index = 5
	_crawl_root.add_child(fade_bot)

	# Text block
	var text_container := Node2D.new()
	text_container.name = "TextContainer"
	_crawl_root.add_child(text_container)

	var y_offset := 0.0
	for line in STORY_LINES:
		var lbl := Label.new()
		lbl.text = line
		var is_title: bool = (line == "T H E   L A S T   H O U R")
		var is_emphasis: bool = (line == "UNE HEURE.")
		var fs: int = 50 if is_title else (34 if is_emphasis else 22)
		var color: Color = Color(0.95, 0.88, 0.5) if is_title else (Color(1.0, 0.4, 0.3) if is_emphasis else Color(0.80, 0.76, 0.68))
		lbl.add_theme_font_size_override("font_size", fs)
		lbl.add_theme_color_override("font_color", color)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.size = Vector2(700, fs + 8)
		lbl.position = Vector2((W - 700) / 2.0, y_offset)
		text_container.add_child(lbl)
		y_offset += float(fs + 8) if line.length() > 0 else 20.0

	_crawl_y = H + 40.0
	text_container.position.y = _crawl_y
	text_container.name = "TextContainer"

# ── Fade overlay ───────────────────────────────────────────────────────────────

func _build_fade() -> void:
	_fade_rect = ColorRect.new()
	_fade_rect.size = Vector2(W, H)
	_fade_rect.color = Color(0, 0, 0, 1.0)
	_fade_rect.z_index = 50
	add_child(_fade_rect)
	# Initial fade in
	var t := create_tween()
	t.tween_property(_fade_rect, "color:a", 0.0, 1.2)

# ── Scene timings ──────────────────────────────────────────────────────────────

const SCENE_DURATIONS := [5.0, 4.0, 4.5, 4.0, 4.5, 4.5, 4.0, 5.0]

func _process(delta: float) -> void:
	match _phase:
		Phase.CINEMATIC: _update_cinematic(delta)
		Phase.CRAWL:     _update_crawl(delta)
		Phase.FADE_OUT:  _update_fade_out(delta)

func _update_cinematic(delta: float) -> void:
	_scene_t += delta
	var dur: float = SCENE_DURATIONS[_scene_idx] if _scene_idx < SCENE_DURATIONS.size() else 4.0

	if _scene_t >= dur:
		_scene_t = 0.0
		_scene_idx += 1
		if _scene_idx >= _scene_root.get_child_count():
			_start_crawl()
		else:
			# Fade between scenes
			var ft := create_tween()
			ft.tween_property(_fade_rect, "color:a", 1.0, 0.4)
			ft.tween_callback(func():
				_show_scene(_scene_idx)
				create_tween().tween_property(_fade_rect, "color:a", 0.0, 0.5)
			)

func _start_crawl() -> void:
	_phase = Phase.CRAWL
	_letters_root.visible = false
	_skip_lbl.visible = false
	_sub_lbl.visible = false
	_scene_root.visible = false
	var ft := create_tween()
	ft.tween_property(_fade_rect, "color:a", 1.0, 0.6)
	ft.tween_callback(func():
		_crawl_root.visible = true
		create_tween().tween_property(_fade_rect, "color:a", 0.0, 0.8)
	)

func _update_crawl(delta: float) -> void:
	_crawl_y -= CRAWL_SPEED * delta
	var container := _crawl_root.get_node_or_null("TextContainer")
	if container:
		container.position.y = _crawl_y
		# Check if text has scrolled past top
		var last_child_y := 0.0
		if container.get_child_count() > 0:
			var last := container.get_child(container.get_child_count() - 1)
			last_child_y = _crawl_y + last.position.y
		if last_child_y < -60:
			_start_fade_out()

func _start_fade_out() -> void:
	_phase = Phase.FADE_OUT
	var ft := create_tween()
	ft.tween_property(_fade_rect, "color:a", 1.0, 1.5)
	ft.tween_interval(0.5)
	ft.tween_callback(_launch_game)

func _update_fade_out(_delta: float) -> void:
	pass

func _launch_game() -> void:
	GameManager.new_game()
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

# ── Input (skip) ───────────────────────────────────────────────────────────────

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_skip()

func _skip() -> void:
	if _phase == Phase.FADE_OUT or _phase == Phase.DONE:
		return
	_start_fade_out()

# ── Helpers ────────────────────────────────────────────────────────────────────

func _make_scene_root() -> Node2D:
	var r := Node2D.new()
	r.visible = false
	_scene_root.add_child(r)
	return r

func _add_bg(parent: Node2D, color: Color, pos: Vector2, size: Vector2) -> ColorRect:
	var r := ColorRect.new()
	r.color = color
	r.position = pos
	r.size = size
	parent.add_child(r)
	return r

func _make_sprite(parent: Node2D, tex_key: String, sc: float, pos: Vector2) -> Sprite2D:
	var sp := Sprite2D.new()
	sp.texture = _sprites[tex_key]
	sp.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sp.scale = Vector2.ONE * sc
	sp.position = pos
	if SPRITE_HFRAMES.has(tex_key):
		sp.hframes = SPRITE_HFRAMES[tex_key]
		sp.frame = 0
	parent.add_child(sp)
	return sp
