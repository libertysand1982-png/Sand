# Mother.gd — LA MÈRE. Boss final véritable. Vampire.
# Sprite : res://assets/characters/mother.png si présent, sinon garde.png teinté violet.
class_name TLHMother
extends CharacterBody2D

const HP_MAX     := 900
const SIGHT      := 950.0
const MOVE_SPEED := 140.0
const SPRITE_SIZE := 48.0

enum Phase { ONE, TWO, THREE }
enum FSM { IDLE, GLIDE, SWIPE, DRAIN, BAT_SWARM, SHADOW, STAGGER, DEAD }

var sprite: Sprite2D
var _state: FSM = FSM.IDLE
var _phase: Phase = Phase.ONE
var hp: int = HP_MAX
var _player: Node2D
var _time := 0.0
var _attack_cd := 0.0
var _stagger_t := 0.0
var _glide_t := 0.0
var _glide_dir := 1
var _shadow_t := 0.0
var _shadow_active := false
var _hitflash := 0.0
var _base_modulate := Color(1, 1, 1)

signal drain_bullet(from: Vector2, velocity_vec: Vector2, damage: int)
signal bat_bullet(from: Vector2, velocity_vec: Vector2, damage: int)
signal died()
signal hp_changed(current: int, maximum: int)
signal phase_changed(n: int)

func setup(pos: Vector2, player: Node2D) -> void:
	global_position = pos
	_player = player
	hp = HP_MAX

	sprite = Sprite2D.new()
	var tex_path := "res://assets/characters/mother.png"
	if ResourceLoader.exists(tex_path):
		sprite.texture = load(tex_path)
		_base_modulate = Color(1, 1, 1)
	else:
		sprite.texture = load("res://assets/characters/garde.png")
		_base_modulate = Color(0.55, 0.15, 0.70)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.scale = Vector2.ONE * (SPRITE_SIZE / 64.0)
	sprite.modulate = _base_modulate
	add_child(sprite)

	var col := CollisionShape2D.new()
	var s := CapsuleShape2D.new()
	s.radius = 13.0
	s.height = 28.0
	col.shape = s
	col.position = Vector2(0, -4)
	add_child(col)

	_attack_cd = randf_range(1.5, 2.5)

func is_dead() -> bool:
	return _state == FSM.DEAD

func take_damage(amount: int, kb: Vector2 = Vector2.ZERO) -> void:
	if is_dead() or _shadow_active: return
	hp -= amount
	_hitflash = 0.12
	velocity += kb
	emit_signal("hp_changed", hp, HP_MAX)
	if hp <= 0:
		_die()
	else:
		AudioManager.play_sfx("enemy_hurt", -4.0)
		_check_phase()
		_state = FSM.STAGGER
		_stagger_t = 0.22

func heal(amount: int) -> void:
	if is_dead(): return
	hp = mini(hp + amount, HP_MAX)
	emit_signal("hp_changed", hp, HP_MAX)

func _die() -> void:
	_state = FSM.DEAD
	emit_signal("died")
	queue_free()

func _check_phase() -> void:
	var pct := float(hp) / float(HP_MAX)
	if _phase == Phase.ONE and pct <= 0.60:
		_phase = Phase.TWO
		emit_signal("phase_changed", 2)
		_attack_cd = 0.3
	elif _phase == Phase.TWO and pct <= 0.30:
		_phase = Phase.THREE
		emit_signal("phase_changed", 3)
		_attack_cd = 0.1

func _physics_process(delta: float) -> void:
	if is_dead(): return
	if _state == FSM.GLIDE:
		velocity.y = lerpf(velocity.y, -35.0, 2.5 * delta)
	elif not is_on_floor():
		velocity.y += 920.0 * delta
	_tick(delta)
	move_and_slide()

func _tick(delta: float) -> void:
	_time += delta
	if _attack_cd > 0.0: _attack_cd -= delta
	if _stagger_t > 0.0: _stagger_t -= delta

	if _shadow_t > 0.0:
		_shadow_t -= delta
		if _shadow_t <= 0.0:
			_shadow_active = false
			sprite.modulate = _base_modulate

	if _hitflash > 0.0:
		_hitflash -= delta
		sprite.self_modulate = Color(3.0, 3.0, 3.0) if _hitflash > 0.0 else Color(1, 1, 1)

	if not _player or not is_instance_valid(_player): return
	var diff := _player.global_position - global_position
	var dist := diff.length()
	if dist > SIGHT: return

	match _state:
		FSM.IDLE:
			velocity.x = lerpf(velocity.x, 0.0, 5.0 * delta)
			if _attack_cd <= 0.0:
				_choose_attack(dist)

		FSM.GLIDE:
			_glide_t -= delta
			velocity.x = lerpf(velocity.x, _glide_dir * MOVE_SPEED * 2.0, 3.5 * delta)
			sprite.scale.x = abs(sprite.scale.x) * _glide_dir
			if abs(diff.x) < 65.0 or _glide_t <= 0.0:
				_state = FSM.SWIPE
				_attack_cd = 0.0

		FSM.SWIPE:
			velocity.x = lerpf(velocity.x, 0.0, 10.0 * delta)
			_do_swipe(diff)
			_state = FSM.IDLE
			_attack_cd = _get_cd()

		FSM.DRAIN:
			velocity.x = lerpf(velocity.x, 0.0, 8.0 * delta)
			_do_drain(diff.normalized())
			_state = FSM.IDLE
			_attack_cd = _get_cd()

		FSM.BAT_SWARM:
			velocity.x = lerpf(velocity.x, 0.0, 8.0 * delta)
			_do_bat_swarm()
			_state = FSM.IDLE
			_attack_cd = _get_cd()

		FSM.SHADOW:
			_shadow_active = true
			_shadow_t = 2.5
			sprite.modulate = Color(0.12, 0.0, 0.22, 0.35)
			AudioManager.play_sfx("mother_shadow")
			_state = FSM.IDLE
			_attack_cd = _get_cd()

		FSM.STAGGER:
			velocity.x = lerpf(velocity.x, 0.0, 9.0 * delta)
			if _stagger_t <= 0.0:
				_state = FSM.IDLE

	if _state == FSM.IDLE:
		var dir_x := sign(diff.x)
		if dir_x != 0.0:
			sprite.scale.x = abs(sprite.scale.x) * dir_x

func _choose_attack(dist: float) -> void:
	match _phase:
		Phase.ONE:
			if dist > 120.0 or randf() < 0.4:
				_state = FSM.GLIDE
				_glide_dir = int(sign(_player.global_position.x - global_position.x))
				_glide_t = 1.5
			else:
				_state = FSM.SWIPE
				_attack_cd = 0.0

		Phase.TWO:
			var r := randf()
			if r < 0.30:
				_state = FSM.DRAIN
			elif r < 0.55:
				_state = FSM.BAT_SWARM
			else:
				_state = FSM.GLIDE
				_glide_dir = int(sign(_player.global_position.x - global_position.x))
				_glide_t = 1.2

		Phase.THREE:
			var r := randf()
			if r < 0.22:
				_state = FSM.SHADOW
			elif r < 0.44:
				_state = FSM.BAT_SWARM
			elif r < 0.66:
				_state = FSM.DRAIN
			else:
				_state = FSM.GLIDE
				_glide_dir = int(sign(_player.global_position.x - global_position.x))
				_glide_t = 1.0

func _get_cd() -> float:
	match _phase:
		Phase.ONE:   return randf_range(2.0, 3.0)
		Phase.TWO:   return randf_range(1.2, 2.0)
		Phase.THREE: return randf_range(0.7, 1.4)
	return 2.0

func _do_swipe(diff: Vector2) -> void:
	var dir := int(sign(diff.x)) if diff.x != 0.0 else 1
	sprite.scale.x = abs(sprite.scale.x) * dir
	if diff.length() < 85.0:
		_player.take_damage(24, Vector2(dir * 220.0, -90.0))

func _do_drain(dir_n: Vector2) -> void:
	var dir := int(sign(dir_n.x)) if dir_n.x != 0.0 else 1
	sprite.scale.x = abs(sprite.scale.x) * dir
	AudioManager.play_sfx("mother_drain")
	emit_signal("drain_bullet", global_position + dir_n * 18.0, dir_n * 260.0, 20)

func _do_bat_swarm() -> void:
	AudioManager.play_sfx("mother_bats")
	var count := 5 if _phase == Phase.TWO else 8
	var base_dmg := 10 if _phase == Phase.TWO else 14
	for i in count:
		var angle := TAU / count * i
		var vel := Vector2(cos(angle), sin(angle)) * randf_range(160.0, 235.0)
		emit_signal("bat_bullet", global_position, vel, base_dmg)
