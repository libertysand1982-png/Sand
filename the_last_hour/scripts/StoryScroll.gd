# StoryScroll.gd — intro cinématique pixel 2D + défilement Star Wars.
# Phase 1 : Cinématique (9 scènes animées avec sous-titres)
# Phase 2 : Texte défilant Star Wars
# Escape pour skipper à tout moment.
extends Node2D

const W := 1280.0
const H := 720.0

# Sprite scales — divisor = frame height of each sheet
const SP_PAYSAN  := 90.0 / 140.0   # frères paysans (wizard idle, 140 px)
const SP_CADET   := 52.0 / 140.0   # petit frère
const SP_MONSTER := 48.0 / 96.0    # gobelin (kobold, 96 px)

enum Phase { CINEMATIC, CRAWL, FADE_OUT, DONE }
var _phase: Phase = Phase.CINEMATIC

var _scene_idx := 0
var _scene_t   := 0.0
const SCENES: Array[Dictionary] = []

var _bg:           ColorRect
var _letters_root: Node2D
var _scene_root:   Node2D
var _sub_lbl:      Label
var _skip_lbl:     Label

var _crawl_root: Node2D
var _crawl_y:    float = H + 20.0
const CRAWL_SPEED := 60.0

var _fade_rect: ColorRect
var _sprites := {}

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
"Une lettre tomba à ses pieds.",
"« Château Noir. Une heure. Ou ton frère mourra. »",
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

const SPRITE_HFRAMES := {
	"paysan":  10,  # wizard/idle : 10 frames 140×140
	"gobelin":  9,  # kobold/idle : 9 frames 96×96
}

func _load_sprites() -> void:
	_sprites["paysan"]    = load("res://assets/characters/wizard/idle.png")
	_sprites["gobelin"]   = load("res://assets/characters/gobelin.png")
	_sprites["ew3_idle"]  = load("res://assets/characters/evil_wizard3/idle.png")
	_sprites["ew3_walk"]  = load("res://assets/characters/evil_wizard3/walk.png")
	_sprites["holy_init"] = load("res://assets/vfx/holy_initial.png")
	_sprites["holy_loop"] = load("res://assets/vfx/holy_repeatable.png")
	_sprites["weapons"]   = load("res://assets/items/weapons.png")

# ── Base layout ────────────────────────────────────────────────────────────────

func _build_base() -> void:
	_bg = ColorRect.new()
	_bg.size = Vector2(W, H)
	_bg.color = Color(0.02, 0.01, 0.01)
	add_child(_bg)

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

	_sub_lbl = Label.new()
	_sub_lbl.add_theme_font_size_override("font_size", 20)
	_sub_lbl.add_theme_color_override("font_color", Color(0.88, 0.84, 0.78))
	_sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_sub_lbl.position = Vector2(160, H - 70)
	_sub_lbl.size = Vector2(960, 36)
	_sub_lbl.z_index = 31
	add_child(_sub_lbl)

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
	_scene_idx = 0
	_scene_t   = 0.0
	_build_all_scenes()
	_show_scene(0)

func _build_all_scenes() -> void:
	_build_scene_farm_night()    # 0
	_build_scene_noise()         # 1
	_build_scene_split()         # 2
	_build_scene_attack()        # 3
	_build_scene_ko()            # 4
	_build_scene_wizard_letter() # 5  — Evil Wizard 3 + lettre
	_build_scene_abduction()     # 6
	_build_scene_awakening()     # 7
	_build_scene_sword()         # 8  — Holy VFX

func _show_scene(idx: int) -> void:
	for i in _scene_root.get_child_count():
		_scene_root.get_child(i).visible = (i == idx)
	var subs := [
		"La ferme des frères Aldric. Nuit calme.",
		"Des bruits dans la grange...",
		"« Toi à gauche. Moi à droite. »",
		"Une embuscade !",
		"L'aîné tombe, assommé.",
		"Une présence mystérieuse s'adresse à lui...",
		"Le cadet est emporté dans l'obscurité.",
		"L'aîné se réveille. Seul. La grange, vide.",
		"L'épée de son père. La seule chose qui lui reste.",
	]
	_sub_lbl.text = subs[idx] if idx < subs.size() else ""
	_start_scene_anim(idx)

# ── Scene animators (called when scene becomes visible) ───────────────────────

func _start_scene_anim(idx: int) -> void:
	match idx:
		5: _start_wizard_anim()
		8: _start_sword_anim()

func _start_wizard_anim() -> void:
	var root: Node2D = _scene_root.get_child(5)
	if not root: return
	var wizard: AnimatedSprite2D = root.get_node_or_null("Wizard") as AnimatedSprite2D
	var aura:   ColorRect        = root.get_node_or_null("Aura")   as ColorRect
	var flash:  ColorRect        = root.get_node_or_null("Flash")  as ColorRect
	var bubble: Node2D           = root.get_node_or_null("Bubble") as Node2D
	if not wizard or not bubble: return
	# Reset to initial (invisible) state
	var wz_sc := 68.0 / 140.0
	wizard.scale    = Vector2(0.0, 0.0)
	wizard.play("idle")
	flash.color     = Color(0.6, 0.3, 1.0, 0.0)
	aura.color      = Color(0.28, 0.0, 0.45, 0.0)
	bubble.modulate = Color(1, 1, 1, 0.0)
	# Materialize sequence
	var wt := create_tween()
	wt.tween_property(flash, "color:a", 0.65, 0.04)
	wt.tween_property(flash, "color:a", 0.0, 0.22)
	wt.parallel().tween_property(wizard, "scale", Vector2(wz_sc, wz_sc), 0.32).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	wt.parallel().tween_property(aura, "color:a", 0.38, 0.45)
	# Pause then speech bubble appears
	wt.tween_interval(0.45)
	wt.tween_property(bubble, "modulate:a", 1.0, 0.38)
	# Hold for player to read
	wt.tween_interval(4.2)
	# Bubble fades, then wizard dematerializes
	wt.tween_property(bubble, "modulate:a", 0.0, 0.32)
	wt.tween_interval(0.25)
	wt.tween_property(flash, "color:a", 0.55, 0.04)
	wt.tween_property(flash, "color:a", 0.0, 0.22)
	wt.parallel().tween_property(wizard, "scale", Vector2(0.0, 0.0), 0.28).set_ease(Tween.EASE_IN)
	wt.parallel().tween_property(aura, "color:a", 0.0, 0.32)

func _start_sword_anim() -> void:
	var root: Node2D = _scene_root.get_child(8)
	if not root: return
	var hero:  Sprite2D          = root.get_node_or_null("Hero")  as Sprite2D
	var holy:  AnimatedSprite2D  = root.get_node_or_null("Holy")  as AnimatedSprite2D
	if not hero: return
	# Reset
	hero.position.x = 430.0
	if holy:
		holy.visible = false
	var ht := create_tween()
	ht.tween_property(hero, "position:x", 580.0, 1.8).set_ease(Tween.EASE_OUT)
	var vt := create_tween()
	vt.tween_interval(1.65)
	vt.tween_callback(func():
		if is_instance_valid(holy):
			holy.visible = true
			holy.play("initial")
	)
	vt.tween_interval(0.22)
	vt.tween_callback(func():
		if is_instance_valid(holy): holy.play("repeat")
	)

# ── Timing ────────────────────────────────────────────────────────────────────

const SCENE_DURATIONS := [5.0, 4.0, 4.5, 4.0, 4.5, 8.0, 4.5, 4.0, 6.0]

# ── Scene 0 : Ferme, nuit calme ───────────────────────────────────────────────

func _build_scene_farm_night() -> void:
	var root := _make_scene_root()
	_add_bg(root, Color(0.04, 0.04, 0.12), Vector2.ZERO, Vector2(W, H))
	for i in 80:
		var star := ColorRect.new()
		star.size = Vector2(2, 2)
		star.position = Vector2(randf() * W, randf() * (H * 0.55))
		star.color = Color(0.9, 0.88, 0.95, randf_range(0.4, 0.9))
		root.add_child(star)
	var moon := ColorRect.new()
	moon.size = Vector2(40, 40)
	moon.position = Vector2(900, 80)
	moon.color = Color(0.88, 0.88, 0.80, 0.7)
	root.add_child(moon)
	_add_bg(root, Color(0.06, 0.08, 0.04), Vector2(0, H - 220), Vector2(W, 220))
	_add_bg(root, Color(0.10, 0.07, 0.05), Vector2(360, H - 320), Vector2(560, 320))
	_add_bg(root, Color(0.08, 0.055, 0.04), Vector2(340, H - 370), Vector2(600, 60))
	# Deux frères paysans endormis (robes brunes, non armurés)
	var b1 := _make_sprite(root, "paysan", SP_PAYSAN, Vector2(510, H - 220))
	b1.rotation_degrees = 90.0
	b1.modulate = Color(0.58, 0.46, 0.28)
	var b2 := _make_sprite(root, "paysan", SP_CADET, Vector2(610, H - 210))
	b2.rotation_degrees = 90.0
	b2.modulate = Color(0.52, 0.42, 0.25)
	for i in 3:
		var z := Label.new()
		z.text = "z"
		z.add_theme_font_size_override("font_size", 14 + i * 4)
		z.add_theme_color_override("font_color", Color(0.7, 0.7, 0.9, 0.5 - i * 0.1))
		z.position = Vector2(490 + i * 20, H - 255 - i * 18)
		root.add_child(z)
		var t := create_tween().set_loops()
		t.tween_property(z, "position:y", z.position.y - 15, 1.5 + i * 0.3).set_ease(Tween.EASE_IN_OUT)
		t.tween_property(z, "position:y", z.position.y,      1.5 + i * 0.3).set_ease(Tween.EASE_IN_OUT)

# ── Scene 1 : Bruits dans la grange ──────────────────────────────────────────

func _build_scene_noise() -> void:
	var root := _make_scene_root()
	_add_bg(root, Color(0.04, 0.04, 0.12), Vector2.ZERO, Vector2(W, H))
	_add_bg(root, Color(0.06, 0.08, 0.04), Vector2(0, H - 220), Vector2(W, 220))
	_add_bg(root, Color(0.10, 0.07, 0.05), Vector2(360, H - 320), Vector2(560, 320))
	_make_sprite(root, "paysan", SP_PAYSAN, Vector2(480, H - 230))
	_make_sprite(root, "paysan", SP_CADET,  Vector2(625, H - 215))
	for pos in [Vector2(465, H - 310), Vector2(612, H - 296)]:
		var ex := Label.new()
		ex.text = "!"
		ex.add_theme_font_size_override("font_size", 36)
		ex.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
		ex.position = pos
		root.add_child(ex)
		var t := create_tween().set_loops()
		t.tween_property(ex, "scale", Vector2(1.3, 1.3), 0.3)
		t.tween_property(ex, "scale", Vector2(1.0, 1.0), 0.3)
	var noise := Label.new()
	noise.text = "~ ~ ~ ~"
	noise.add_theme_font_size_override("font_size", 22)
	noise.add_theme_color_override("font_color", Color(0.6, 0.5, 0.3, 0.7))
	noise.position = Vector2(400, H - 360)
	root.add_child(noise)

# ── Scene 2 : Séparation ──────────────────────────────────────────────────────

func _build_scene_split() -> void:
	var root := _make_scene_root()
	_add_bg(root, Color(0.04, 0.04, 0.10), Vector2.ZERO, Vector2(W, H))
	_add_bg(root, Color(0.08, 0.06, 0.04), Vector2(0, H - 180), Vector2(W, 180))
	_add_bg(root, Color(0.09, 0.065, 0.045), Vector2(300, H - 340), Vector2(680, 340))
	for i in 8:
		var d := ColorRect.new()
		d.size = Vector2(3, 14)
		d.position = Vector2(W / 2.0 - 1.5, H - 340 + i * 30)
		d.color = Color(0.5, 0.4, 0.25, 0.5)
		root.add_child(d)
	var h_big := _make_sprite(root, "paysan", SP_PAYSAN, Vector2(360, H - 230))
	h_big.scale.x = -abs(h_big.scale.x)  # face gauche
	create_tween().tween_property(h_big, "position:x", 380.0, 1.5).set_ease(Tween.EASE_OUT)
	var h_small := _make_sprite(root, "paysan", SP_CADET, Vector2(880, H - 215))
	create_tween().tween_property(h_small, "position:x", 860.0, 1.5).set_ease(Tween.EASE_OUT)
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

# ── Scene 3 : Embuscade ────────────────────────────────────────────────────────

func _build_scene_attack() -> void:
	var root := _make_scene_root()
	_add_bg(root, Color(0.03, 0.02, 0.04), Vector2.ZERO, Vector2(W, H))
	_add_bg(root, Color(0.06, 0.04, 0.03), Vector2(0, H - 180), Vector2(W, 180))
	_add_bg(root, Color(0.08, 0.05, 0.03), Vector2(200, H - 320), Vector2(880, 320))
	var monster := _make_sprite(root, "gobelin", SP_MONSTER, Vector2(800, H - 240))
	monster.modulate = Color(0.6, 0.3, 0.25)
	create_tween().tween_property(monster, "position:x", 580.0, 0.8).set_ease(Tween.EASE_IN)
	_make_sprite(root, "paysan", SP_PAYSAN, Vector2(440, H - 230))
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
	var flash := ColorRect.new()
	flash.size = Vector2(W, H)
	flash.color = Color(0.8, 0.1, 0.05, 0.0)
	flash.z_index = 5
	root.add_child(flash)
	var ft := create_tween()
	ft.tween_interval(0.75)
	ft.tween_property(flash, "color:a", 0.65, 0.05)
	ft.tween_property(flash, "color:a", 0.0,  0.5)
	var q := Label.new()
	q.text = "???"
	q.add_theme_font_size_override("font_size", 20)
	q.add_theme_color_override("font_color", Color(0.8, 0.7, 0.4, 0.7))
	q.position = Vector2(950, H - 260)
	root.add_child(q)

# ── Scene 4 : L'aîné à terre ──────────────────────────────────────────────────

func _build_scene_ko() -> void:
	var root := _make_scene_root()
	_add_bg(root, Color(0.025, 0.015, 0.015), Vector2.ZERO, Vector2(W, H))
	_add_bg(root, Color(0.055, 0.035, 0.025), Vector2(0, H - 180), Vector2(W, 180))
	var hero := _make_sprite(root, "paysan", SP_PAYSAN, Vector2(500, H - 190))
	hero.rotation_degrees = 90.0
	hero.modulate = Color(0.52, 0.45, 0.55)
	for i in 5:
		var star := Label.new()
		star.text = "✦"
		star.add_theme_font_size_override("font_size", 14)
		star.add_theme_color_override("font_color", Color(0.9, 0.85, 0.3, 0.8))
		star.position = Vector2(475, H - 230)
		root.add_child(star)
		var ang := TAU / 5.0 * i
		var stt := create_tween().set_loops()
		stt.tween_property(star, "position", Vector2(475 + cos(ang) * 28, H - 230 + sin(ang) * 18), 1.2)
		stt.tween_property(star, "position", Vector2(475 + cos(ang + 0.8) * 28, H - 230 + sin(ang + 0.8) * 18), 1.2)
	var blood := ColorRect.new()
	blood.size = Vector2(80, 12)
	blood.position = Vector2(460, H - 178)
	blood.color = Color(0.35, 0.04, 0.02, 0.7)
	root.add_child(blood)
	var monster := _make_sprite(root, "gobelin", SP_MONSTER, Vector2(760, H - 230))
	monster.modulate = Color(0.4, 0.25, 0.2)
	var small := _make_sprite(root, "paysan", SP_CADET, Vector2(800, H - 210))
	small.modulate = Color(0.46, 0.42, 0.52)
	small.rotation_degrees = 45.0
	create_tween().tween_property(monster, "position:x", 1400.0, 2.5).set_ease(Tween.EASE_IN)
	create_tween().tween_property(small,   "position:x", 1450.0, 2.5).set_ease(Tween.EASE_IN)

# ── Scene 5 : Evil Wizard 3 se matérialise et parle au frère blessé ──────────

func _build_scene_wizard_letter() -> void:
	var root := _make_scene_root()
	root.name = "SceneWizard"
	_add_bg(root, Color(0.02, 0.01, 0.02), Vector2.ZERO, Vector2(W, H))
	_add_bg(root, Color(0.04, 0.02, 0.02), Vector2(0, H - 180), Vector2(W, 180))
	# Aîné inconscient au sol (plus grand)
	var hero := _make_sprite(root, "paysan", SP_PAYSAN, Vector2(300, H - 190))
	hero.rotation_degrees = 90.0
	hero.modulate = Color(0.45, 0.38, 0.48)
	# Aura violette derrière le sorcier — invisible initialement
	var aura := ColorRect.new()
	aura.name = "Aura"
	aura.size = Vector2(90, 110)
	aura.color = Color(0.28, 0.0, 0.45, 0.0)
	aura.position = Vector2(718, H - 275)
	root.add_child(aura)
	# Flash d'apparition — invisible initialement
	var flash := ColorRect.new()
	flash.name = "Flash"
	flash.size = Vector2(W, H)
	flash.color = Color(0.6, 0.3, 1.0, 0.0)
	flash.z_index = 10
	root.add_child(flash)
	# Evil Wizard 3 — scale=0 au départ (invisible), _start_wizard_anim() le fait apparaître
	var wizard := AnimatedSprite2D.new()
	wizard.name = "Wizard"
	wizard.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	wizard.sprite_frames = _make_ew3_frames()
	wizard.scale = Vector2(0.0, 0.0)
	wizard.position = Vector2(760, H - 215.0)
	wizard.flip_h = true   # face au frère blessé à gauche
	wizard.play("idle")
	root.add_child(wizard)
	# Bulle de dialogue (conteneur — modulate:a contrôle tout d'un coup)
	var bubble := Node2D.new()
	bubble.name = "Bubble"
	bubble.modulate = Color(1, 1, 1, 0.0)
	root.add_child(bubble)
	# Bordure de la bulle (couleur violette)
	var border := ColorRect.new()
	border.size = Vector2(348, 82)
	border.position = Vector2(376, H - 350)
	border.color = Color(0.55, 0.18, 0.78, 0.94)
	bubble.add_child(border)
	# Fond intérieur foncé
	var bg := ColorRect.new()
	bg.size = Vector2(340, 74)
	bg.position = Vector2(380, H - 346)
	bg.color = Color(0.07, 0.03, 0.12, 0.97)
	bubble.add_child(bg)
	# Queue de la bulle pointant vers le sorcier (en bas à droite)
	var tail := ColorRect.new()
	tail.size = Vector2(20, 26)
	tail.position = Vector2(706, H - 284)
	tail.rotation_degrees = 25.0
	tail.color = Color(0.55, 0.18, 0.78, 0.94)
	bubble.add_child(tail)
	# Texte du discours
	var speech := Label.new()
	speech.text = "« Ton frère est prisonnier\n     du Château Noir...\n Tu as exactement une heure. »"
	speech.add_theme_font_size_override("font_size", 14)
	speech.add_theme_color_override("font_color", Color(0.92, 0.80, 1.0))
	speech.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	speech.size = Vector2(330, 72)
	speech.position = Vector2(385, H - 344)
	bubble.add_child(speech)

# ── Scene 6 : Enlèvement (récapitulatif) ──────────────────────────────────────

func _build_scene_abduction() -> void:
	var root := _make_scene_root()
	_add_bg(root, Color(0.03, 0.03, 0.08), Vector2.ZERO, Vector2(W, H))
	_add_bg(root, Color(0.04, 0.06, 0.03), Vector2(0, H - 160), Vector2(W, 160))
	for i in 50:
		var star := ColorRect.new()
		star.size = Vector2(2, 2)
		star.position = Vector2(randf() * W, randf() * (H * 0.5))
		star.color = Color(0.85, 0.85, 0.92, 0.5)
		root.add_child(star)
	var m1 := _make_sprite(root, "gobelin", SP_MONSTER, Vector2(900, H - 200))
	m1.modulate = Color(0.4, 0.25, 0.2)
	var small := _make_sprite(root, "paysan", SP_CADET, Vector2(960, H - 185))
	small.modulate = Color(0.46, 0.42, 0.52)
	small.rotation_degrees = 35.0
	var t1 := create_tween()
	t1.tween_property(m1, "position:x", 1350.0, 3.0).set_ease(Tween.EASE_IN)
	t1.parallel().tween_property(m1, "scale", m1.scale * 0.3, 3.0)
	var t2 := create_tween()
	t2.tween_property(small, "position:x", 1380.0, 3.0).set_ease(Tween.EASE_IN)
	t2.parallel().tween_property(small, "scale", small.scale * 0.3, 3.0)
	var dots := Label.new()
	dots.text = "..."
	dots.add_theme_font_size_override("font_size", 32)
	dots.add_theme_color_override("font_color", Color(0.55, 0.45, 0.35, 0.8))
	dots.position = Vector2(350, H - 280)
	root.add_child(dots)

# ── Scene 7 : L'aîné se réveille ─────────────────────────────────────────────

func _build_scene_awakening() -> void:
	var root := _make_scene_root()
	_add_bg(root, Color(0.025, 0.02, 0.02), Vector2.ZERO, Vector2(W, H))
	_add_bg(root, Color(0.05, 0.04, 0.03), Vector2(0, H - 160), Vector2(W, 160))
	_add_bg(root, Color(0.07, 0.05, 0.03), Vector2(200, H - 280), Vector2(880, 280))
	var hero := _make_sprite(root, "paysan", SP_PAYSAN, Vector2(640, H - 230))
	hero.modulate = Color(0.78, 0.64, 0.40)
	create_tween().tween_property(hero, "rotation_degrees", 0.0, 1.2).from(80.0).set_ease(Tween.EASE_OUT)
	var silence := Label.new()
	silence.text = ". . ."
	silence.add_theme_font_size_override("font_size", 28)
	silence.add_theme_color_override("font_color", Color(0.5, 0.45, 0.42, 0.6))
	silence.position = Vector2(560, H - 310)
	root.add_child(silence)
	var dawn := ColorRect.new()
	dawn.size = Vector2(60, 100)
	dawn.position = Vector2(800, H - 300)
	dawn.color = Color(0.6, 0.18, 0.06, 0.25)
	root.add_child(dawn)

# ── Scene 8 : L'épée du père + Holy VFX ─────────────────────────────────────

func _build_scene_sword() -> void:
	var root := _make_scene_root()
	root.name = "SceneSword"
	_add_bg(root, Color(0.07, 0.04, 0.02), Vector2.ZERO, Vector2(W, H))
	_add_bg(root, Color(0.10, 0.06, 0.03), Vector2(0, H - 160), Vector2(W, 160))
	# Panneau mural derrière l'épée
	_add_bg(root, Color(0.14, 0.09, 0.06), Vector2(590, H - 420), Vector2(100, 420))
	# Supports muraux (clous/crochets)
	var hook_t := ColorRect.new()
	hook_t.size = Vector2(44, 7)
	hook_t.position = Vector2(618, H - 402)
	hook_t.color = Color(0.28, 0.20, 0.10, 0.9)
	root.add_child(hook_t)
	var hook_b := ColorRect.new()
	hook_b.size = Vector2(44, 7)
	hook_b.position = Vector2(618, H - 296)
	hook_b.color = Color(0.28, 0.20, 0.10, 0.9)
	root.add_child(hook_b)
	# Lueur dorée pulsante (looping — toujours visible)
	var glow := ColorRect.new()
	glow.size = Vector2(96, 130)
	glow.position = Vector2(592, H - 420)
	glow.color = Color(0.9, 0.72, 0.18, 0.0)
	root.add_child(glow)
	var gt := create_tween().set_loops()
	gt.tween_property(glow, "color:a", 0.18, 1.4).set_ease(Tween.EASE_IN_OUT)
	gt.tween_property(glow, "color:a", 0.05, 1.4).set_ease(Tween.EASE_IN_OUT)
	# Scintillements dorés (looping — toujours visibles)
	for i in 4:
		var spark := Label.new()
		spark.text = "✦"
		spark.add_theme_font_size_override("font_size", 8 + i * 3)
		spark.add_theme_color_override("font_color", Color(1.0, 0.88, 0.3, 0.8))
		spark.position = Vector2(610 + i * 16, H - 420 + i * 22)
		root.add_child(spark)
		var st := create_tween().set_loops()
		st.tween_property(spark, "modulate:a", 0.08, 0.4 + i * 0.18).set_ease(Tween.EASE_IN_OUT)
		st.tween_property(spark, "modulate:a", 0.85, 0.4 + i * 0.18).set_ease(Tween.EASE_IN_OUT)
	# Épée réelle (spritesheet weapons.png — premier sprite 16×16, colonne 0 rangée 0)
	var sword := Sprite2D.new()
	sword.texture = _sprites["weapons"]
	sword.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sword.region_enabled = true
	sword.region_rect = Rect2(0, 0, 16, 16)
	sword.scale = Vector2(7.0, 7.0)         # 16×7 = 112 px affiché
	sword.position = Vector2(640, H - 350)
	sword.rotation_degrees = -40.0           # légèrement incliné, pointe en haut
	root.add_child(sword)
	# Inscription gravée
	var inscription := Label.new()
	inscription.text = "— L'épée du père —"
	inscription.add_theme_font_size_override("font_size", 14)
	inscription.add_theme_color_override("font_color", Color(0.55, 0.45, 0.28, 0.7))
	inscription.position = Vector2(575, H - 430)
	root.add_child(inscription)
	# Héros (paysan) — position initiale, _start_sword_anim() gère le déplacement
	var hero := _make_sprite(root, "paysan", SP_PAYSAN, Vector2(430, H - 230))
	hero.name = "Hero"
	hero.modulate = Color(0.80, 0.66, 0.42)
	# Holy VFX — invisible au départ, _start_sword_anim() le déclenche
	var holy := _make_holy_anim(root, Vector2(640, H - 355))
	holy.name = "Holy"

# ── Helpers — sprites animés ──────────────────────────────────────────────────

func _make_ew3_frames() -> SpriteFrames:
	var sf := SpriteFrames.new()
	sf.remove_animation("default")
	var defs := {
		"idle": [10, 8.0,  "ew3_idle"],
		"walk": [8,  10.0, "ew3_walk"],
	}
	for raw_name in defs:
		var anim_name: String = str(raw_name)
		var def: Array = defs[anim_name]
		var frame_count: int = int(def[0])
		var fps: float = float(def[1])
		var tex_key: String = str(def[2])
		sf.add_animation(anim_name)
		sf.set_animation_speed(anim_name, fps)
		sf.set_animation_loop(anim_name, true)
		var tex: Texture2D = _sprites[tex_key]
		for i in frame_count:
			var atlas := AtlasTexture.new()
			atlas.atlas = tex
			atlas.region = Rect2(i * 140, 0, 140, 140)
			sf.add_frame(anim_name, atlas)
	return sf

func _make_holy_anim(parent: Node2D, pos: Vector2) -> AnimatedSprite2D:
	var holy := AnimatedSprite2D.new()
	holy.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var sf := SpriteFrames.new()
	sf.remove_animation("default")
	# initial : 2 frames 32×32
	sf.add_animation("initial")
	sf.set_animation_speed("initial", 10.0)
	sf.set_animation_loop("initial", false)
	var init_tex: Texture2D = _sprites["holy_init"]
	for i in 2:
		var atlas := AtlasTexture.new()
		atlas.atlas = init_tex
		atlas.region = Rect2(i * 32, 0, 32, 32)
		sf.add_frame("initial", atlas)
	# repeat : 8 frames 32×32
	sf.add_animation("repeat")
	sf.set_animation_speed("repeat", 12.0)
	sf.set_animation_loop("repeat", true)
	var rep_tex: Texture2D = _sprites["holy_loop"]
	for i in 8:
		var atlas := AtlasTexture.new()
		atlas.atlas = rep_tex
		atlas.region = Rect2(i * 32, 0, 32, 32)
		sf.add_frame("repeat", atlas)
	holy.sprite_frames = sf
	holy.scale = Vector2(5.0, 5.0)  # 32×5 = 160 px affiché
	holy.position = pos
	holy.visible = false
	parent.add_child(holy)
	return holy

# ── Star Wars crawl ────────────────────────────────────────────────────────────

func _build_crawl() -> void:
	_crawl_root = Node2D.new()
	_crawl_root.visible = false
	_crawl_root.z_index = 25
	add_child(_crawl_root)

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

	var fade_top := ColorRect.new()
	fade_top.size = Vector2(W, 160)
	fade_top.position = Vector2(0, 0)
	fade_top.color = Color(0.01, 0.01, 0.02, 0.95)
	fade_top.z_index = 5
	_crawl_root.add_child(fade_top)

	var fade_bot := ColorRect.new()
	fade_bot.size = Vector2(W, 80)
	fade_bot.position = Vector2(0, H - 80)
	fade_bot.color = Color(0.01, 0.01, 0.02, 0.9)
	fade_bot.z_index = 5
	_crawl_root.add_child(fade_bot)

	var text_container := Node2D.new()
	text_container.name = "TextContainer"
	_crawl_root.add_child(text_container)

	var y_offset := 0.0
	for line in STORY_LINES:
		var lbl := Label.new()
		lbl.text = line
		var is_title: bool    = (line == "T H E   L A S T   H O U R")
		var is_emphasis: bool = (line == "UNE HEURE.")
		var fs: int   = 50 if is_title else (34 if is_emphasis else 22)
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

# ── Fade overlay ───────────────────────────────────────────────────────────────

func _build_fade() -> void:
	_fade_rect = ColorRect.new()
	_fade_rect.size = Vector2(W, H)
	_fade_rect.color = Color(0, 0, 0, 1.0)
	_fade_rect.z_index = 50
	add_child(_fade_rect)
	create_tween().tween_property(_fade_rect, "color:a", 0.0, 1.2)

# ── Update loop ────────────────────────────────────────────────────────────────

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
	GlobalTimer.pause()           # suspended until camera descent ends in Main.gd
	GameManager.auto_start = true # tells Main.gd to skip the menu
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
