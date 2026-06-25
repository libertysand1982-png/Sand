# Dungeon.gd — génère un niveau plateforme procédural : 3 zones + salle boss.
class_name TLHDungeon
extends Node2D

const GROUND_Y  := 520
const ZONE_W    := 1450
const ZONE_COUNT := 3
const BOSS_X    := 200.0 + ZONE_COUNT * ZONE_W

var _player: TLHPlayer
var _enemies: Array = []
var _arrows: Array = []
var _knives: Array = []
var _floats: Array = []
var _zone_alive: Dictionary = {}
var _zone_barriers: Array = []  # {body, door, zone, open}
var _boss: TLHJailer = null
var _boss_mother: TLHMother = null
var _boss_entrance_body: StaticBody2D = null
var _boss_entered := false
var _drain_arrows: Array = []

signal boss_hp_changed(pct: float)
signal boss_defeated()
signal boss_phase(n: int)
signal revelation_started()
signal boss_name_changed(name: String)

func build(player: TLHPlayer) -> void:
	_player = player
	_player.knife_fired.connect(_on_knife_fired)
	_player.hit_landed.connect(_on_hit_landed)

	_build_bg_and_floor()
	for z in ZONE_COUNT:
		_build_zone(z)
	_build_boss_zone()

# ── Level geometry ──────────────────────────────────────────────────────────────

func _build_bg_and_floor() -> void:
	var total_w := int(BOSS_X) + 1600
	var bg := ColorRect.new()
	bg.size = Vector2(total_w, GROUND_Y + 200)
	bg.position = Vector2(0, -300)
	bg.color = Color(0.04, 0.03, 0.07)
	bg.z_index = -20
	add_child(bg)

	# Stone floor
	_add_static_rect(Vector2(total_w, 80), Vector2(0, GROUND_Y), Color(0.20, 0.17, 0.24), true)

	# Distant backdrop "castle" shapes
	for i in 6:
		var bx := float(i) * 900 + randf_range(-100, 100)
		var bh := randf_range(80, 200)
		var bw := randf_range(40, 100)
		var tower := ColorRect.new()
		tower.size = Vector2(bw, bh)
		tower.position = Vector2(bx, GROUND_Y - bh)
		tower.color = Color(0.08, 0.06, 0.11)
		tower.z_index = -5
		add_child(tower)

func _build_zone(zone_idx: int) -> void:
	var x0 := 200.0 + zone_idx * ZONE_W
	_zone_alive[zone_idx] = 0

	# Platform rows at 3 heights
	var rng := RandomNumberGenerator.new()
	rng.seed = zone_idx * 997 + 13

	var heights := [GROUND_Y - 130, GROUND_Y - 250, GROUND_Y - 370]
	for row in heights:
		var count := rng.randi_range(2, 4)
		var section := ZONE_W / float(count + 1)
		for i in count:
			var px := x0 + section * (i + 1) + rng.randf_range(-70, 70)
			var pw := rng.randf_range(110, 220)
			_add_platform(px, row, pw)

	# Torch decorations
	for i in 3:
		var tx := x0 + ZONE_W * float(i + 1) / 4.0
		_add_torch(tx, GROUND_Y - 4)

	# Enemies
	_spawn_zone_enemies(x0, zone_idx)

	# Barrier at zone end
	var bx := x0 + ZONE_W - 16.0
	var barrier := _make_barrier(bx, zone_idx)
	_zone_barriers.append(barrier)

func _spawn_zone_enemies(x0: float, zone_idx: int) -> void:
	var hp_scale := 1.0 + zone_idx * 0.45 + GlobalTimer.urgency() * 0.6
	var guard_n  := 2 + zone_idx + (1 if GlobalTimer.urgency() > 0.5 else 0)
	var archer_n := 1 + zone_idx

	for i in guard_n:
		var x := x0 + 250.0 + (ZONE_W - 500.0) * float(i) / guard_n + randf_range(-50, 50)
		var g := TLHGuard.new()
		g.collision_layer = 2
		g.collision_mask  = 4
		g.setup(Vector2(x, GROUND_Y - 32), _player, hp_scale)
		g.died.connect(_on_enemy_died.bind(zone_idx))
		add_child(g)
		_enemies.append(g)
		_zone_alive[zone_idx] += 1

	for i in archer_n:
		var x := x0 + 400.0 + (ZONE_W - 700.0) * float(i) / archer_n + randf_range(-40, 40)
		var a := TLHArcher.new()
		a.collision_layer = 2
		a.collision_mask  = 4
		a.setup(Vector2(x, GROUND_Y - 28), _player, hp_scale)
		a.died.connect(_on_enemy_died.bind(zone_idx))
		a.arrow_shot.connect(_on_arrow_shot)
		add_child(a)
		_enemies.append(a)
		_zone_alive[zone_idx] += 1

func _build_boss_zone() -> void:
	# Entrance door (locked until zone 2 cleared)
	var entrance := _make_barrier(BOSS_X + 10.0, -1)  # zone -1 = boss entrance
	_boss_entrance_body = entrance.body
	entrance.door.color = Color(0.35, 0.1, 0.45, 0.9)
	_zone_barriers.append(entrance)

	# Arena platforms
	_add_platform(BOSS_X + 300, GROUND_Y - 140, 500)
	_add_platform(BOSS_X + 750, GROUND_Y - 240, 280)
	_add_platform(BOSS_X + 150, GROUND_Y - 220, 200)

	# Son — prisonnier dans une cage visuelle
	var cage_x := BOSS_X + 1100.0
	_add_static_rect(Vector2(6, 80), Vector2(cage_x - 3,       GROUND_Y - 80), Color(0.5, 0.45, 0.3), false)
	_add_static_rect(Vector2(6, 80), Vector2(cage_x + 44,      GROUND_Y - 80), Color(0.5, 0.45, 0.3), false)
	_add_static_rect(Vector2(50, 6), Vector2(cage_x,           GROUND_Y - 80), Color(0.5, 0.45, 0.3), false)
	var son_rect := ColorRect.new()
	son_rect.size = Vector2(28, 44)
	son_rect.color = Color(0.75, 0.85, 1.0)
	son_rect.position = Vector2(cage_x + 9, GROUND_Y - 76)
	add_child(son_rect)
	var son_lbl := Label.new()
	son_lbl.text = "TON FILS"
	son_lbl.add_theme_font_size_override("font_size", 11)
	son_lbl.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0))
	son_lbl.position = Vector2(cage_x - 4, GROUND_Y - 96)
	add_child(son_lbl)

	# Boss title sign
	var sign_lbl := Label.new()
	sign_lbl.text = "— LE GEÔLIER —"
	sign_lbl.add_theme_font_size_override("font_size", 22)
	sign_lbl.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3))
	sign_lbl.position = Vector2(BOSS_X + 550, GROUND_Y - 420)
	add_child(sign_lbl)

	# Spawn boss
	_boss = TLHJailer.new()
	_boss.collision_layer = 2
	_boss.collision_mask  = 4
	_boss.setup(Vector2(BOSS_X + 700, GROUND_Y - 50), _player)
	_boss.died.connect(_on_boss_died)
	_boss.hp_changed.connect(func(c, m): emit_signal("boss_hp_changed", float(c) / float(m)))
	_boss.phase_changed.connect(func(n): emit_signal("boss_phase", n))
	_boss.burst_bullet.connect(_on_burst_bullet)
	add_child(_boss)

# ── Helpers ─────────────────────────────────────────────────────────────────────

func _add_platform(cx: float, y: float, w: float) -> void:
	var sb := StaticBody2D.new()
	sb.collision_layer = 4

	var col := CollisionShape2D.new()
	var s := RectangleShape2D.new()
	s.size = Vector2(w, 18)
	col.shape = s
	col.position = Vector2(cx, y + 9)
	sb.add_child(col)

	var r := ColorRect.new()
	r.size = Vector2(w, 18)
	r.position = Vector2(cx - w / 2.0, y)
	r.color = Color(0.24, 0.19, 0.30)
	sb.add_child(r)
	# Highlight edge
	var edge := ColorRect.new()
	edge.size = Vector2(w, 3)
	edge.position = Vector2(cx - w / 2.0, y)
	edge.color = Color(0.38, 0.30, 0.48)
	sb.add_child(edge)
	add_child(sb)

func _add_static_rect(sz: Vector2, pos: Vector2, color: Color, has_collision: bool) -> void:
	if has_collision:
		var sb := StaticBody2D.new()
		sb.collision_layer = 4
		var col := CollisionShape2D.new()
		var s := RectangleShape2D.new()
		s.size = sz
		col.shape = s
		col.position = pos + sz / 2.0
		sb.add_child(col)
		var r := ColorRect.new()
		r.size = sz
		r.position = pos
		r.color = color
		sb.add_child(r)
		add_child(sb)
	else:
		var r := ColorRect.new()
		r.size = sz
		r.position = pos
		r.color = color
		add_child(r)

func _add_torch(x: float, y: float) -> void:
	var base := ColorRect.new()
	base.size = Vector2(6, 16)
	base.position = Vector2(x - 3, y - 16)
	base.color = Color(0.4, 0.3, 0.2)
	add_child(base)
	var flame := ColorRect.new()
	flame.size = Vector2(8, 8)
	flame.position = Vector2(x - 4, y - 22)
	flame.color = Color(1.0, 0.6, 0.1)
	add_child(flame)

func _make_barrier(x: float, zone_idx: int) -> Dictionary:
	var h := GROUND_Y + 300
	var door := ColorRect.new()
	door.size = Vector2(22, h)
	door.position = Vector2(x, -300)
	door.color = Color(0.55, 0.1, 0.1, 0.9)
	add_child(door)

	var sb := StaticBody2D.new()
	sb.collision_layer = 4
	var col := CollisionShape2D.new()
	var s := RectangleShape2D.new()
	s.size = Vector2(22, h)
	col.shape = s
	col.position = Vector2(x + 11, -300 + h / 2.0)
	sb.add_child(col)
	add_child(sb)

	return {"body": sb, "door": door, "zone": zone_idx, "open": false}

# ── Update ──────────────────────────────────────────────────────────────────────

func _process(delta: float) -> void:
	_update_arrows(delta)
	_update_drain_arrows(delta)
	_update_floats(delta)
	_check_boss_entrance()

func _check_boss_entrance() -> void:
	if _boss_entered or not _player or not is_instance_valid(_player):
		return
	# Boss entrance opens only when all zones cleared
	if _player.global_position.x > BOSS_X + 200.0:
		_boss_entered = true
		# Close entrance behind the player
		if is_instance_valid(_boss_entrance_body):
			_boss_entrance_body.queue_free()

# ── Signals ─────────────────────────────────────────────────────────────────────

func _on_enemy_died(pos: Vector2, cells: int, zone_idx: int) -> void:
	RunData.cells += cells
	_spawn_float(pos, "+cell", Color(0.55, 0.95, 0.55))
	_enemies = _enemies.filter(func(e): return is_instance_valid(e) and not e.is_dead())
	_player.register_enemies(_enemies)
	_zone_alive[zone_idx] = maxi(0, _zone_alive.get(zone_idx, 1) - 1)
	if _zone_alive[zone_idx] <= 0:
		_open_zone(zone_idx)

func _open_zone(zone_idx: int) -> void:
	for b in _zone_barriers:
		if b.zone == zone_idx and not b.open:
			b.open = true
			var scroll_x := b.door.position.x + 11.0
			if is_instance_valid(b.door):
				b.door.queue_free()
			if is_instance_valid(b.body):
				b.body.queue_free()
			_spawn_loot_scroll(Vector2(scroll_x, GROUND_Y - 24))
			if zone_idx == ZONE_COUNT - 1:
				_open_boss_entrance()
			break

func _open_boss_entrance() -> void:
	for b in _zone_barriers:
		if b.zone == -1 and not b.open:
			b.open = true
			if is_instance_valid(b.door):
				b.door.queue_free()
			if is_instance_valid(b.body):
				b.body.queue_free()
			break

func _spawn_loot_scroll(pos: Vector2) -> void:
	var area := Area2D.new()
	area.collision_layer = 0
	area.collision_mask  = 1
	var r := ColorRect.new()
	r.size = Vector2(22, 28)
	r.color = Color(0.9, 0.82, 0.3)
	r.position = Vector2(-11, -14)
	area.add_child(r)
	var lbl := Label.new()
	lbl.text = "?"
	lbl.add_theme_font_size_override("font_size", 20)
	lbl.position = Vector2(-6, -18)
	area.add_child(lbl)
	var col := CollisionShape2D.new()
	var s := CircleShape2D.new()
	s.radius = 18.0
	col.shape = s
	area.add_child(col)
	area.global_position = pos
	area.body_entered.connect(_on_scroll_picked.bind(area))
	add_child(area)

func _on_scroll_picked(body: Node, area: Area2D) -> void:
	if body != _player or not is_instance_valid(area): return
	var rolls := ["hp_boost", "dmg_boost", "speed_boost", "knife_upgrade"]
	var chosen := rolls[randi() % rolls.size()]
	RunData.apply_scroll(chosen)
	_player.hp = RunData.hp
	_player.max_hp = RunData.max_hp
	_spawn_float(area.global_position, "SCROLL !", Color(1.0, 0.9, 0.3))
	area.queue_free()

func _on_arrow_shot(from: Vector2, velocity_vec: Vector2, damage: int) -> void:
	var arrow := TLHArrow.new()
	arrow.setup(from, velocity_vec, damage)
	add_child(arrow)
	_arrows.append(arrow)

func _on_burst_bullet(from: Vector2, velocity_vec: Vector2, damage: int) -> void:
	var arrow := TLHArrow.new()
	arrow.setup(from, velocity_vec, damage)
	add_child(arrow)
	_arrows.append(arrow)

func _on_drain_bullet(from: Vector2, velocity_vec: Vector2, damage: int) -> void:
	var arrow := TLHArrow.new()
	arrow.setup(from, velocity_vec, damage)
	arrow.modulate = Color(0.65, 0.10, 0.85)
	add_child(arrow)
	_drain_arrows.append(arrow)

func _on_bat_bullet(from: Vector2, velocity_vec: Vector2, damage: int) -> void:
	var arrow := TLHArrow.new()
	arrow.setup(from, velocity_vec, damage)
	arrow.modulate = Color(0.12, 0.08, 0.18)
	add_child(arrow)
	_arrows.append(arrow)

func _on_knife_fired(from_pos: Vector2, direction: int) -> void:
	var knife := TLHKnife.new()
	knife.setup(from_pos, direction, 530.0, RunData.knife_dmg, _enemies)
	add_child(knife)
	_knives.append(knife)

func _on_hit_landed(pos: Vector2, dmg: int) -> void:
	_spawn_float(pos, str(dmg), Color(1.0, 0.95, 0.55))

func _on_boss_died() -> void:
	_spawn_float(_boss.global_position if is_instance_valid(_boss) else Vector2(BOSS_X + 700, 400),
				 "PHASE 2 !", Color(0.80, 0.30, 1.0))
	GlobalTimer.pause()
	emit_signal("revelation_started")
	var t := create_tween()
	t.tween_interval(5.5)
	t.tween_callback(_spawn_mother)

func _spawn_mother() -> void:
	GlobalTimer.start()
	_boss_mother = TLHMother.new()
	_boss_mother.collision_layer = 2
	_boss_mother.collision_mask  = 4
	_boss_mother.setup(Vector2(BOSS_X + 700, GROUND_Y - 50), _player)
	_boss_mother.died.connect(_on_mother_died)
	_boss_mother.hp_changed.connect(func(c, _m): emit_signal("boss_hp_changed", float(c) / float(TLHMother.HP_MAX)))
	_boss_mother.phase_changed.connect(func(n): emit_signal("boss_phase", n))
	_boss_mother.drain_bullet.connect(_on_drain_bullet)
	_boss_mother.bat_bullet.connect(_on_bat_bullet)
	add_child(_boss_mother)
	emit_signal("boss_name_changed", "LA MÈRE")
	emit_signal("boss_hp_changed", 1.0)

func _on_mother_died() -> void:
	_spawn_float(_boss_mother.global_position if is_instance_valid(_boss_mother) else Vector2(BOSS_X + 700, 400),
				 "VICTOIRE !", Color(1.0, 0.70, 1.0))
	emit_signal("boss_defeated")

# ── Projectile updates ──────────────────────────────────────────────────────────

func _update_arrows(delta: float) -> void:
	for i in range(_arrows.size() - 1, -1, -1):
		if not is_instance_valid(_arrows[i]):
			_arrows.remove_at(i)
			continue
		var arrow: TLHArrow = _arrows[i]
		if _player and is_instance_valid(_player):
			if arrow.global_position.distance_to(_player.global_position) < 20.0:
				_player.take_damage(arrow.dmg, arrow.vel.normalized() * 130.0)
				arrow.queue_free()
				_arrows.remove_at(i)

func _update_drain_arrows(delta: float) -> void:
	for i in range(_drain_arrows.size() - 1, -1, -1):
		if not is_instance_valid(_drain_arrows[i]):
			_drain_arrows.remove_at(i)
			continue
		var arrow: TLHArrow = _drain_arrows[i]
		if _player and is_instance_valid(_player):
			if arrow.global_position.distance_to(_player.global_position) < 22.0:
				_player.take_damage(arrow.dmg, arrow.vel.normalized() * 80.0)
				if is_instance_valid(_boss_mother):
					_boss_mother.heal(25)
				arrow.queue_free()
				_drain_arrows.remove_at(i)

# ── Floating numbers ────────────────────────────────────────────────────────────

func _spawn_float(pos: Vector2, text: String, color: Color) -> void:
	var l := Label.new()
	l.text = text
	l.global_position = pos + Vector2(-12, -8)
	l.add_theme_color_override("font_color", color)
	l.add_theme_font_size_override("font_size", 17)
	l.z_index = 60
	add_child(l)
	_floats.append({"node": l, "life": 0.85, "vy": -44.0})

func _update_floats(delta: float) -> void:
	for i in range(_floats.size() - 1, -1, -1):
		var f = _floats[i]
		var l: Label = f["node"]
		if not is_instance_valid(l):
			_floats.remove_at(i)
			continue
		l.position.y += f["vy"] * delta
		f["life"] -= delta
		l.modulate.a = clampf(f["life"] / 0.35, 0.0, 1.0)
		if f["life"] <= 0.0:
			l.queue_free()
			_floats.remove_at(i)

func get_boss_hp_pct() -> float:
	if is_instance_valid(_boss_mother):
		return float(_boss_mother.hp) / float(TLHMother.HP_MAX)
	if _boss == null or not is_instance_valid(_boss):
		return -1.0
	return float(_boss.hp) / TLHJailer.HP_MAX
