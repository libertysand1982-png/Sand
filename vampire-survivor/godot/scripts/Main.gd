# Main.gd — contrôleur du jeu : boucle, spawn, collisions, niveaux, états, audio.
extends Node2D

const WORLD := 4000.0
const MAX_ENEMIES := 280
const MAX_LEVEL := 99   # niveau maximum — le Seigneur du Crépuscule y attend

enum State { MENU, PLAYING, LEVELUP, PAUSED, GAMEOVER }

const ENEMY_DEF := {
	"goblin":    {"hp": 26.0,  "speed": 82.0, "dmg": 8.0,  "xp": 1, "radius": 18.0, "scale": 0.58, "bar": false},
	"flyingeye": {"hp": 40.0,  "speed": 96.0, "dmg": 10.0, "xp": 3, "radius": 17.0, "scale": 0.52, "bar": false},
	"mushroom":  {"hp": 60.0,  "speed": 52.0, "dmg": 13.0, "xp": 3, "radius": 20.0, "scale": 0.60, "bar": false},
	"skeleton":  {"hp": 160.0, "speed": 46.0, "dmg": 20.0, "xp": 7,  "radius": 22.0, "scale": 0.70, "bar": true},
	"bat":       {"hp": 30.0,  "speed": 112.0,"dmg": 9.0,  "xp": 2,  "radius": 16.0, "scale": 0.85, "bar": false},
	"demon":     {"hp": 240.0, "speed": 58.0, "dmg": 22.0, "xp": 10, "radius": 20.0, "scale": 0.62, "bar": true},
	"boss":      {"hp": 600.0, "speed": 42.0, "dmg": 30.0, "xp": 30, "radius": 42.0, "scale": 1.70, "bar": true},
	"bringer":   {"hp": 720.0, "speed": 38.0, "dmg": 34.0, "xp": 40, "radius": 46.0, "scale": 1.55, "bar": true},
	"demon1":    {"hp": 780.0, "speed": 46.0, "dmg": 34.0, "xp": 45, "radius": 38.0, "scale": 1.5,  "bar": true},
	"demon2":    {"hp": 820.0, "speed": 44.0, "dmg": 36.0, "xp": 45, "radius": 40.0, "scale": 1.5,  "bar": true},
	"demon3":    {"hp": 860.0, "speed": 48.0, "dmg": 36.0, "xp": 50, "radius": 38.0, "scale": 1.55, "bar": true},
	"dragon1":   {"hp": 980.0, "speed": 40.0, "dmg": 40.0, "xp": 55, "radius": 54.0, "scale": 1.30, "bar": true},
	"dragon2":   {"hp": 1020.0,"speed": 40.0, "dmg": 42.0, "xp": 60, "radius": 54.0, "scale": 1.30, "bar": true},
	"dragon3":   {"hp": 1060.0,"speed": 42.0, "dmg": 44.0, "xp": 65, "radius": 56.0, "scale": 1.35, "bar": true},
	"megaboss":  {"hp": 850.0, "speed": 50.0, "dmg": 42.0, "xp": 150,"radius": 66.0, "scale": 1.9,  "bar": true},
}

# Rotation des gardiens (niveaux 10..90) : sprite + patterns + nom
const BOSS_TIERS := {
	1: {"tkey": "boss",    "kind": "night",   "title": "NIGHTBORNE"},
	2: {"tkey": "bringer", "kind": "bringer", "title": "PORTEUR DE MORT"},
	3: {"tkey": "demon1",  "kind": "demon",   "title": "L'ŒIL DÉVOREUR"},
	4: {"tkey": "dragon1", "kind": "dragon",  "title": "DRAGON ÉCARLATE"},
	5: {"tkey": "demon2",  "kind": "demon",   "title": "BRUTE DÉMONIAQUE"},
	6: {"tkey": "bringer", "kind": "bringer", "title": "PORTEUR DE MORT"},
	7: {"tkey": "demon3",  "kind": "demon",   "title": "OMBRE CORNUE"},
	8: {"tkey": "dragon2", "kind": "dragon",  "title": "DRAGON D'IVOIRE"},
	9: {"tkey": "dragon3", "kind": "dragon",  "title": "DRAGON DU CRÉPUSCULE"},
}

# Améliorations de niveau. `kind`: "off"=offensif, "def"=défensif (→ marque de buff
# en haut-droite), ""=utilitaire (pas de marque). `icon` = fichier dans ui/upgrades/.
const UPGRADES := [
	# --- Offensif (marque de buff) ---
	{"id": "dmg",      "name": "Affûtage",        "desc": "+25% dégâts d'arme",         "icon": "dmg",       "kind": "off"},
	{"id": "count",    "name": "Multi-tir",       "desc": "+1 projectile",              "icon": "count",     "kind": "off"},
	{"id": "rate",     "name": "Cadence",         "desc": "-15% recharge d'arme",       "icon": "rate",      "kind": "off"},
	{"id": "pierce",   "name": "Perforation",     "desc": "traverse +1 ennemi",         "icon": "pierce",    "kind": "off"},
	{"id": "crit",     "name": "Coups critiques", "desc": "+10% chance de dégâts x2",   "icon": "crit",      "kind": "off"},
	{"id": "heavy",    "name": "Projectile lourd","desc": "+25% taille & vitesse",      "icon": "heavy",     "kind": "off"},
	{"id": "lifesteal","name": "Vampirisme",      "desc": "+2 PV par ennemi tué",       "icon": "lifesteal", "kind": "off"},
	{"id": "spell_power","name": "Maître des sorts","desc": "+25% dégâts des capacités","icon": "spell_power","kind": "off"},
	# --- Défensif (marque de buff) ---
	{"id": "hp",       "name": "Vitalité",        "desc": "+30 PV max (soigne)",        "icon": "hp",        "kind": "def"},
	{"id": "armor",    "name": "Armure",          "desc": "-8% dégâts subis",           "icon": "armor",     "kind": "def"},
	{"id": "regen",    "name": "Régénération",    "desc": "+1.5 PV / seconde",          "icon": "regen",     "kind": "def"},
	{"id": "nova",     "name": "Onde renforcée",  "desc": "+30% puissance de l'onde",   "icon": "nova",      "kind": "def"},
	# --- Utilitaire (pas de marque) ---
	{"id": "speed",    "name": "Célérité",        "desc": "+12% vitesse de déplacement","icon": "speed",     "kind": ""},
	{"id": "magnet",   "name": "Aimant",          "desc": "+35% rayon de ramassage",    "icon": "magnet",    "kind": ""},
]

# Héros jouables (sélection au début)
const HEROES := {
	"wizard": {
		"name": "Sorcier Maudit", "style": "Mage à distance — boules de feu auto",
		"frames": "wizard", "scale": 0.95, "offset_y": -16.0, "shadow_y": 16.0, "shadow_r": 18.0,
		"speed": 205.0, "maxhp": 100.0, "fire_interval": 0.85, "attack": "fireball", "dmg": 24.0,
		"skills": ["fire", "bolt", "frost", "heal", "meteor"], "ult": "arcane_storm",
		"crop": Rect2(45, 35, 60, 100),
	},
	"samurai": {
		"name": "Samurai Errant", "style": "Mêlée rapide — coups de sabre",
		"frames": "samurai", "scale": 0.85, "offset_y": -22.0, "shadow_y": 12.0, "shadow_r": 16.0,
		"speed": 250.0, "maxhp": 135.0, "fire_interval": 0.5, "attack": "melee", "dmg": 24.0,
		"skills": ["slash_sk", "dash", "whirl", "guard", "blade"], "ult": "thousand_cuts",
		"crop": Rect2(24, 12, 48, 80),
	},
	"knight": {
		"name": "Chevalier de l'Aube", "style": "Tank sacré — épée lourde & égide",
		"frames": "knight", "scale": 1.1, "offset_y": -18.0, "shadow_y": 14.0, "shadow_r": 17.0,
		"speed": 190.0, "maxhp": 170.0, "fire_interval": 0.75, "attack": "melee", "dmg": 32.0,
		"skills": ["slash_sk", "aegis", "dash", "heal", "blade"], "ult": "judgment",
		"crop": Rect2(22, 8, 52, 74),
	},
	"kobold": {
		"name": "Kobold Sauvage", "style": "Berserker féral — griffes & sang",
		"frames": "kobold", "scale": 0.9, "offset_y": -20.0, "shadow_y": 13.0, "shadow_r": 15.0,
		"speed": 265.0, "maxhp": 90.0, "fire_interval": 0.45, "attack": "melee", "dmg": 15.0,
		"skills": ["arc_wave", "blood_nova", "war_stomp", "frenzy", "whirl"], "ult": "primal_rage",
		"crop": Rect2(48, 10, 56, 84),
	},
	"gladiator": {
		"name": "Gladiateur", "style": "Champion d'arène — glaive & bouclier",
		"frames": "gladiator", "scale": 1.0, "offset_y": -22.0, "shadow_y": 15.0, "shadow_r": 17.0,
		"speed": 225.0, "maxhp": 150.0, "fire_interval": 0.6, "attack": "melee", "dmg": 27.0,
		"skills": ["slash_sk", "war_stomp", "dash", "guard", "blade"], "ult": "arena_roar",
		"crop": Rect2(40, 22, 48, 90),
	},
}

# Capacités (nom, icône dans assets/spells/, recharge)
const SKILLS := {
	"fire":       {"name": "Boule de feu",      "icon": "fire",      "cd": 3.5},
	"bolt":       {"name": "Éclair",            "icon": "lightning", "cd": 6.0},
	"frost":      {"name": "Gel",               "icon": "frost",     "cd": 10.0},
	"heal":       {"name": "Soin",              "icon": "heal",      "cd": 18.0},
	"meteor":     {"name": "Météore",           "icon": "meteor",    "cd": 7.0},
	"slash_sk":   {"name": "Entaille",          "icon": "slash",     "cd": 2.0},
	"dash":       {"name": "Ruée",              "icon": "dash",      "cd": 4.0},
	"whirl":      {"name": "Tourbillon",        "icon": "whirl",     "cd": 6.0},
	"guard":      {"name": "Garde",             "icon": "guard",     "cd": 14.0},
	"blade":      {"name": "Lame volante",      "icon": "blade",     "cd": 3.0},
	"aegis":      {"name": "Égide sacrée",      "icon": "aegis",     "cd": 16.0},
	"arc_wave":   {"name": "Croissant sanglant","icon": "arcwave",   "cd": 5.0},
	"blood_nova": {"name": "Nova écarlate",     "icon": "bloodnova", "cd": 9.0},
	"war_stomp":  {"name": "Piétinement",       "icon": "stomp",     "cd": 7.0},
	"frenzy":     {"name": "Frénésie",          "icon": "frenzy",    "cd": 14.0},
	"arcane_storm":  {"name": "Tempête arcanique",     "icon": "ult_wizard",  "cd": 0.0},
	"thousand_cuts": {"name": "Mille coupures",        "icon": "ult_samurai", "cd": 0.0},
	"judgment":      {"name": "Jugement",              "icon": "judgment",    "cd": 0.0},
	"primal_rage":   {"name": "Rage primordiale",      "icon": "rage",        "cd": 0.0},
	"arena_roar":    {"name": "Rugissement de l'arène","icon": "roar",        "cd": 0.0},
}

var state: int = State.MENU
var time := 0.0
var elapsed := 0.0
var kills := 0
var spawn_timer := 0.0
var level_queue := 0

var player: VSPlayer
var world: Node2D
var gem_layer: Node2D
var proj_layer: Node2D
var fx_layer: Node2D
var ground: Sprite2D
var sfx: VSSfx
var hud: VSHud

var enemies: Array[VSEnemy] = []
var projectiles: Array[VSProjectile] = []
var gems: Array[VSGem] = []
var floats: Array = []
var enemy_frames: Dictionary = {}
var spells: Array = []
var items: Array = []
var item_tex: Dictionary = {}
var hero_frames: Dictionary = {}
var current_hero := "wizard"
var power := 0.0
var buffs: Dictionary = {}   # id d'amélioration off/def -> nombre de stacks
var ult_icon: Texture2D
var bosses_spawned := 0
var final_spawned := false
var enemy_shots: Array = []
var zones: Array = []
var spellfx_frames: SpriteFrames
var intro_seen := false
var _last_score := 0
var _last_time := "00:00"

# ============================================================
func _ready() -> void:
	randomize()
	_setup_input()

	# Animations
	enemy_frames = {
		"goblin":    _enemy_sf("res://assets/monsters/goblin/run.png", 8, "res://assets/monsters/goblin/death.png", 4),
		"flyingeye": _enemy_sf("res://assets/monsters/flyingeye/flight.png", 8, "res://assets/monsters/flyingeye/death.png", 4),
		"mushroom":  _enemy_sf("res://assets/monsters/mushroom/run.png", 8, "res://assets/monsters/mushroom/death.png", 4),
		"skeleton":  _enemy_sf("res://assets/monsters/skeleton/walk.png", 4, "res://assets/monsters/skeleton/death.png", 4),
		"bat":       _enemy_sf("res://assets/monsters/bat/fly.png", 9, "res://assets/monsters/bat/death.png", 12, 64),
		"boss":      _boss_sf(),
		"bringer":   _bringer_sf(),
		"demon1":    _enemy_sf("res://assets/monsters/demon1/walk.png", 5,  "res://assets/monsters/demon1/death.png", 3, 128),
		"demon2":    _enemy_sf("res://assets/monsters/demon2/walk.png", 12, "res://assets/monsters/demon2/death.png", 3, 128),
		"demon3":    _enemy_sf("res://assets/monsters/demon3/walk.png", 12, "res://assets/monsters/demon3/death.png", 5, 128),
		"dragon1":   _enemy_sf("res://assets/boss/dragon1_walk.png", 12, "res://assets/boss/dragon1_death.png", 3, 256),
		"dragon2":   _enemy_sf("res://assets/boss/dragon2_walk.png", 12, "res://assets/boss/dragon2_death.png", 3, 256),
		"dragon3":   _enemy_sf("res://assets/boss/dragon3_walk.png", 12, "res://assets/boss/dragon3_death.png", 3, 256),
		"megaboss":  _enemy_sf("res://assets/boss/megaboss_walk.png", 8, "res://assets/boss/megaboss_death.png", 8, 256),
	}
	enemy_frames["demon"] = enemy_frames["demon3"]   # le démon "de base" réutilise l'Ombre cornue
	item_tex = {
		"weapon": load("res://assets/items/weapon.png"),
		"armor":  load("res://assets/items/armor.png"),
		"potion": load("res://assets/items/potion.png"),
	}

	hero_frames = {
		"wizard":  _wizard_sf(),
		"samurai": _samurai_sf(),
		"knight":  _knight_sf(),
		"kobold":  _kobold_sf(),
		"gladiator": _gladiator_sf(),
	}
	_build_spells(current_hero)

	# VFX du sort des boss (explosion sombre du Porteur de Mort)
	spellfx_frames = SpriteFrames.new()
	_add_sheet(spellfx_frames, "boom", load("res://assets/boss/bringer_spell.png"), 16, 140, 20.0, false, 93)

	# Sol
	ground = Sprite2D.new()
	ground.texture = load("res://assets/bg/cave_floor.png")
	ground.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	ground.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	ground.centered = false
	ground.region_enabled = true
	ground.region_rect = Rect2(0, 0, WORLD, WORLD)
	ground.z_index = -100
	add_child(ground)

	gem_layer = Node2D.new()
	gem_layer.z_index = -1
	add_child(gem_layer)
	world = Node2D.new()
	world.y_sort_enabled = true
	add_child(world)
	proj_layer = Node2D.new()
	proj_layer.z_index = 10
	add_child(proj_layer)
	fx_layer = Node2D.new()
	fx_layer.z_index = 30
	add_child(fx_layer)

	sfx = VSSfx.new()
	add_child(sfx)

	player = VSPlayer.new()
	world.add_child(player)
	player.set_frames(hero_frames["wizard"])
	player.cam.limit_left = 0
	player.cam.limit_top = 0
	player.cam.limit_right = int(WORLD)
	player.cam.limit_bottom = int(WORLD)
	player.position = Vector2(WORLD / 2.0, WORLD / 2.0)
	player.visible = false

	hud = VSHud.new()
	add_child(hud)
	hud.build()
	hud.play_pressed.connect(_on_play)
	hud.retry_pressed.connect(_on_retry)
	hud.to_menu_pressed.connect(_to_menu)
	hud.upgrade_chosen.connect(_apply_upgrade)
	hud.sfx_changed.connect(sfx.set_sfx_volume)
	hud.music_changed.connect(sfx.set_music_volume)
	hud.hero_selected.connect(_on_hero_selected)
	hud.name_submitted.connect(_on_name_submitted)
	hud.intro_done.connect(_on_intro_done)
	hud.history_pressed.connect(_on_history)
	hud.show_menu()
	state = State.MENU
	sfx.play_music("menu")

	# Test automatisé : l'argument `--smoke` (ligne de commande) auto-démarre une partie.
	if "--smoke" in OS.get_cmdline_user_args():
		start_game.call_deferred()

func _setup_input() -> void:
	_mk("vs_up", [KEY_W, KEY_Z, KEY_UP])
	_mk("vs_down", [KEY_S, KEY_DOWN])
	_mk("vs_left", [KEY_A, KEY_Q, KEY_LEFT])
	_mk("vs_right", [KEY_D, KEY_RIGHT])
	_mk("vs_pause", [KEY_P, KEY_ESCAPE])
	_mk("vs_mute", [KEY_M])
	_mk("vs_spell1", [KEY_1, KEY_KP_1])
	_mk("vs_spell2", [KEY_2, KEY_KP_2])
	_mk("vs_spell3", [KEY_3, KEY_KP_3])
	_mk("vs_spell4", [KEY_4, KEY_KP_4])
	_mk("vs_spell5", [KEY_5, KEY_KP_5])
	_mk("vs_ult", [KEY_6, KEY_KP_6, KEY_SPACE])
	# Manette : stick gauche pour bouger, boutons pour les capacités
	_pad_axis("vs_left", 0, -1.0)
	_pad_axis("vs_right", 0, 1.0)
	_pad_axis("vs_up", 1, -1.0)
	_pad_axis("vs_down", 1, 1.0)
	_pad_btn("vs_spell1", JOY_BUTTON_A)
	_pad_btn("vs_spell2", JOY_BUTTON_B)
	_pad_btn("vs_spell3", JOY_BUTTON_X)
	_pad_btn("vs_spell4", JOY_BUTTON_Y)
	_pad_btn("vs_spell5", JOY_BUTTON_LEFT_SHOULDER)
	_pad_btn("vs_ult", JOY_BUTTON_RIGHT_SHOULDER)
	_pad_btn("vs_pause", JOY_BUTTON_START)

func _mk(action: String, keys: Array) -> void:
	if InputMap.has_action(action):
		InputMap.erase_action(action)
	InputMap.add_action(action)
	for k in keys:
		var ev := InputEventKey.new()
		ev.keycode = k
		InputMap.action_add_event(action, ev)

func _pad_axis(action: String, axis: int, dir: float) -> void:
	var ev := InputEventJoypadMotion.new()
	ev.axis = axis
	ev.axis_value = dir
	InputMap.action_add_event(action, ev)

func _pad_btn(action: String, btn: int) -> void:
	var ev := InputEventJoypadButton.new()
	ev.button_index = btn
	InputMap.action_add_event(action, ev)

# ============================================================
func _clear_entities() -> void:
	for c in world.get_children():
		if c is VSEnemy:
			c.queue_free()
	for c in proj_layer.get_children():
		c.queue_free()
	for c in gem_layer.get_children():
		c.queue_free()
	for c in fx_layer.get_children():
		c.queue_free()
	enemies.clear()
	projectiles.clear()
	gems.clear()
	items.clear()
	floats.clear()
	enemy_shots.clear()
	zones.clear()

func _on_play() -> void:
	sfx.play("click", 0.5)
	if intro_seen:
		_open_select()
	else:
		intro_seen = true
		hud.show_intro(_intro_slides(), false)

func _on_intro_done(to_menu: bool) -> void:
	if to_menu:
		hud.show_menu()
	else:
		_open_select()

func _on_history() -> void:
	sfx.play("click", 0.5)
	hud.show_intro(_intro_slides(), true)

func _open_select() -> void:
	var data: Array = []
	for hid in HEROES:
		var h: Dictionary = HEROES[hid]
		var sk := ""
		for sid in h["skills"]:
			sk += (" · " if sk != "" else "") + SKILLS[sid]["name"]
		# portrait : 1re frame d'idle recadrée sur le personnage
		var base: AtlasTexture = hero_frames[hid].get_frame_texture("idle", 0)
		var pt := AtlasTexture.new()
		pt.atlas = base.atlas
		var cr: Rect2 = h["crop"]
		pt.region = Rect2(base.region.position + cr.position, cr.size)
		data.append({
			"id": hid, "name": h["name"], "style": h["style"],
			"skills": sk, "ult": SKILLS[h["ult"]]["name"], "tex": pt,
		})
	hud.show_select(data)

func _on_hero_selected(hero_id: String) -> void:
	start_game(hero_id)

func _on_retry() -> void:
	start_game(current_hero)

func start_game(hero_id := current_hero) -> void:
	current_hero = hero_id
	var h: Dictionary = HEROES[hero_id]
	sfx.play("click", 0.5)
	_clear_entities()
	elapsed = 0.0
	kills = 0
	spawn_timer = 0.0
	level_queue = 0
	bosses_spawned = 0
	final_spawned = false
	power = 0.0
	buffs.clear()
	hud.set_buffs([])
	player.set_frames(hero_frames[h["frames"]])
	player.setup_hero(h["scale"], h["offset_y"], h["shadow_y"], h["shadow_r"])
	_build_spells(hero_id)
	player.reset(Vector2(WORLD / 2.0, WORLD / 2.0))
	player.maxhp = h["maxhp"]
	player.hp = h["maxhp"]
	player.speed = h["speed"]
	player.fire_interval = h["fire_interval"]
	player.proj_damage = h["dmg"]
	player.visible = true
	hud.hide_overlays()
	hud.show_hud(true)
	sfx.play_music("game")
	state = State.PLAYING

func _build_spells(hero_id: String) -> void:
	spells = []
	var hs: Array = HEROES[hero_id]["skills"]
	for i in hs.size():
		var sid: String = hs[i]
		var sk: Dictionary = SKILLS[sid]
		spells.append({
			"id": sid, "name": sk["name"], "key": str(i + 1), "cd": sk["cd"], "left": 0.0,
			"icon": load("res://assets/spells/%s.png" % sk["icon"]),
		})
	ult_icon = load("res://assets/spells/%s.png" % SKILLS[HEROES[hero_id]["ult"]]["icon"])

func _to_menu() -> void:
	state = State.MENU
	_clear_entities()
	player.visible = false
	hud.show_hud(false)
	hud.show_menu()
	sfx.play_music("menu")

func _unhandled_input(event: InputEvent) -> void:
	if hud.intro_active():
		if (event is InputEventKey and event.pressed and not event.echo) \
				or (event is InputEventMouseButton and event.pressed):
			hud.intro_next()
		return
	if event.is_action_pressed("vs_pause"):
		_toggle_pause()
	elif event.is_action_pressed("vs_mute"):
		sfx.set_muted(not sfx.muted)
		hud.set_muted(sfx.muted)
	elif state == State.PLAYING:
		if event.is_action_pressed("vs_ult"):
			_cast_ult()
			return
		for i in spells.size():
			if event.is_action_pressed("vs_spell" + str(i + 1)):
				_try_cast(i)
				break

func _toggle_pause() -> void:
	if state == State.PLAYING:
		state = State.PAUSED
		hud.show_pause(true)
	elif state == State.PAUSED:
		state = State.PLAYING
		hud.show_pause(false)

# ============================================================
func _process(delta: float) -> void:
	time += delta
	if state == State.PLAYING:
		_update_playing(delta)

func _update_playing(delta: float) -> void:
	var p := player
	elapsed += delta
	for sp in spells:
		if sp["left"] > 0.0:
			sp["left"] = maxf(0.0, sp["left"] - delta)

	# Frénésie (buff kobold) : tout s'accélère
	var frenzy := p.frenzy_timer > 0.0
	if frenzy:
		p.frenzy_timer -= delta

	# Déplacement + animation
	var dir := Input.get_vector("vs_left", "vs_right", "vs_up", "vs_down")
	var spd := p.speed * (1.25 if frenzy else 1.0)
	p.position.x = clampf(p.position.x + dir.x * spd * delta, 24.0, WORLD - 24.0)
	p.position.y = clampf(p.position.y + dir.y * spd * delta, 24.0, WORLD - 24.0)
	var moving := dir.length() > 0.01
	if dir.x < 0.0:
		p.facing = -1
	elif dir.x > 0.0:
		p.facing = 1
	p.anim.flip_h = p.facing < 0
	p.anim.play("run" if moving else "idle")
	if moving:
		p.step_timer -= delta
		if p.step_timer <= 0.0:
			sfx.play("step", 0.10)
			p.step_timer = 0.33
	if p.invuln > 0.0:
		p.invuln -= delta
	# Régénération passive (carte Régénération)
	if p.regen > 0.0 and p.hp < p.maxhp:
		p.hp = minf(p.maxhp, p.hp + p.regen * delta)
	p.anim.modulate.a = 0.45 if (p.invuln > 0.0 and int(time * 20.0) % 2 == 0) else 1.0
	p.anim.self_modulate = Color(1.3, 0.85, 0.85) if frenzy else Color(1, 1, 1)

	# Arme automatique (2x plus rapide sous Frénésie)
	p.fire_cd -= delta * (2.0 if frenzy else 1.0)
	if p.fire_cd <= 0.0 and enemies.size() > 0:
		_fire()
		p.fire_cd = p.fire_interval

	_spawns(delta)
	_update_enemies(delta)
	_update_bosses(delta)
	_update_projectiles(delta)
	_update_enemy_shots(delta)
	_update_zones(delta)
	_update_gems(delta)
	_update_items(delta)
	_cull_enemies()
	_update_floats(delta)

	# Boss majeurs tous les 10 niveaux (10, 20, ..., 90)
	while player.level >= (bosses_spawned + 1) * 10 and bosses_spawned < 9:
		bosses_spawned += 1
		_spawn_boss(bosses_spawned)
	# Niveau 99 : le Seigneur du Crépuscule en personne
	if player.level >= MAX_LEVEL and not final_spawned:
		final_spawned = true
		_spawn_final_boss()

	if level_queue > 0 and state == State.PLAYING:
		_open_levelup()

	if p.hp <= 0.0:
		_end_run(false)
		return

	_refresh_hud()

# ----- Arme -----
func _fire() -> void:
	var p := player
	if HEROES[current_hero]["attack"] == "melee":
		_melee_attack()
		return
	var best: VSEnemy = null
	var bd := INF
	for e in enemies:
		var d := p.position.distance_squared_to(e.position)
		if d < bd:
			bd = d
			best = e
	if best == null:
		return
	var base_a := (best.position - p.position).angle()
	var n := p.proj_count
	var spread := 0.22
	var start := base_a - spread * (n - 1) / 2.0
	for i in n:
		var a := start + spread * i
		var pr := VSProjectile.new()
		var dmg := p.proj_damage
		if randf() < p.crit_chance:
			dmg *= 2.0   # coup critique
		pr.setup(p.position, Vector2.from_angle(a), p.proj_speed, dmg, p.pierce, p.proj_size)
		proj_layer.add_child(pr)
		projectiles.append(pr)
	sfx.play("magic", 0.30)

# ----- Spawn -----
func _spawns(delta: float) -> void:
	spawn_timer -= delta
	if spawn_timer > 0.0:
		return
	var minutes := elapsed / 60.0
	spawn_timer = maxf(0.2, 1.15 - minutes * 0.16)
	var batch := 1 + int(elapsed / 45.0)
	for i in batch:
		if enemies.size() >= MAX_ENEMIES:
			break
		_spawn_one()

func _pick_type() -> String:
	var t := elapsed
	var r := randf()
	if t < 25.0:
		return "goblin" if r < 0.7 else "bat"
	elif t < 70.0:
		if r < 0.45: return "goblin"
		elif r < 0.7: return "bat"
		else: return "flyingeye"
	elif t < 140.0:
		if r < 0.3: return "goblin"
		elif r < 0.5: return "bat"
		elif r < 0.7: return "flyingeye"
		else: return "mushroom"
	elif t < 240.0:
		if r < 0.2: return "goblin"
		elif r < 0.4: return "bat"
		elif r < 0.58: return "flyingeye"
		elif r < 0.78: return "mushroom"
		else: return "skeleton"
	else:
		# tard dans la nuit : les démons rejoignent la horde
		if r < 0.15: return "goblin"
		elif r < 0.33: return "bat"
		elif r < 0.48: return "flyingeye"
		elif r < 0.65: return "mushroom"
		elif r < 0.85: return "skeleton"
		else: return "demon"

# Les ennemis grossissent avec le temps ET avec le niveau du héros.
func _hp_scale() -> float:
	return (1.0 + (elapsed / 60.0) * 0.22) * (1.0 + (player.level - 1) * 0.02)

func _dmg_scale() -> float:
	return 1.0 + (player.level - 1) * 0.01

func _spawn_one() -> void:
	var tkey := _pick_type()
	var vsize := get_viewport_rect().size
	var radius := maxf(vsize.x, vsize.y) / 2.0 + 80.0
	var ang := randf() * TAU
	var pos := player.position + Vector2.from_angle(ang) * radius
	pos.x = clampf(pos.x, 20.0, WORLD - 20.0)
	pos.y = clampf(pos.y, 20.0, WORLD - 20.0)

	var e := VSEnemy.new()
	e.setup(tkey, pos, _hp_scale(), enemy_frames[tkey], ENEMY_DEF[tkey])
	e.dmg *= _dmg_scale()
	world.add_child(e)
	enemies.append(e)

# ----- Boss majeurs (tous les 10 niveaux) + objets -----
func _boss_spawn_pos(margin: float) -> Vector2:
	var vsize := get_viewport_rect().size
	var radius := maxf(vsize.x, vsize.y) / 2.0 + 90.0
	var ang := randf() * TAU
	var pos := player.position + Vector2.from_angle(ang) * radius
	pos.x = clampf(pos.x, margin, WORLD - margin)
	pos.y = clampf(pos.y, margin, WORLD - margin)
	return pos

func _spawn_boss(tier: int) -> void:
	var bt: Dictionary = BOSS_TIERS[tier]
	var tkey: String = bt["tkey"]
	var e := VSEnemy.new()
	var hp_scale := _hp_scale() * (0.6 + 0.55 * tier)
	e.setup(tkey, _boss_spawn_pos(40.0), hp_scale, enemy_frames[tkey], ENEMY_DEF[tkey])
	e.is_boss = true
	e.tier = tier
	e.boss_kind = bt["kind"]
	e.dmg *= 1.0 + tier * 0.12
	e.speed += tier * 2.0
	e.boss_title = "%s — GARDIEN DU NIVEAU %d" % [bt["title"], tier * 10]
	world.add_child(e)
	enemies.append(e)
	_spawn_text(player.position + Vector2(0, -120), "BOSS !", Color(0.85, 0.35, 1.0))
	sfx.play("buff", 0.7)

func _spawn_final_boss() -> void:
	var e := VSEnemy.new()
	e.setup("megaboss", _boss_spawn_pos(80.0), _hp_scale() * 9.0, enemy_frames["megaboss"], ENEMY_DEF["megaboss"])
	e.is_boss = true
	e.tier = 10
	e.boss_kind = "final"
	e.boss_title = "☠ SEIGNEUR DU CRÉPUSCULE ☠"
	e.dmg *= 1.4
	world.add_child(e)
	enemies.append(e)
	_spawn_text(player.position + Vector2(0, -130), "LE SEIGNEUR DU CRÉPUSCULE !", Color(1.0, 0.3, 0.9))
	sfx.play("buff", 1.0)
	sfx.play("lightning_cast", 0.8)

func _drop_item(pos: Vector2) -> void:
	var kinds := ["weapon", "armor", "potion"]
	var k: String = kinds[randi() % kinds.size()]
	var it := VSItem.new()
	it.setup(pos, k, item_tex[k])
	gem_layer.add_child(it)
	items.append(it)

func _update_items(_delta: float) -> void:
	var p := player
	for i in range(items.size() - 1, -1, -1):
		var it: VSItem = items[i]
		if p.position.distance_to(it.position) < 34.0:
			_apply_item(it.kind)
			it.queue_free()
			items.remove_at(i)

func _apply_item(kind: String) -> void:
	var p := player
	match kind:
		"weapon":
			p.proj_damage = round(p.proj_damage * 1.3)
			_spawn_text(p.position + Vector2(0, -46), "ARME ! +30% dégâts", Color(1.0, 0.7, 0.3))
		"armor":
			p.maxhp += 40.0
			p.hp = minf(p.maxhp, p.hp + 40.0)
			_spawn_text(p.position + Vector2(0, -46), "ARMURE ! +40 PV max", Color(0.55, 0.8, 1.0))
		"potion":
			p.hp = p.maxhp
			_spawn_text(p.position + Vector2(0, -46), "POTION ! PV au max", Color(0.55, 1.0, 0.55))
	sfx.play("blessing", 0.6)

# ----- Patterns des boss : à esquiver ! -----
func _update_bosses(delta: float) -> void:
	for e in enemies:
		if not is_instance_valid(e) or e.dead or not e.is_boss:
			continue
		e.pat_a -= delta
		e.pat_b -= delta
		var t := e.tier
		match e.boss_kind:
			"night":
				# anneaux de projectiles + tirs visés
				if e.pat_a <= 0.0:
					e.pat_a = maxf(2.4, 5.2 - 0.3 * t)
					_boss_ring(e, 8 + 2 * t, 130.0 + 9.0 * t)
				if e.pat_b <= 0.0:
					e.pat_b = maxf(1.6, 3.4 - 0.15 * t)
					_boss_aimed(e, 3, 230.0 + 10.0 * t)
			"bringer":
				# zones d'explosion télégraphiées + invocations
				if e.pat_a <= 0.0:
					e.pat_a = maxf(3.2, 6.0 - 0.25 * t)
					_boss_zones(e, 2 + int(t / 3.0), 90.0)
				if e.pat_b <= 0.0:
					e.pat_b = 8.0
					_boss_summon(e, 3 + int(t / 2.0))
			"demon":
				# volées de tirs visés + invocations de la horde
				if e.pat_a <= 0.0:
					e.pat_a = maxf(1.8, 3.0 - 0.12 * t)
					_boss_aimed(e, 4, 250.0 + 8.0 * t)
				if e.pat_b <= 0.0:
					e.pat_b = 9.0
					_boss_summon(e, 2 + int(t / 3.0))
			"dragon":
				# souffle enflammé (éventail d'orbes lourds) + nappes de feu
				if e.pat_a <= 0.0:
					e.pat_a = maxf(2.4, 4.0 - 0.15 * t)
					_boss_breath(e, 6, 200.0 + 6.0 * t)
				if e.pat_b <= 0.0:
					e.pat_b = 6.5
					_boss_zones(e, 3, 85.0)
			"final":
				# tout à la fois, sans pitié
				if e.pat_a <= 0.0:
					e.pat_a = 3.0
					var pick := randi() % 3
					if pick == 0:
						_boss_ring(e, 22, 200.0)
					elif pick == 1:
						_boss_zones(e, 4, 95.0)
					else:
						_boss_breath(e, 8, 240.0)
				if e.pat_b <= 0.0:
					e.pat_b = 2.6
					_boss_aimed(e, 5, 300.0)

func _boss_ring(e: VSEnemy, n: int, spd: float) -> void:
	var off := randf() * TAU
	for i in n:
		var a := off + TAU * float(i) / float(n)
		var s := VSEnemyShot.new()
		s.setup(e.position, Vector2.from_angle(a), spd, e.dmg * 0.45)
		proj_layer.add_child(s)
		enemy_shots.append(s)
	sfx.play("magic", 0.25)

func _boss_aimed(e: VSEnemy, n: int, spd: float) -> void:
	var base_a := (player.position - e.position).angle()
	var spread := 0.22
	var start := base_a - spread * (n - 1) / 2.0
	for i in n:
		var s := VSEnemyShot.new()
		s.setup(e.position, Vector2.from_angle(start + spread * i), spd, e.dmg * 0.5, 10.0)
		proj_layer.add_child(s)
		enemy_shots.append(s)
	sfx.play("lightning_cast", 0.2)

# Souffle de dragon : éventail serré de gros orbes lents — à esquiver de côté.
func _boss_breath(e: VSEnemy, n: int, spd: float) -> void:
	var base_a := (player.position - e.position).angle()
	var arc := 0.9
	for i in n:
		var a := base_a - arc / 2.0 + arc * float(i) / float(maxi(1, n - 1))
		var s := VSEnemyShot.new()
		s.setup(e.position, Vector2.from_angle(a), spd, e.dmg * 0.55, 14.0)
		proj_layer.add_child(s)
		enemy_shots.append(s)
	sfx.play("fire_cast", 0.4)

func _boss_zones(e: VSEnemy, k: int, r: float) -> void:
	for i in k:
		var pos := player.position
		if i > 0:
			pos += Vector2.from_angle(randf() * TAU) * randf_range(50.0, 180.0)
		pos.x = clampf(pos.x, 30.0, WORLD - 30.0)
		pos.y = clampf(pos.y, 30.0, WORLD - 30.0)
		var z := VSDangerZone.new()
		z.setup(pos, r, 1.0, e.dmg * 0.9)
		fx_layer.add_child(z)
		zones.append(z)
	sfx.play("buff", 0.35)

func _boss_summon(e: VSEnemy, n: int) -> void:
	for i in n:
		if enemies.size() >= MAX_ENEMIES:
			break
		var tkey := _pick_type()
		var pos := e.position + Vector2.from_angle(randf() * TAU) * randf_range(60.0, 130.0)
		pos.x = clampf(pos.x, 20.0, WORLD - 20.0)
		pos.y = clampf(pos.y, 20.0, WORLD - 20.0)
		var m := VSEnemy.new()
		m.setup(tkey, pos, _hp_scale(), enemy_frames[tkey], ENEMY_DEF[tkey])
		m.dmg *= _dmg_scale()
		world.add_child(m)
		enemies.append(m)
	_spawn_text(e.position + Vector2(0, -e.radius * 2.0), "Invocation !", Color(0.8, 0.4, 1.0))
	sfx.play("buff", 0.4)

func _spawn_spellfx(pos: Vector2) -> void:
	var fx := AnimatedSprite2D.new()
	fx.sprite_frames = spellfx_frames
	fx.position = pos + Vector2(0, -26.0)
	fx.scale = Vector2(1.7, 1.7)
	fx.z_index = 40
	fx_layer.add_child(fx)
	fx.play("boom")
	fx.animation_finished.connect(fx.queue_free)

func _update_enemy_shots(delta: float) -> void:
	var p := player
	for i in range(enemy_shots.size() - 1, -1, -1):
		var s: VSEnemyShot = enemy_shots[i]
		s.position += s.vel * delta
		s.life -= delta
		var sp := s.position
		if s.life <= 0.0 or sp.x < -60.0 or sp.y < -60.0 or sp.x > WORLD + 60.0 or sp.y > WORLD + 60.0:
			s.queue_free()
			enemy_shots.remove_at(i)
			continue
		if p.invuln <= 0.0 and sp.distance_to(p.position) <= s.radius + p.radius:
			var dmg := s.dmg * (1.0 - p.dmg_reduction)
			p.hp -= dmg
			p.invuln = 0.6
			sfx.play("hurt", 0.4)
			_spawn_text(p.position + Vector2(0, -34), "-" + str(int(dmg)), Color(1, 0.42, 0.42))
			s.queue_free()
			enemy_shots.remove_at(i)

func _update_zones(delta: float) -> void:
	var p := player
	for i in range(zones.size() - 1, -1, -1):
		var z: VSDangerZone = zones[i]
		if not is_instance_valid(z):
			zones.remove_at(i)
			continue
		if z.tick(delta):
			# BOOM
			_burst(z.position, z.radius, Color(1.0, 0.45, 0.3), Color(1.0, 0.2, 0.1))
			_spawn_spellfx(z.position)
			sfx.play("fire_cast", 0.45)
			if p.invuln <= 0.0 and p.position.distance_to(z.position) <= z.radius + p.radius:
				var dmg := z.dmg * (1.0 - p.dmg_reduction)
				p.hp -= dmg
				p.invuln = 0.7
				sfx.play("hurt", 0.45)
				_spawn_text(p.position + Vector2(0, -34), "-" + str(int(dmg)), Color(1, 0.42, 0.42))
			z.queue_free()
			zones.remove_at(i)

# ----- Ennemis -----
func _update_enemies(delta: float) -> void:
	var p := player
	for e in enemies:
		if not is_instance_valid(e) or e.dead:
			continue
		var sp_mul := 1.0
		if e.slow_timer > 0.0:
			e.slow_timer -= delta
			sp_mul = 0.45
		var to := p.position - e.position
		var d := to.length()
		if d > 0.001:
			e.position += to / d * e.speed * sp_mul * delta
		e.anim.flip_h = to.x < 0.0

		var punch := 1.0
		if e.hitflash > 0.0:
			e.hitflash -= delta
			var tt := clampf(e.hitflash / 0.12, 0.0, 1.0)
			punch = lerpf(1.0, 1.18, tt)
			e.anim.self_modulate = Color(1, 1, 1).lerp(Color(2.2, 2.2, 2.2), tt)
		elif e.slow_timer > 0.0:
			e.anim.self_modulate = Color(0.6, 0.8, 1.25)   # teinte gelée
		else:
			e.anim.self_modulate = Color(1, 1, 1)
		e.anim.scale = Vector2(e.disp_scale * punch, e.disp_scale * punch)
		if e.show_bar:
			e.queue_redraw()

		if d < e.radius + p.radius and p.invuln <= 0.0:
			var dmg := e.dmg * (1.0 - p.dmg_reduction)
			p.hp -= dmg
			p.invuln = 0.6
			sfx.play("hurt", 0.4)
			_spawn_text(p.position + Vector2(0, -34), "-" + str(int(dmg)), Color(1, 0.42, 0.42))

func _cull_enemies() -> void:
	for i in range(enemies.size() - 1, -1, -1):
		if not is_instance_valid(enemies[i]) or enemies[i].dead:
			enemies.remove_at(i)

# ----- Projectiles -----
func _update_projectiles(delta: float) -> void:
	for i in range(projectiles.size() - 1, -1, -1):
		var pr: VSProjectile = projectiles[i]
		pr.position += pr.vel * delta
		pr.life -= delta
		var pp := pr.position
		if pr.life <= 0.0 or pp.x < -50.0 or pp.y < -50.0 or pp.x > WORLD + 50.0 or pp.y > WORLD + 50.0:
			pr.queue_free()
			projectiles.remove_at(i)
			continue
		for e in enemies:
			if not is_instance_valid(e) or e.dead or pr.hitset.has(e):
				continue
			var rr := e.radius + pr.size
			if pp.distance_squared_to(e.position) <= rr * rr:
				pr.hitset[e] = true
				e.hp -= pr.dmg
				e.hitflash = 0.12
				_spawn_text(e.position + Vector2(0, -e.radius * 1.6), str(int(pr.dmg)), Color(1, 0.91, 0.66))
				sfx.play("hit", 0.12)
				if e.hp <= 0.0:
					_kill_enemy(e)
				pr.hits_left -= 1
				if pr.hits_left <= 0:
					pr.queue_free()
					projectiles.remove_at(i)
					break

func _kill_enemy(e: VSEnemy) -> void:
	if e.dead:
		return
	e.dead = true
	kills += 1
	power = minf(1.0, power + (0.25 if e.is_boss else 0.045))
	# Vampirisme (carte)
	if player.heal_on_kill > 0.0 and player.hp < player.maxhp:
		player.hp = minf(player.maxhp, player.hp + player.heal_on_kill)
	var g := VSGem.new()
	g.setup(e.position, e.xp)
	gem_layer.add_child(g)
	gems.append(g)
	if e.is_boss:
		_drop_item(e.position)
		if e.boss_kind == "final":
			call_deferred("_end_run", true)
	e.die()   # joue l'animation de mort puis se libère

# ----- Gemmes -----
func _update_gems(delta: float) -> void:
	var p := player
	var gained := 0
	var collected := 0
	for i in range(gems.size() - 1, -1, -1):
		var g: VSGem = gems[i]
		var to := p.position - g.position
		var d := to.length()
		if d < p.pickup:
			var pull := clampf(360.0 + (p.pickup - d) * 6.0, 360.0, 1100.0)
			g.position += to / maxf(d, 0.001) * pull * delta
		if d < 18.0:
			gained += g.value
			collected += 1
			g.queue_free()
			gems.remove_at(i)
	if collected > 0:
		sfx.play("coins", 0.3)
		_add_xp(gained)

func _add_xp(amount: int) -> void:
	var p := player
	if p.level >= MAX_LEVEL:
		return
	var leveled := false
	p.xp += amount
	while p.xp >= p.xp_to_next and p.level < MAX_LEVEL:
		p.xp -= p.xp_to_next
		p.level += 1
		p.xp_to_next = 5 + p.level * 3
		# le héros se renforce à chaque niveau (les ennemis aussi…)
		p.maxhp += 2.0
		p.hp = minf(p.maxhp, p.hp + 2.0)
		p.proj_damage *= 1.015
		p.speed *= 1.002
		level_queue += 1
		leveled = true
	if p.level >= MAX_LEVEL:
		p.xp = 0
	if leveled:
		_cast_nova()   # sort lancé à la montée de niveau

# Onde arcanique : dégâts + repoussée sur tous les monstres autour, à chaque niveau.
func _cast_nova() -> void:
	var p := player
	var radius := (200.0 + p.level * 6.0) * p.nova_radius_mul
	var dmg := (20.0 + p.level * 8.0) * p.nova_dmg_mul
	var nova := VSNova.new()
	nova.position = p.position
	nova.max_r = radius
	fx_layer.add_child(nova)
	sfx.play("buff", 0.6)
	for e in enemies:
		if not is_instance_valid(e) or e.dead:
			continue
		var to := e.position - p.position
		var d := to.length()
		if d <= radius:
			var dir := to / maxf(d, 0.001)
			var kb := 70.0 * (1.0 - d / radius)
			e.position.x = clampf(e.position.x + dir.x * kb, 20.0, WORLD - 20.0)
			e.position.y = clampf(e.position.y + dir.y * kb, 20.0, WORLD - 20.0)
			e.hitflash = 0.12
			e.hp -= dmg
			_spawn_text(e.position + Vector2(0, -e.radius * 1.6), str(int(dmg)), Color(0.7, 0.9, 1.0))
			if e.hp <= 0.0:
				_kill_enemy(e)

# ----- Sorts actifs (touches 1..5 + ultime) -----
func _wheel_data() -> Dictionary:
	var out: Array = []
	for sp in spells:
		out.append({
			"icon": sp["icon"], "key": sp["key"], "left": sp["left"],
			"frac": (sp["left"] / sp["cd"]) if sp["cd"] > 0.0 else 0.0,
			"ready": sp["left"] <= 0.0,
		})
	return {
		"slots": out, "power": power, "ult": {"icon": ult_icon, "key": "6"},
		"hp": player.hp / player.maxhp,
		"hp_text": "%d / %d" % [maxi(0, int(ceil(player.hp))), int(player.maxhp)],
	}

func _try_cast(i: int) -> void:
	var sp = spells[i]
	if sp["left"] > 0.0:
		return
	if _do_cast(sp["id"]):
		sp["left"] = sp["cd"]
		hud.wheel.set_data(_wheel_data())

func _do_cast(id: String) -> bool:
	var p := player
	match id:
		"fire":
			var e := _nearest_enemy()
			if e == null:
				return false
			_burst(e.position, 90.0, Color(1.0, 0.7, 0.3), Color(1.0, 0.45, 0.15))
			var fdmg := (55.0 + p.level * 3.0) * p.spell_mul
			for en in enemies:
				if not is_instance_valid(en) or en.dead:
					continue
				if en.position.distance_to(e.position) <= 90.0:
					en.hp -= fdmg
					en.hitflash = 0.12
					_spawn_text(en.position + Vector2(0, -en.radius * 1.6), str(int(fdmg)), Color(1.0, 0.7, 0.3))
					if en.hp <= 0.0:
						_kill_enemy(en)
			sfx.play("fire_cast", 0.6)
			return true
		"bolt":
			var targets := _nearest_enemies(4, 540.0)
			if targets.is_empty():
				return false
			var bdmg := (75.0 + p.level * 4.0) * p.spell_mul
			var pts: Array = []
			for en in targets:
				pts.append(en.position)
				en.hp -= bdmg
				en.hitflash = 0.12
				_spawn_text(en.position + Vector2(0, -en.radius * 1.6), str(int(bdmg)), Color(0.8, 0.9, 1.0))
				if en.hp <= 0.0:
					_kill_enemy(en)
			var bolt := VSBolt.new()
			bolt.setup(p.position, pts)
			fx_layer.add_child(bolt)
			sfx.play("lightning_cast", 0.5)
			return true
		"frost":
			var frad := 240.0
			_burst(p.position, frad, Color(0.8, 0.95, 1.0), Color(0.4, 0.7, 1.0))
			var cdmg := (22.0 + p.level * 2.0) * p.spell_mul
			for en in enemies:
				if not is_instance_valid(en) or en.dead:
					continue
				if en.position.distance_to(p.position) <= frad:
					en.slow_timer = 3.0
					en.hp -= cdmg
					en.hitflash = 0.12
					if en.hp <= 0.0:
						_kill_enemy(en)
			sfx.play("ice_impact", 0.6)
			return true
		"heal":
			if p.hp >= p.maxhp:
				return false
			p.hp = minf(p.maxhp, p.hp + 40.0)
			_burst(p.position, 80.0, Color(0.7, 1.0, 0.6), Color(0.4, 0.9, 0.4))
			_spawn_text(p.position + Vector2(0, -40), "+40", Color(0.5, 1.0, 0.5))
			sfx.play("blessing", 0.5)
			return true
		"meteor":
			var me := _nearest_enemy()
			if me == null:
				return false
			_burst(me.position, 130.0, Color(1.0, 0.6, 0.2), Color(1.0, 0.35, 0.1))
			var mdmg := (90.0 + p.level * 4.0) * p.spell_mul
			for en in enemies:
				if not is_instance_valid(en) or en.dead:
					continue
				if en.position.distance_to(me.position) <= 130.0:
					en.hp -= mdmg
					en.hitflash = 0.12
					_spawn_text(en.position + Vector2(0, -en.radius * 1.6), str(int(mdmg)), Color(1.0, 0.6, 0.2))
					if en.hp <= 0.0:
						_kill_enemy(en)
			sfx.play("fire_cast", 0.7)
			return true
		"slash_sk":
			var skrad := 135.0
			_burst(p.position, skrad, Color(1.0, 0.95, 0.7), Color(1.0, 0.7, 0.3))
			var skdmg := (55.0 + p.level * 3.0) * p.spell_mul
			for en in enemies:
				if not is_instance_valid(en) or en.dead:
					continue
				var sto := en.position - p.position
				var sd := sto.length()
				if sd <= skrad:
					en.position += (sto / maxf(sd, 0.001)) * 50.0
					en.hp -= skdmg
					en.hitflash = 0.12
					_spawn_text(en.position + Vector2(0, -en.radius * 1.6), str(int(skdmg)), Color(1, 0.9, 0.6))
					if en.hp <= 0.0:
						_kill_enemy(en)
			sfx.play("slice", 0.5)
			return true
		"dash":
			var dvx := p.facing * 175.0
			p.position.x = clampf(p.position.x + dvx, 24.0, WORLD - 24.0)
			p.invuln = maxf(p.invuln, 0.45)
			_burst(p.position, 95.0, Color(0.9, 0.95, 1.0), Color(0.6, 0.8, 1.0))
			var ddmg := (45.0 + p.level * 2.0) * p.spell_mul
			for en in enemies:
				if not is_instance_valid(en) or en.dead:
					continue
				if en.position.distance_to(p.position) <= 95.0:
					en.hp -= ddmg
					en.hitflash = 0.12
					if en.hp <= 0.0:
						_kill_enemy(en)
			sfx.play("slice2", 0.5)
			return true
		"whirl":
			var wrad := 165.0
			_burst(p.position, wrad, Color(1.0, 0.9, 0.6), Color(1.0, 0.6, 0.2))
			var wdmg := (40.0 + p.level * 3.0) * p.spell_mul
			for en in enemies:
				if not is_instance_valid(en) or en.dead:
					continue
				if en.position.distance_to(p.position) <= wrad:
					en.hp -= wdmg
					en.hitflash = 0.12
					_spawn_text(en.position + Vector2(0, -en.radius * 1.6), str(int(wdmg)), Color(1, 0.9, 0.6))
					if en.hp <= 0.0:
						_kill_enemy(en)
			sfx.play("slice", 0.5)
			return true
		"guard":
			p.hp = minf(p.maxhp, p.hp + 30.0)
			p.invuln = maxf(p.invuln, 1.6)
			_burst(p.position, 75.0, Color(0.7, 0.85, 1.0), Color(0.4, 0.6, 1.0))
			_spawn_text(p.position + Vector2(0, -44), "GARDE !", Color(0.6, 0.8, 1.0))
			sfx.play("blessing", 0.5)
			return true
		"blade":
			var bld_e := _nearest_enemy()
			var bld_ang := 0.0
			if bld_e != null:
				bld_ang = (bld_e.position - p.position).angle()
			elif p.facing < 0:
				bld_ang = PI
			for k in 3:
				var bpr := VSProjectile.new()
				bpr.setup(p.position, Vector2.from_angle(bld_ang + (k - 1) * 0.2), 560.0, (40.0 + p.level * 3.0) * p.spell_mul, 2, 11.0)
				proj_layer.add_child(bpr)
				projectiles.append(bpr)
			sfx.play("slice2", 0.4)
			return true
		"aegis":
			# bouclier sacré : invincible plusieurs secondes + petit soin
			p.invuln = maxf(p.invuln, 3.5)
			p.hp = minf(p.maxhp, p.hp + 12.0)
			_burst(p.position, 90.0, Color(1.0, 0.95, 0.6), Color(1.0, 0.85, 0.3))
			_spawn_text(p.position + Vector2(0, -46), "ÉGIDE ! Invincible", Color(1.0, 0.9, 0.5))
			sfx.play("blessing", 0.7)
			return true
		"arc_wave":
			# éventail de 7 lames en arc de cercle
			var aw_e := _nearest_enemy()
			var aw_ang := 0.0
			if aw_e != null:
				aw_ang = (aw_e.position - p.position).angle()
			elif p.facing < 0:
				aw_ang = PI
			var aw_n := 7
			var aw_arc := 1.75   # ~100°
			for k in aw_n:
				var aa := aw_ang - aw_arc / 2.0 + aw_arc * float(k) / float(aw_n - 1)
				var apr := VSProjectile.new()
				apr.setup(p.position, Vector2.from_angle(aa), 500.0, (30.0 + p.level * 2.0) * p.spell_mul, 1, 10.0)
				proj_layer.add_child(apr)
				projectiles.append(apr)
			sfx.play("slice2", 0.5)
			return true
		"blood_nova":
			# anneau complet de 14 projectiles autour du héros
			for k in 14:
				var na := TAU * float(k) / 14.0
				var npr := VSProjectile.new()
				npr.setup(p.position, Vector2.from_angle(na), 430.0, (26.0 + p.level * 2.0) * p.spell_mul, 0, 10.0)
				proj_layer.add_child(npr)
				projectiles.append(npr)
			_burst(p.position, 70.0, Color(1.0, 0.4, 0.4), Color(0.9, 0.15, 0.2))
			sfx.play("fire_cast", 0.5)
			return true
		"war_stomp":
			# onde de choc : dégâts + gros knockback + ralentissement
			var st_rad := 150.0
			_burst(p.position, st_rad, Color(0.9, 0.8, 0.6), Color(0.7, 0.5, 0.3))
			var st_dmg := (30.0 + p.level * 2.0) * p.spell_mul
			for en in enemies:
				if not is_instance_valid(en) or en.dead:
					continue
				var st_to := en.position - p.position
				var st_d := st_to.length()
				if st_d <= st_rad:
					en.position += (st_to / maxf(st_d, 0.001)) * 90.0
					en.slow_timer = maxf(en.slow_timer, 2.5)
					en.hp -= st_dmg
					en.hitflash = 0.12
					if en.hp <= 0.0:
						_kill_enemy(en)
			sfx.play("ice_impact", 0.5)
			return true
		"frenzy":
			# fureur : attaque 2x plus vite et court plus vite quelques secondes
			p.frenzy_timer = maxf(p.frenzy_timer, 5.0)
			_burst(p.position, 80.0, Color(1.0, 0.5, 0.4), Color(1.0, 0.25, 0.2))
			_spawn_text(p.position + Vector2(0, -46), "FRÉNÉSIE !", Color(1.0, 0.45, 0.35))
			sfx.play("buff", 0.6)
			return true
	return false

# Attaque de mêlée (Samurai / Chevalier / Kobold) : dégâts autour du héros.
func _melee_attack() -> void:
	var p := player
	var rad := 100.0
	_burst(p.position + Vector2(p.facing * 28, 0), 80.0, Color(1.0, 0.97, 0.8), Color(1.0, 0.8, 0.4))
	var mdmg := p.proj_damage
	var crit := randf() < p.crit_chance
	if crit:
		mdmg *= 2.0
	for e in enemies:
		if not is_instance_valid(e) or e.dead:
			continue
		if p.position.distance_to(e.position) <= rad:
			e.hp -= mdmg
			e.hitflash = 0.12
			_spawn_text(e.position + Vector2(0, -e.radius * 1.6), str(int(mdmg)), Color(1, 0.7, 0.3) if crit else Color(1, 0.9, 0.6))
			if e.hp <= 0.0:
				_kill_enemy(e)
	sfx.play("slice" if randf() < 0.5 else "slice2", 0.25)

# Ultime (jauge pleine) : dépend du héros.
func _cast_ult() -> bool:
	if power < 1.0:
		return false
	var p := player
	var uid: String = HEROES[current_hero]["ult"]
	match uid:
		"arcane_storm":
			for k in 7:
				var off := Vector2.from_angle(randf() * TAU) * randf_range(40.0, 240.0)
				_burst(p.position + off, 110.0, Color(0.72, 0.6, 1.0), Color(0.5, 0.4, 1.0))
			var udmg := 140.0 + p.level * 6.0
			for en in enemies:
				if not is_instance_valid(en) or en.dead:
					continue
				if en.position.distance_to(p.position) <= 380.0:
					en.hp -= udmg
					en.hitflash = 0.12
					if en.hp <= 0.0:
						_kill_enemy(en)
			sfx.play("buff", 0.85)
		"thousand_cuts":
			var udmg2 := 120.0 + p.level * 6.0
			for en in enemies:
				if not is_instance_valid(en) or en.dead:
					continue
				if en.position.distance_to(p.position) <= 430.0:
					_burst(en.position, 38.0, Color(1.0, 0.97, 0.85), Color(1.0, 0.7, 0.3))
					en.hp -= udmg2
					en.hitflash = 0.12
					_spawn_text(en.position, str(int(udmg2)), Color(1, 0.85, 0.4))
					if en.hp <= 0.0:
						_kill_enemy(en)
			sfx.play("slice", 0.85)
		"judgment":
			# le ciel s'ouvre : énorme zone sainte + invincibilité
			p.invuln = maxf(p.invuln, 2.5)
			for k in 5:
				var joff := Vector2.from_angle(randf() * TAU) * randf_range(0.0, 200.0)
				_burst(p.position + joff, 130.0, Color(1.0, 0.95, 0.7), Color(1.0, 0.85, 0.4))
			var jdmg := 150.0 + p.level * 6.0
			for en in enemies:
				if not is_instance_valid(en) or en.dead:
					continue
				if en.position.distance_to(p.position) <= 400.0:
					en.hp -= jdmg
					en.hitflash = 0.12
					_spawn_text(en.position, str(int(jdmg)), Color(1, 0.95, 0.6))
					if en.hp <= 0.0:
						_kill_enemy(en)
			sfx.play("blessing", 0.9)
			sfx.play("buff", 0.7)
		"primal_rage":
			# rage primordiale : longue frénésie + double anneau de sang
			p.frenzy_timer = maxf(p.frenzy_timer, 8.0)
			for ring in 2:
				var rn := 16
				for k in rn:
					var ra := TAU * float(k) / float(rn) + ring * 0.2
					var rpr := VSProjectile.new()
					rpr.setup(p.position, Vector2.from_angle(ra), 380.0 + ring * 140.0, 34.0 + p.level * 3.0, 1, 11.0)
					proj_layer.add_child(rpr)
					projectiles.append(rpr)
			_burst(p.position, 160.0, Color(1.0, 0.4, 0.35), Color(0.95, 0.15, 0.2))
			sfx.play("buff", 0.9)
			sfx.play("slice", 0.6)
		"arena_roar":
			# rugissement de l'arène : choc géant, la foule est conquise
			p.invuln = maxf(p.invuln, 1.5)
			_burst(p.position, 150.0, Color(1.0, 0.9, 0.6), Color(1.0, 0.7, 0.3))
			_burst(p.position, 300.0, Color(1.0, 0.85, 0.5), Color(0.9, 0.6, 0.2))
			_burst(p.position, 440.0, Color(1.0, 0.8, 0.45), Color(0.85, 0.5, 0.15))
			var rodmg := 130.0 + p.level * 5.0
			for en in enemies:
				if not is_instance_valid(en) or en.dead:
					continue
				var ro_to := en.position - p.position
				var ro_d := ro_to.length()
				if ro_d <= 440.0:
					en.position += (ro_to / maxf(ro_d, 0.001)) * 140.0
					en.slow_timer = maxf(en.slow_timer, 3.0)
					en.hp -= rodmg
					en.hitflash = 0.12
					_spawn_text(en.position, str(int(rodmg)), Color(1, 0.9, 0.55))
					if en.hp <= 0.0:
						_kill_enemy(en)
			sfx.play("buff", 0.9)
			sfx.play("slice", 0.7)
	power = 0.0
	_spawn_text(p.position + Vector2(0, -60), "ULTIME !", Color(1.0, 0.82, 0.32))
	hud.wheel.set_data(_wheel_data())
	return true

func _burst(pos: Vector2, radius: float, ring: Color, glow: Color) -> void:
	var nova := VSNova.new()
	nova.position = pos
	nova.max_r = radius
	nova.ring_color = ring
	nova.glow_color = glow
	fx_layer.add_child(nova)

func _nearest_enemy() -> VSEnemy:
	var best: VSEnemy = null
	var bd := INF
	for e in enemies:
		if not is_instance_valid(e) or e.dead:
			continue
		var d := player.position.distance_squared_to(e.position)
		if d < bd:
			bd = d
			best = e
	return best

func _nearest_enemies(count: int, max_range: float) -> Array:
	var pool: Array = []
	for e in enemies:
		if not is_instance_valid(e) or e.dead:
			continue
		if player.position.distance_to(e.position) <= max_range:
			pool.append(e)
	pool.sort_custom(func(a, b): return player.position.distance_squared_to(a.position) < player.position.distance_squared_to(b.position))
	if pool.size() > count:
		pool.resize(count)
	return pool

# ----- Textes flottants -----
func _spawn_text(pos: Vector2, text: String, color: Color) -> void:
	var l := Label.new()
	l.text = text
	l.position = pos
	l.z_index = 30
	l.add_theme_color_override("font_color", color)
	l.add_theme_font_size_override("font_size", 16)
	fx_layer.add_child(l)
	floats.append({"node": l, "life": 0.7, "vy": -36.0})

func _update_floats(delta: float) -> void:
	for i in range(floats.size() - 1, -1, -1):
		var f = floats[i]
		var l: Label = f["node"]
		l.position.y += f["vy"] * delta
		f["life"] -= delta
		l.modulate.a = clampf(f["life"] / 0.4, 0.0, 1.0)
		if f["life"] <= 0.0:
			l.queue_free()
			floats.remove_at(i)

# ----- Montée de niveau -----
func _open_levelup() -> void:
	state = State.LEVELUP
	level_queue -= 1
	var pool := UPGRADES.duplicate()
	pool.shuffle()
	hud.show_levelup(pool.slice(0, 3))

func _apply_upgrade(id: String) -> void:
	var p := player
	match id:
		"dmg": p.proj_damage = round(p.proj_damage * 1.25)
		"count": p.proj_count += 1
		"rate": p.fire_interval = maxf(0.16, p.fire_interval * 0.85)
		"pierce": p.pierce += 1
		"crit": p.crit_chance = minf(0.75, p.crit_chance + 0.10)
		"heavy":
			p.proj_speed *= 1.25
			p.proj_size *= 1.25
		"lifesteal": p.heal_on_kill += 2.0
		"spell_power": p.spell_mul *= 1.25
		"hp":
			p.maxhp += 30.0
			p.hp = minf(p.maxhp, p.hp + 30.0)
		"armor": p.dmg_reduction = minf(0.6, p.dmg_reduction + 0.08)
		"regen": p.regen += 1.5
		"nova":
			p.nova_radius_mul *= 1.3
			p.nova_dmg_mul *= 1.3
		"speed": p.speed *= 1.12
		"magnet": p.pickup *= 1.35
	_register_buff(id)
	sfx.play("click", 0.5)
	hud.hide_overlays()
	if level_queue > 0:
		_open_levelup()
	else:
		state = State.PLAYING

# Enregistre une marque de buff (offensif/défensif) et rafraîchit la barre.
func _register_buff(id: String) -> void:
	for u in UPGRADES:
		if u["id"] == id:
			if u["kind"] != "":
				buffs[id] = int(buffs.get(id, 0)) + 1
				_refresh_buffs()
			return

func _refresh_buffs() -> void:
	var out: Array = []
	for u in UPGRADES:   # ordre stable : offensifs puis défensifs
		var uid: String = u["id"]
		if buffs.has(uid):
			out.append({
				"icon": load("res://assets/ui/upgrades/%s.png" % u["icon"]),
				"count": int(buffs[uid]),
				"name": u["name"],
				"off": u["kind"] == "off",
			})
	hud.set_buffs(out)

# ----- Fin de partie : défaite OU victoire -----
func _end_run(victory: bool) -> void:
	if state == State.GAMEOVER:
		return
	state = State.GAMEOVER
	if victory:
		sfx.play("blessing", 0.9)
		sfx.play("buff", 0.9)
	else:
		player.anim.play("death")
		player.anim.modulate.a = 1.0
		sfx.play("death", 0.7)
	sfx.play_music("menu")
	hud.show_hud(false)
	_last_score = kills * 10 + (player.level - 1) * 40 + int(elapsed) + (10000 if victory else 0)
	var m := int(elapsed / 60.0)
	var s := int(fmod(elapsed, 60.0))
	_last_time = "%02d:%02d" % [m, s]
	hud.show_gameover_entry(_last_time, player.level, kills, _last_score, VSScores.last_name(), victory)

func _on_name_submitted(player_name: String) -> void:
	var nm := player_name.strip_edges()
	if nm == "":
		nm = "Héros"
	VSScores.save_name(nm)
	var rank := VSScores.add({
		"name": nm, "score": _last_score, "time": _last_time,
		"level": player.level, "kills": kills,
	})
	sfx.play("click", 0.5)
	hud.show_gameover_result(VSScores.load_all(), rank, _last_score)

func _refresh_hud() -> void:
	var p := player
	var m := int(elapsed / 60.0)
	var s := int(fmod(elapsed, 60.0))
	hud.set_xp(p.xp_pct(), p.level)
	hud.set_hp(p.hp, p.maxhp)
	hud.set_time("%02d:%02d" % [m, s])
	hud.set_kills(kills)
	hud.wheel.set_data(_wheel_data())
	# barre du boss le plus puissant en vie
	var boss: VSEnemy = null
	for e in enemies:
		if is_instance_valid(e) and e.is_boss and not e.dead:
			if boss == null or e.maxhp > boss.maxhp:
				boss = e
	if boss != null:
		hud.set_boss(boss.hp / boss.maxhp, boss.boss_title)
	else:
		hud.set_boss(-1.0, "")

# ----- Cinématique d'introduction -----
func _intro_slides() -> Array:
	return [
		{
			"texs": [load("res://assets/bg/forest.png")], "h": 230.0,
			"title": "La forêt du Crépuscule",
			"sub": "Depuis mille ans, elle veille, paisible, sur le monde des vivants.",
		},
		{
			"texs": [enemy_frames["boss"].get_frame_texture("move", 0),
					enemy_frames["demon2"].get_frame_texture("move", 0),
					enemy_frames["bringer"].get_frame_texture("move", 0),
					enemy_frames["dragon1"].get_frame_texture("move", 0)], "h": 150.0,
			"title": "L'éveil du Seigneur",
			"sub": "Sous la terre, le Seigneur du Crépuscule a rouvert les cavernes.\nDémons, dragons et morts-vivants déferlent — tous les 10 niveaux, un gardien les mène.",
		},
		{
			"texs": [hero_frames["wizard"].get_frame_texture("idle", 0),
					hero_frames["samurai"].get_frame_texture("idle", 0),
					hero_frames["knight"].get_frame_texture("idle", 0),
					hero_frames["kobold"].get_frame_texture("idle", 0),
					hero_frames["gladiator"].get_frame_texture("idle", 0)], "h": 150.0,
			"title": "Cinq héros se lèvent",
			"sub": "Sorcier, Samurai, Chevalier, Kobold, Gladiateur.\nLeurs sorts sont notre dernier rempart.",
		},
		{
			"texs": [enemy_frames["megaboss"].get_frame_texture("move", 0)], "h": 230.0,
			"title": "Ta quête",
			"sub": "Survis aux vagues. Deviens plus fort. Atteins le NIVEAU 99.\nEt là, au bout de la nuit… affronte-le.",
		},
	]

# ============================================================
# Construction des animations
func _wizard_sf() -> SpriteFrames:
	var sf := SpriteFrames.new()
	_add_sheet(sf, "idle", load("res://assets/wizard/idle.png"), 8, 150, 8.0, true)
	_add_sheet(sf, "run", load("res://assets/wizard/move.png"), 8, 150, 11.0, true)
	_add_sheet(sf, "death", load("res://assets/wizard/death.png"), 5, 150, 9.0, false)
	return sf

func _samurai_sf() -> SpriteFrames:
	var sf := SpriteFrames.new()
	_add_sheet(sf, "idle", load("res://assets/samurai/idle.png"), 10, 96, 8.0, true)
	_add_sheet(sf, "run", load("res://assets/samurai/run.png"), 16, 96, 14.0, true)
	_add_sheet(sf, "death", load("res://assets/samurai/hurt.png"), 4, 96, 7.0, false)
	return sf

func _knight_sf() -> SpriteFrames:
	var sf := SpriteFrames.new()
	_add_sheet(sf, "idle", load("res://assets/knight/idle.png"), 7, 96, 8.0, true, 84)
	_add_sheet(sf, "run", load("res://assets/knight/run.png"), 8, 96, 12.0, true, 84)
	_add_sheet(sf, "death", load("res://assets/knight/death.png"), 12, 96, 10.0, false, 84)
	return sf

func _kobold_sf() -> SpriteFrames:
	var sf := SpriteFrames.new()
	_add_sheet(sf, "idle", load("res://assets/kobold/idle.png"), 6, 148, 8.0, true, 96)
	_add_sheet(sf, "run", load("res://assets/kobold/run.png"), 8, 148, 13.0, true, 96)
	# pas d'animation de mort dans le pack : on fige la 1re frame d'idle
	_add_sheet(sf, "death", load("res://assets/kobold/idle.png"), 1, 148, 5.0, false, 96)
	return sf

func _gladiator_sf() -> SpriteFrames:
	var sf := SpriteFrames.new()
	_add_sheet(sf, "idle", load("res://assets/gladiator/idle.png"), 7, 128, 8.0, true)
	_add_sheet(sf, "run", load("res://assets/gladiator/run.png"), 10, 128, 13.0, true)
	_add_sheet(sf, "death", load("res://assets/gladiator/death.png"), 5, 128, 8.0, false)
	return sf

func _enemy_sf(move_path: String, move_count: int, death_path: String, death_count: int, fsize: int = 150) -> SpriteFrames:
	var sf := SpriteFrames.new()
	_add_sheet(sf, "move", load(move_path), move_count, fsize, 10.0, true)
	_add_sheet(sf, "death", load(death_path), death_count, fsize, 12.0, false)
	return sf

func _boss_sf() -> SpriteFrames:
	var sf := SpriteFrames.new()
	var tex = load("res://assets/boss/nightborne.png")
	_add_sheet_row(sf, "move", tex, 0, 9, 80, 9.0, true)       # rangée 0 = idle
	_add_sheet_row(sf, "death", tex, 4, 16, 80, 11.0, false)   # rangée 4 = mort / dissolution
	return sf

func _bringer_sf() -> SpriteFrames:
	var sf := SpriteFrames.new()
	_add_sheet(sf, "move", load("res://assets/boss/bringer_walk.png"), 8, 140, 9.0, true, 93)
	_add_sheet(sf, "death", load("res://assets/boss/bringer_death.png"), 10, 140, 11.0, false, 93)
	return sf

func _add_sheet_row(sf: SpriteFrames, anim: String, tex: Texture2D, row: int, count: int, fsize: int, fps: float, loop: bool) -> void:
	if not sf.has_animation(anim):
		sf.add_animation(anim)
	sf.set_animation_speed(anim, fps)
	sf.set_animation_loop(anim, loop)
	if tex == null:
		return
	for i in count:
		var at := AtlasTexture.new()
		at.atlas = tex
		at.region = Rect2(i * fsize, row * fsize, fsize, fsize)
		sf.add_frame(anim, at)

# Découpe une planche horizontale ; `fh` = hauteur de frame si différente de la largeur.
func _add_sheet(sf: SpriteFrames, anim: String, tex: Texture2D, count: int, fsize: int, fps: float, loop: bool, fh: int = -1) -> void:
	if not sf.has_animation(anim):
		sf.add_animation(anim)
	sf.set_animation_speed(anim, fps)
	sf.set_animation_loop(anim, loop)
	if tex == null:
		return
	var h := fh if fh > 0 else fsize
	for i in count:
		var at := AtlasTexture.new()
		at.atlas = tex
		at.region = Rect2(i * fsize, 0, fsize, h)
		sf.add_frame(anim, at)
