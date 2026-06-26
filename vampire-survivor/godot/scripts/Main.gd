# Main.gd — contrôleur du jeu : boucle, spawn, collisions, niveaux, états, audio.
extends Node2D

const WORLD := 4000.0
const MAX_ENEMIES := 280

enum State { MENU, PLAYING, LEVELUP, PAUSED, GAMEOVER }

const ENEMY_DEF := {
	"goblin":    {"hp": 26.0,  "speed": 82.0, "dmg": 8.0,  "xp": 1, "radius": 18.0, "scale": 0.58, "bar": false},
	"flyingeye": {"hp": 40.0,  "speed": 96.0, "dmg": 10.0, "xp": 3, "radius": 17.0, "scale": 0.52, "bar": false},
	"mushroom":  {"hp": 60.0,  "speed": 52.0, "dmg": 13.0, "xp": 3, "radius": 20.0, "scale": 0.60, "bar": false},
	"skeleton":  {"hp": 160.0, "speed": 46.0, "dmg": 20.0, "xp": 7,  "radius": 22.0, "scale": 0.70, "bar": true},
	"bat":       {"hp": 30.0,  "speed": 112.0,"dmg": 9.0,  "xp": 2,  "radius": 16.0, "scale": 0.85, "bar": false},
	"boss":      {"hp": 600.0, "speed": 42.0, "dmg": 30.0, "xp": 30, "radius": 42.0, "scale": 1.70, "bar": true},
}

const UPGRADES := [
	{"name": "Lame jumelle",     "desc": "+1 projectile",        "id": "count"},
	{"name": "Frappe rapide",    "desc": "-15% recharge",        "id": "rate"},
	{"name": "Affûtage",         "desc": "+30% dégâts",          "id": "dmg"},
	{"name": "Bottes ailées",    "desc": "+12% vitesse",         "id": "speed"},
	{"name": "Vitalité",         "desc": "+25 PV max (soigne)",  "id": "hp"},
	{"name": "Aimant",           "desc": "+30% ramassage",       "id": "magnet"},
	{"name": "Perforation",      "desc": "traverse +1 ennemi",   "id": "pierce"},
	{"name": "Projectile lourd", "desc": "+25% vitesse/taille",  "id": "heavy"},
	{"name": "Onde arcanique",   "desc": "+30% puissance du sort", "id": "spell"},
]

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
var bosses_spawned := 0
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
	}
	item_tex = {
		"weapon": load("res://assets/items/weapon.png"),
		"armor":  load("res://assets/items/armor.png"),
		"potion": load("res://assets/items/potion.png"),
	}

	spells = [
		{"id": "fire",  "name": "Boule de feu", "key": "1", "cd": 3.5,  "left": 0.0, "icon": load("res://assets/spells/fire.png")},
		{"id": "bolt",  "name": "Éclair",       "key": "2", "cd": 6.0,  "left": 0.0, "icon": load("res://assets/spells/lightning.png")},
		{"id": "frost", "name": "Gel",          "key": "3", "cd": 10.0, "left": 0.0, "icon": load("res://assets/spells/frost.png")},
		{"id": "heal",  "name": "Soin",         "key": "4", "cd": 18.0, "left": 0.0, "icon": load("res://assets/spells/heal.png")},
	]

	# Sol
	ground = Sprite2D.new()
	ground.texture = _make_ground_texture()
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
	player.set_frames(_wizard_sf())
	player.cam.limit_left = 0
	player.cam.limit_top = 0
	player.cam.limit_right = int(WORLD)
	player.cam.limit_bottom = int(WORLD)
	player.position = Vector2(WORLD / 2.0, WORLD / 2.0)
	player.visible = false

	hud = VSHud.new()
	add_child(hud)
	hud.build()
	hud.play_pressed.connect(start_game)
	hud.retry_pressed.connect(start_game)
	hud.to_menu_pressed.connect(_to_menu)
	hud.upgrade_chosen.connect(_apply_upgrade)
	hud.sfx_changed.connect(sfx.set_sfx_volume)
	hud.name_submitted.connect(_on_name_submitted)
	hud.show_menu()
	state = State.MENU

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

func _mk(action: String, keys: Array) -> void:
	if InputMap.has_action(action):
		InputMap.erase_action(action)
	InputMap.add_action(action)
	for k in keys:
		var ev := InputEventKey.new()
		ev.keycode = k
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

func start_game() -> void:
	sfx.play("click", 0.5)
	_clear_entities()
	elapsed = 0.0
	kills = 0
	spawn_timer = 0.0
	level_queue = 0
	bosses_spawned = 0
	player.reset(Vector2(WORLD / 2.0, WORLD / 2.0))
	player.visible = true
	hud.hide_overlays()
	hud.show_hud(true)
	state = State.PLAYING

func _to_menu() -> void:
	state = State.MENU
	_clear_entities()
	player.visible = false
	hud.show_hud(false)
	hud.show_menu()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("vs_pause"):
		_toggle_pause()
	elif event.is_action_pressed("vs_mute"):
		sfx.set_muted(not sfx.muted)
		hud.set_muted(sfx.muted)
	elif state == State.PLAYING:
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

	# Déplacement + animation
	var dir := Input.get_vector("vs_left", "vs_right", "vs_up", "vs_down")
	p.position.x = clampf(p.position.x + dir.x * p.speed * delta, 24.0, WORLD - 24.0)
	p.position.y = clampf(p.position.y + dir.y * p.speed * delta, 24.0, WORLD - 24.0)
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
	p.anim.modulate.a = 0.45 if (p.invuln > 0.0 and int(time * 20.0) % 2 == 0) else 1.0

	# Arme automatique
	p.fire_cd -= delta
	if p.fire_cd <= 0.0 and enemies.size() > 0:
		_fire()
		p.fire_cd = p.fire_interval

	_spawns(delta)
	_update_enemies(delta)
	_update_projectiles(delta)
	_update_gems(delta)
	_update_items(delta)
	_cull_enemies()
	_update_floats(delta)

	# Boss tous les 5 niveaux
	if player.level >= (bosses_spawned + 1) * 5:
		bosses_spawned += 1
		_spawn_boss()

	if level_queue > 0 and state == State.PLAYING:
		_open_levelup()

	if p.hp <= 0.0:
		_game_over()
		return

	_refresh_hud()

# ----- Arme -----
func _fire() -> void:
	var p := player
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
		pr.setup(p.position, Vector2.from_angle(a), p.proj_speed, p.proj_damage, p.pierce, p.proj_size)
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
	else:
		if r < 0.2: return "goblin"
		elif r < 0.4: return "bat"
		elif r < 0.58: return "flyingeye"
		elif r < 0.78: return "mushroom"
		else: return "skeleton"

func _spawn_one() -> void:
	var tkey := _pick_type()
	var hp_scale := 1.0 + (elapsed / 60.0) * 0.22
	var vsize := get_viewport_rect().size
	var radius := maxf(vsize.x, vsize.y) / 2.0 + 80.0
	var ang := randf() * TAU
	var pos := player.position + Vector2.from_angle(ang) * radius
	pos.x = clampf(pos.x, 20.0, WORLD - 20.0)
	pos.y = clampf(pos.y, 20.0, WORLD - 20.0)

	var e := VSEnemy.new()
	e.setup(tkey, pos, hp_scale, enemy_frames[tkey], ENEMY_DEF[tkey])
	world.add_child(e)
	enemies.append(e)

# ----- Boss + objets -----
func _spawn_boss() -> void:
	var hp_scale := 1.0 + bosses_spawned * 0.6
	var vsize := get_viewport_rect().size
	var radius := maxf(vsize.x, vsize.y) / 2.0 + 90.0
	var ang := randf() * TAU
	var pos := player.position + Vector2.from_angle(ang) * radius
	pos.x = clampf(pos.x, 40.0, WORLD - 40.0)
	pos.y = clampf(pos.y, 40.0, WORLD - 40.0)
	var e := VSEnemy.new()
	e.setup("boss", pos, hp_scale, enemy_frames["boss"], ENEMY_DEF["boss"])
	e.is_boss = true
	world.add_child(e)
	enemies.append(e)
	_spawn_text(player.position + Vector2(0, -120), "BOSS !", Color(0.85, 0.35, 1.0))
	sfx.play("buff", 0.7)

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
			p.hp -= e.dmg
			p.invuln = 0.6
			sfx.play("hurt", 0.4)
			_spawn_text(p.position + Vector2(0, -34), "-" + str(int(e.dmg)), Color(1, 0.42, 0.42))

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
	var g := VSGem.new()
	g.setup(e.position, e.xp)
	gem_layer.add_child(g)
	gems.append(g)
	if e.is_boss:
		_drop_item(e.position)
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
	var leveled := false
	p.xp += amount
	while p.xp >= p.xp_to_next:
		p.xp -= p.xp_to_next
		p.level += 1
		p.xp_to_next = int(round(p.xp_to_next * 1.32 + 3.0))
		level_queue += 1
		leveled = true
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

# ----- Sorts actifs (touches 1..4) -----
func _wheel_data() -> Array:
	var out: Array = []
	for sp in spells:
		out.append({
			"icon": sp["icon"], "key": sp["key"], "left": sp["left"],
			"frac": (sp["left"] / sp["cd"]) if sp["cd"] > 0.0 else 0.0,
			"ready": sp["left"] <= 0.0,
		})
	return out

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
			var fdmg := 55.0 + p.level * 3.0
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
			var bdmg := 75.0 + p.level * 4.0
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
			var cdmg := 22.0 + p.level * 2.0
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
	return false

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
		"count": p.proj_count += 1
		"rate": p.fire_interval = maxf(0.16, p.fire_interval * 0.85)
		"dmg": p.proj_damage = round(p.proj_damage * 1.3)
		"speed": p.speed *= 1.12
		"hp":
			p.maxhp += 25.0
			p.hp = minf(p.maxhp, p.hp + 25.0)
		"magnet": p.pickup *= 1.3
		"pierce": p.pierce += 1
		"heavy":
			p.proj_speed *= 1.25
			p.proj_size *= 1.25
		"spell":
			p.nova_radius_mul *= 1.3
			p.nova_dmg_mul *= 1.3
	sfx.play("click", 0.5)
	hud.hide_overlays()
	if level_queue > 0:
		_open_levelup()
	else:
		state = State.PLAYING

# ----- Fin -----
func _game_over() -> void:
	state = State.GAMEOVER
	player.anim.play("death")
	player.anim.modulate.a = 1.0
	sfx.play("death", 0.7)
	hud.show_hud(false)
	_last_score = kills * 10 + (player.level - 1) * 40 + int(elapsed)
	var m := int(elapsed / 60.0)
	var s := int(fmod(elapsed, 60.0))
	_last_time = "%02d:%02d" % [m, s]
	hud.show_gameover_entry(_last_time, player.level, kills, _last_score, VSScores.last_name())

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

# ============================================================
# Construction des animations
func _wizard_sf() -> SpriteFrames:
	var sf := SpriteFrames.new()
	_add_sheet(sf, "idle", load("res://assets/wizard/idle.png"), 8, 150, 8.0, true)
	_add_sheet(sf, "run", load("res://assets/wizard/move.png"), 8, 150, 11.0, true)
	_add_sheet(sf, "death", load("res://assets/wizard/death.png"), 5, 150, 9.0, false)
	return sf

func _add_files(sf: SpriteFrames, anim: String, dir: String, count: int, fps: float, loop: bool) -> void:
	if not sf.has_animation(anim):
		sf.add_animation(anim)
	sf.set_animation_speed(anim, fps)
	sf.set_animation_loop(anim, loop)
	for i in count:
		var t = load(dir + str(i) + ".png")
		if t:
			sf.add_frame(anim, t)

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

func _add_sheet(sf: SpriteFrames, anim: String, tex: Texture2D, count: int, fsize: int, fps: float, loop: bool) -> void:
	if not sf.has_animation(anim):
		sf.add_animation(anim)
	sf.set_animation_speed(anim, fps)
	sf.set_animation_loop(anim, loop)
	if tex == null:
		return
	for i in count:
		var at := AtlasTexture.new()
		at.atlas = tex
		at.region = Rect2(i * fsize, 0, fsize, fsize)
		sf.add_frame(anim, at)

# ----- Sol procédural (tuile sans couture) -----
func _make_ground_texture() -> Texture2D:
	var s := 96
	var img := Image.create(s, s, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.108, 0.168, 0.122))
	var r := RandomNumberGenerator.new()
	r.seed = 20240625
	# taches de teinte (intérieur -> sans couture) pour casser l'uniformité
	for n in 7:
		var px := r.randi_range(8, s - 12)
		var py := r.randi_range(8, s - 12)
		var lighter := r.randf() < 0.55
		var col := Color(0.135, 0.205, 0.140) if lighter else Color(0.078, 0.123, 0.092)
		for dy in range(0, r.randi_range(4, 9)):
			for dx in range(0, r.randi_range(4, 9)):
				img.set_pixel(px + dx, py + dy, col)
	# brins d'herbe
	for n in 60:
		var x := r.randi_range(5, s - 5)
		var y := r.randi_range(6, s - 5)
		var c := Color(0.16, 0.26, 0.16) if r.randf() < 0.65 else Color(0.06, 0.10, 0.07)
		img.set_pixel(x, y, c)
		img.set_pixel(x, y - 1, c)
	# quelques fleurs/cailloux
	for n in 5:
		var x := r.randi_range(6, s - 6)
		var y := r.randi_range(6, s - 6)
		img.set_pixel(x, y, Color(0.58, 0.52, 0.30) if r.randf() < 0.5 else Color(0.45, 0.30, 0.45))
	return ImageTexture.create_from_image(img)
