# Main.gd — contrôleur du jeu : boucle, spawn, collisions, niveaux, états.
extends Node2D

const WORLD := 4000.0
const MAX_ENEMIES := 280

enum State { MENU, PLAYING, LEVELUP, PAUSED, GAMEOVER }

const UPGRADES := [
	{"name": "Lame jumelle",     "desc": "+1 projectile",        "id": "count"},
	{"name": "Frappe rapide",    "desc": "-15% recharge",        "id": "rate"},
	{"name": "Affûtage",         "desc": "+30% dégâts",          "id": "dmg"},
	{"name": "Bottes ailées",    "desc": "+12% vitesse",         "id": "speed"},
	{"name": "Vitalité",         "desc": "+25 PV max (soigne)",  "id": "hp"},
	{"name": "Aimant",           "desc": "+30% ramassage",       "id": "magnet"},
	{"name": "Perforation",      "desc": "traverse +1 ennemi",   "id": "pierce"},
	{"name": "Projectile lourd", "desc": "+25% vitesse/taille",  "id": "heavy"},
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
var enemy_tex: Dictionary = {}

# ============================================================
func _ready() -> void:
	randomize()
	_setup_input()

	enemy_tex = {
		"gobelin": load("res://assets/characters/gobelin.png"),
		"bandit": load("res://assets/characters/bandit.png"),
		"garde": load("res://assets/characters/garde.png"),
	}

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
	hud.upgrade_chosen.connect(_apply_upgrade)
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

func _mk(action: String, keys: Array) -> void:
	if InputMap.has_action(action):
		InputMap.erase_action(action)
	InputMap.add_action(action)
	for k in keys:
		var ev := InputEventKey.new()
		ev.keycode = k
		InputMap.action_add_event(action, ev)

# ============================================================
func start_game() -> void:
	sfx.play("click", 0.5)
	for e in enemies:
		e.queue_free()
	for p in projectiles:
		p.queue_free()
	for g in gems:
		g.queue_free()
	for f in floats:
		f["node"].queue_free()
	enemies.clear()
	projectiles.clear()
	gems.clear()
	floats.clear()

	elapsed = 0.0
	kills = 0
	spawn_timer = 0.0
	level_queue = 0
	player.reset(Vector2(WORLD / 2.0, WORLD / 2.0))
	player.visible = true
	hud.hide_overlays()
	hud.show_hud(true)
	state = State.PLAYING

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("vs_pause"):
		_toggle_pause()
	elif event.is_action_pressed("vs_mute"):
		sfx.muted = not sfx.muted
		hud.set_muted(sfx.muted)

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

	# Déplacement
	var dir := Input.get_vector("vs_left", "vs_right", "vs_up", "vs_down")
	p.position.x = clampf(p.position.x + dir.x * p.speed * delta, 24.0, WORLD - 24.0)
	p.position.y = clampf(p.position.y + dir.y * p.speed * delta, 24.0, WORLD - 24.0)
	if dir.x < 0.0:
		p.facing = -1
	elif dir.x > 0.0:
		p.facing = 1
	p.sprite.scale.x = p.base_scale.x * p.facing
	if dir.length() > 0.01:
		p.bob += delta * 10.0
		p.sprite.position.y = -absf(sin(p.bob)) * 3.0
		p.step_timer -= delta
		if p.step_timer <= 0.0:
			sfx.play("step", 0.12)
			p.step_timer = 0.33
	else:
		p.sprite.position.y = 0.0
	if p.invuln > 0.0:
		p.invuln -= delta
	p.sprite.modulate.a = 0.45 if (p.invuln > 0.0 and int(time * 20.0) % 2 == 0) else 1.0

	# Arme automatique
	p.fire_cd -= delta
	if p.fire_cd <= 0.0 and enemies.size() > 0:
		_fire()
		p.fire_cd = p.fire_interval

	_spawns(delta)
	_update_enemies(delta)
	_update_projectiles(delta)
	_cull_enemies()
	_update_gems(delta)
	_update_floats(delta)

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
	sfx.play("slice" if randf() < 0.5 else "slice2", 0.22)

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

func _spawn_one() -> void:
	var t := elapsed
	var r := randf()
	var tkey := "gobelin"
	if t < 30.0:
		tkey = "gobelin"
	elif t < 75.0:
		tkey = "gobelin" if r < 0.7 else "bandit"
	elif t < 150.0:
		tkey = "gobelin" if r < 0.45 else ("bandit" if r < 0.85 else "garde")
	else:
		tkey = "gobelin" if r < 0.3 else ("bandit" if r < 0.7 else "garde")

	var hp_scale := 1.0 + (elapsed / 60.0) * 0.22
	var vsize := get_viewport_rect().size
	var radius := maxf(vsize.x, vsize.y) / 2.0 + 70.0
	var ang := randf() * TAU
	var pos := player.position + Vector2.from_angle(ang) * radius
	pos.x = clampf(pos.x, 20.0, WORLD - 20.0)
	pos.y = clampf(pos.y, 20.0, WORLD - 20.0)

	var e := VSEnemy.new()
	e.setup(tkey, pos, hp_scale, enemy_tex[tkey])
	world.add_child(e)
	enemies.append(e)

# ----- Ennemis -----
func _update_enemies(delta: float) -> void:
	var p := player
	for e in enemies:
		if e.dead:
			continue
		var to := p.position - e.position
		var d := to.length()
		if d > 0.001:
			e.position += to / d * e.speed * delta
		e.facing = -1 if to.x < 0.0 else 1

		var punch := 1.0
		if e.hitflash > 0.0:
			e.hitflash -= delta
			var tt := clampf(e.hitflash / 0.12, 0.0, 1.0)
			punch = lerpf(1.0, 1.25, tt)
			e.sprite.self_modulate = Color(1, 1, 1).lerp(Color(2.4, 2.4, 2.4), tt)
		else:
			e.sprite.self_modulate = Color(1, 1, 1)
		e.sprite.scale = Vector2(e.base_scale.x * punch * e.facing, e.base_scale.y * punch)
		if e.show_bar:
			e.queue_redraw()

		# Contact avec le joueur
		if d < e.radius + p.radius and p.invuln <= 0.0:
			p.hp -= e.dmg
			p.invuln = 0.6
			sfx.play("hurt", 0.4)
			_spawn_text(p.position + Vector2(0, -28), "-" + str(int(e.dmg)), Color(1, 0.42, 0.42))

func _cull_enemies() -> void:
	for i in range(enemies.size() - 1, -1, -1):
		if enemies[i].dead:
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
			if e.dead or pr.hitset.has(e):
				continue
			var rr := e.radius + pr.size
			if pp.distance_squared_to(e.position) <= rr * rr:
				pr.hitset[e] = true
				e.hp -= pr.dmg
				e.hitflash = 0.12
				_spawn_text(e.position + Vector2(0, -e.size * 0.4), str(int(pr.dmg)), Color(1, 0.91, 0.66))
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
	e.queue_free()

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
	p.xp += amount
	while p.xp >= p.xp_to_next:
		p.xp -= p.xp_to_next
		p.level += 1
		p.xp_to_next = int(round(p.xp_to_next * 1.32 + 3.0))
		level_queue += 1

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
	sfx.play("click", 0.5)
	hud.hide_overlays()
	if level_queue > 0:
		_open_levelup()
	else:
		state = State.PLAYING

# ----- Fin -----
func _game_over() -> void:
	state = State.GAMEOVER
	hud.show_hud(false)
	var m := int(elapsed / 60.0)
	var s := int(fmod(elapsed, 60.0))
	hud.show_gameover("%02d:%02d" % [m, s], player.level, kills)

func _refresh_hud() -> void:
	var p := player
	var m := int(elapsed / 60.0)
	var s := int(fmod(elapsed, 60.0))
	hud.set_xp(p.xp_pct(), p.level)
	hud.set_hp(p.hp, p.maxhp)
	hud.set_time("%02d:%02d" % [m, s])
	hud.set_kills(kills)

# ----- Sol procédural -----
func _make_ground_texture() -> Texture2D:
	var s := 128
	var img := Image.create(s, s, false, Image.FORMAT_RGBA8)
	var ca := Color(0.102, 0.18, 0.122)
	var cb := Color(0.086, 0.153, 0.106)
	for y in s:
		for x in s:
			var cell := (int(x / 64) + int(y / 64)) % 2
			img.set_pixel(x, y, ca if cell == 0 else cb)
	for n in 24:
		img.set_pixel(randi() % s, randi() % s, Color(0.129, 0.227, 0.153))
	return ImageTexture.create_from_image(img)
