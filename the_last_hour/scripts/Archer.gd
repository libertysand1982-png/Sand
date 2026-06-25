# Archer.gd — garde archer. Maintient sa distance et tire des flèches.
class_name TLHArcher
extends CharacterBody2D

const MOVE_SPEED   := 85.0
const PREF_DIST    := 260.0
const SIGHT        := 400.0
const SHOOT_CD     := 2.4
const SPRITE_SIZE  := 36.0
const HP_BASE      := 50
const ARROW_SPEED  := 310.0
const ARROW_DMG    := 13

enum FSM { IDLE, REPOSITION, SHOOT, STAGGER, DEAD }

var sprite: Sprite2D
var _state: FSM = FSM.IDLE
var hp: int
var _shoot_cd := 0.0
var _stagger_t := 0.0
var _hitflash := 0.0
var _player: Node2D

signal died(pos: Vector2, cells: int)
signal arrow_shot(from: Vector2, velocity_vec: Vector2, damage: int)

func setup(pos: Vector2, player: Node2D, hp_scale: float = 1.0) -> void:
	global_position = pos
	_player = player
	hp = int(HP_BASE * hp_scale)
	_shoot_cd = randf_range(0.6, SHOOT_CD)

	sprite = Sprite2D.new()
	sprite.texture = load("res://assets/characters/bandit.png")
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.scale = Vector2.ONE * (SPRITE_SIZE / 64.0)
	add_child(sprite)

	var col := CollisionShape2D.new()
	var s := CapsuleShape2D.new()
	s.radius = 11.0
	s.height = 26.0
	col.shape = s
	col.position = Vector2(0, -2)
	add_child(col)

func is_dead() -> bool:
	return _state == FSM.DEAD

func take_damage(amount: int, kb: Vector2 = Vector2.ZERO) -> void:
	if is_dead(): return
	hp -= amount
	_hitflash = 0.12
	velocity += kb
	if hp <= 0:
		_die()
	else:
		_state = FSM.STAGGER
		_stagger_t = 0.18

func _die() -> void:
	_state = FSM.DEAD
	emit_signal("died", global_position, 1)
	queue_free()

func _physics_process(delta: float) -> void:
	if is_dead(): return
	if not is_on_floor():
		velocity.y += 920.0 * delta
	_tick(delta)
	move_and_slide()

func _tick(delta: float) -> void:
	if _shoot_cd > 0.0: _shoot_cd -= delta
	if _hitflash > 0.0:
		_hitflash -= delta
		sprite.self_modulate = Color(3.0, 3.0, 3.0) if _hitflash > 0.0 else Color(1, 1, 1)

	if not _player or not is_instance_valid(_player):
		return
	var diff := _player.global_position - global_position
	var dist := diff.length()
	if dist > SIGHT: return

	match _state:
		FSM.IDLE, FSM.REPOSITION:
			var too_close := dist < PREF_DIST - 60.0
			var too_far   := dist > PREF_DIST + 60.0
			if too_close:
				velocity.x = lerpf(velocity.x, -sign(diff.x) * MOVE_SPEED, 8.0 * delta)
			elif too_far:
				velocity.x = lerpf(velocity.x, sign(diff.x) * MOVE_SPEED, 8.0 * delta)
			else:
				velocity.x = lerpf(velocity.x, 0.0, 8.0 * delta)
			sprite.scale.x = abs(sprite.scale.x) * int(sign(diff.x))
			if _shoot_cd <= 0.0:
				_state = FSM.SHOOT
		FSM.SHOOT:
			velocity.x = lerpf(velocity.x, 0.0, 10.0 * delta)
			_do_shoot()
			_shoot_cd = SHOOT_CD
			_state = FSM.IDLE
		FSM.STAGGER:
			velocity.x = lerpf(velocity.x, 0.0, 9.0 * delta)
			_stagger_t -= delta
			if _stagger_t <= 0.0:
				_state = FSM.IDLE

func _do_shoot() -> void:
	if not _player: return
	var dir := sign(_player.global_position.x - global_position.x)
	sprite.scale.x = abs(sprite.scale.x) * dir
	var vel_vec := Vector2(dir * ARROW_SPEED, -60.0)
	emit_signal("arrow_shot", global_position + Vector2(dir * 14.0, -6.0), vel_vec, ARROW_DMG)
