# Main.gd — contrôleur du jeu : boucle, spawn, collisions, niveaux, états, audio.
extends Node2D

const WORLD := 4000.0
const MAX_ENEMIES := 280

enum State { MENU, PLAYING, LEVELUP, PAUSED, GAMEOVER }

const ENEMY_DEF := {
	"goblin":    {"hp": 26.0,  "speed": 82.0, "dmg": 8.0,  "xp": 1, "radius": 18.0, "scale": 0.58, "bar": false},
	"flyingeye": {"hp": 40.0,  "speed": 96.0, "dmg": 10.0, "xp": 3, "radius": 17.0, "scale": 0.52, "bar": false},
	"mushroom":  {"hp": 60.0,  "speed": 52.0, "dmg": 13.0, "xp": 3, "radius": 20.0, "scale": 0.60, "bar": false},
	"skeleton":  {"hp": 160.0, "speed": 46.0, "dmg": 20.0, "xp": 7, "radius": 22.0, "scale": 0.70, "bar": true},
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
	}

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
	player.set_frames(_knight_sf())
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
	hud.music_changed.connect(sfx.set_music_volume)
	hud.sfx_changed.connect(sfx.set_sfx_volume)
	hud.show_menu()
	state = State.MENU
	sfx.start_music()

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
	floats.clear()

func start_game() -> void:
	sfx.play("click", 0.5)
	_clear_entities()
	elapsed = 0.0
	kills = 0
	spawn_timer = 0.0
	level_queue = 0
	player.reset(Vector2(WORLD / 2.0, WORLD / 2.0))
	player.visible = true
	hud.hide_overlays()
	hud.show_hud(true)
	sfx.start_music()
	state = State.PLAYING

func _to_menu() -> void:
	state = State.MENU
	_clear_entities()
	player.visible = false
	hud.show_hud(false)
	hud.show_menu()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("vs_pause"):
		_toggle_pause()
	elif event.is_action_pressed("vs_mute"):
		sfx.set_muted(not sfx.muted)
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
		return "goblin"
	elif t < 70.0:
		return "goblin" if r < 0.6 else "flyingeye"
	elif t < 140.0:
		if r < 0.4: return "goblin"
		elif r < 0.65: return "flyingeye"
		else: return "mushroom"
	else:
		if r < 0.25: return "goblin"
		elif r < 0.45: return "flyingeye"
		elif r < 0.72: return "mushroom"
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
		e.anim.flip_h = to.x < 0.0

		var punch := 1.0
		if e.hitflash > 0.0:
			e.hitflash -= delta
			var tt := clampf(e.hitflash / 0.12, 0.0, 1.0)
			punch = lerpf(1.0, 1.18, tt)
			e.anim.self_modulate = Color(1, 1, 1).lerp(Color(2.2, 2.2, 2.2), tt)
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
	player.anim.play("death")
	player.anim.modulate.a = 1.0
	sfx.play("death", 0.7)
	var m := int(elapsed / 60.0)
	var s := int(fmod(elapsed, 60.0))
	hud.show_hud(false)
	hud.show_gameover("%02d:%02d" % [m, s], player.level, kills)

func _refresh_hud() -> void:
	var p := player
	var m := int(elapsed / 60.0)
	var s := int(fmod(elapsed, 60.0))
	hud.set_xp(p.xp_pct(), p.level)
	hud.set_hp(p.hp, p.maxhp)
	hud.set_time("%02d:%02d" % [m, s])
	hud.set_kills(kills)

# ============================================================
# Construction des animations
func _knight_sf() -> SpriteFrames:
	var sf := SpriteFrames.new()
	_add_files(sf, "idle", "res://assets/knight/idle/", 8, 8.0, true)
	_add_files(sf, "run", "res://assets/knight/run/", 10, 12.0, true)
	_add_files(sf, "death", "res://assets/knight/death/", 10, 10.0, false)
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

func _enemy_sf(move_path: String, move_count: int, death_path: String, death_count: int) -> SpriteFrames:
	var sf := SpriteFrames.new()
	_add_sheet(sf, "move", load(move_path), move_count, 150, 10.0, true)
	_add_sheet(sf, "death", load(death_path), death_count, 150, 12.0, false)
	return sf

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
