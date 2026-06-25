# Player.gd — chevalier héros. Platformer Dead Cells-like avec dash, combo, couteaux.
class_name TLHPlayer
extends CharacterBody2D

const SPEED := 235.0
const JUMP_VEL := -490.0
const GRAVITY := 980.0
const DASH_SPEED := 640.0
const DASH_DUR := 0.14
const DASH_CD := 0.78
const COYOTE_TIME := 0.12
const JUMP_BUFFER := 0.10
const MELEE_REACH := 55.0
const MELEE_DMG := 22
const INVULN_DUR := 0.75
const SPRITE_SIZE := 40.0

var sprite: Sprite2D
var cam: Camera2D

# Physics state
var coyote_t := 0.0
var jump_buf := 0.0
var dash_t := 0.0
var dash_cd := 0.0
var dash_dir := 1
var was_floor := false
var knockback := Vector2.ZERO

# Combat state
var attack_t := 0.0
var combo := 0
var combo_reset_t := 0.0
var invuln := 0.0
var knife_cd := 0.0
var facing := 1

var hp: int
var max_hp: int
var kills := 0

var _enemies: Array = []

signal died()
signal knife_fired(from_pos: Vector2, direction: int)
signal hit_landed(pos: Vector2, dmg: int)

func _ready() -> void:
	hp = RunData.hp
	max_hp = RunData.max_hp

	sprite = Sprite2D.new()
	sprite.texture = load("res://assets/characters/hero.png")
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.scale = Vector2.ONE * (SPRITE_SIZE / 64.0)
	add_child(sprite)

	var col := CollisionShape2D.new()
	var shape := CapsuleShape2D.new()
	shape.radius = 13.0
	shape.height = 32.0
	col.shape = shape
	col.position = Vector2(0, -4)
	add_child(col)

	cam = Camera2D.new()
	cam.position_smoothing_enabled = true
	cam.position_smoothing_speed = 7.0
	cam.drag_horizontal_enabled = true
	cam.drag_horizontal_offset = 0.12
	add_child(cam)
	cam.make_current()

	_setup_input()

func _setup_input() -> void:
	_mk("p_left",  [KEY_Q, KEY_A, KEY_LEFT])
	_mk("p_right", [KEY_D, KEY_RIGHT])
	_mk("p_jump",  [KEY_SPACE, KEY_Z, KEY_W, KEY_UP])
	_mk("p_dash",  [KEY_SHIFT, KEY_CTRL])
	_mk("p_melee", [KEY_J, KEY_X, KEY_F])
	_mk("p_knife", [KEY_K, KEY_C, KEY_G])
	_mk("p_pause", [KEY_ESCAPE, KEY_P])

func _mk(action: String, keys: Array) -> void:
	if InputMap.has_action(action):
		InputMap.erase_action(action)
	InputMap.add_action(action)
	for k in keys:
		var ev := InputEventKey.new()
		ev.keycode = k
		InputMap.action_add_event(action, ev)

func register_enemies(arr: Array) -> void:
	_enemies = arr

# ── Input ──────────────────────────────────────────────────────────────────────

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("p_pause"):
		GameManager.toggle_pause()

func _process(delta: float) -> void:
	_tick_timers(delta)
	_handle_melee_input()
	_handle_knife_input()
	_update_visuals()

func _physics_process(delta: float) -> void:
	var on_floor := is_on_floor()

	if was_floor and not on_floor:
		coyote_t = COYOTE_TIME
	was_floor = on_floor
	if coyote_t > 0.0:
		coyote_t -= delta

	if not on_floor:
		velocity.y += GRAVITY * delta
		velocity.y = minf(velocity.y, 900.0)

	# Dash overrides everything
	if dash_t > 0.0:
		velocity.x = dash_dir * DASH_SPEED
		velocity.y = 0.0
		dash_t -= delta
		move_and_slide()
		return

	var dir_x := Input.get_axis("p_left", "p_right")
	var target_x := dir_x * SPEED * RunData.speed_mult
	velocity.x = lerpf(velocity.x, target_x, 14.0 * delta)

	velocity += knockback
	knockback = knockback.move_toward(Vector2.ZERO, 550.0 * delta)

	if jump_buf > 0.0 and (on_floor or coyote_t > 0.0):
		velocity.y = JUMP_VEL
		AudioManager.play_sfx("player_jump")
		coyote_t = 0.0
		jump_buf = 0.0

	move_and_slide()

# ── Timers ─────────────────────────────────────────────────────────────────────

func _tick_timers(delta: float) -> void:
	if dash_cd > 0.0:   dash_cd   -= delta
	if attack_t > 0.0:  attack_t  -= delta
	if knife_cd > 0.0:  knife_cd  -= delta
	if invuln   > 0.0:  invuln    -= delta
	if combo_reset_t > 0.0:
		combo_reset_t -= delta
		if combo_reset_t <= 0.0:
			combo = 0

	if Input.is_action_just_pressed("p_jump"):
		jump_buf = JUMP_BUFFER
	if jump_buf > 0.0:
		jump_buf -= delta

	if Input.is_action_just_pressed("p_dash") and dash_cd <= 0.0 and dash_t <= 0.0:
		_start_dash()

# ── Actions ────────────────────────────────────────────────────────────────────

func _start_dash() -> void:
	var dir_x := Input.get_axis("p_left", "p_right")
	if dir_x != 0.0:
		dash_dir = int(sign(dir_x))
	dash_t = DASH_DUR
	dash_cd = DASH_CD
	invuln = DASH_DUR + 0.08
	AudioManager.play_sfx("player_dash")

func _handle_melee_input() -> void:
	if not Input.is_action_just_pressed("p_melee"):
		return
	if attack_t > 0.0:
		return
	combo = (combo + 1) % 3
	combo_reset_t = 0.6
	attack_t = 0.26
	AudioManager.play_sfx("sword_finisher" if combo == 2 else "sword_swing")

	# Finisher hits harder
	var mult := 1.6 if combo == 2 else 1.0
	var dmg := int(MELEE_DMG * RunData.damage_mult * mult)

	for e in _enemies:
		if not is_instance_valid(e) or e.is_dead():
			continue
		var diff := e.global_position - global_position
		if abs(diff.x) < MELEE_REACH and abs(diff.y) < 44.0 and int(sign(diff.x)) == facing:
			e.take_damage(dmg, Vector2(facing * 200.0, -110.0))
			AudioManager.play_sfx("sword_hit", -2.0)
			emit_signal("hit_landed", e.global_position, dmg)

func _handle_knife_input() -> void:
	if not Input.is_action_just_pressed("p_knife"):
		return
	if knife_cd > 0.0:
		return
	knife_cd = 0.42
	AudioManager.play_sfx("knife_throw")
	emit_signal("knife_fired", global_position + Vector2(facing * 14.0, -6.0), facing)

# ── Damage ─────────────────────────────────────────────────────────────────────

func take_damage(amount: int, kb: Vector2 = Vector2.ZERO) -> void:
	if invuln > 0.0:
		return
	if RunData.take_damage(amount):
		hp = 0
		set_physics_process(false)
		set_process(false)
		emit_signal("died")
		return
	hp = RunData.hp
	AudioManager.play_sfx("player_hurt")
	invuln = INVULN_DUR
	knockback = kb

# ── Visuals ────────────────────────────────────────────────────────────────────

func _update_visuals() -> void:
	var dir_x := Input.get_axis("p_left", "p_right")
	if dir_x > 0.0:
		facing = 1
	elif dir_x < 0.0:
		facing = -1
	sprite.scale.x = abs(sprite.scale.x) * facing

	if dash_t > 0.0:
		sprite.modulate = Color(0.5, 0.8, 1.0, 0.6)
	elif invuln > 0.0:
		var flash: int = int(Time.get_ticks_msec() / 55.0) % 2
		sprite.modulate.a = 0.35 if flash == 0 else 1.0
	else:
		sprite.modulate = Color(1, 1, 1, 1)
