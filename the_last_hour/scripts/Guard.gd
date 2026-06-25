# Guard.gd — garde corps-à-corps. Patrouille, charge, frappe.
class_name TLHGuard
extends CharacterBody2D

const PATROL_SPEED  := 65.0
const CHASE_SPEED   := 150.0
const SIGHT_RANGE   := 340.0
const ATTACK_RANGE  := 46.0
const ATTACK_CD     := 1.3
const DMG           := 14
const SPRITE_SIZE   := 40.0
const HP_BASE       := 70

enum FSM { PATROL, CHASE, ATTACK, STAGGER, DEAD }

var sprite: Sprite2D
var _state: FSM = FSM.PATROL
var hp: int
var _patrol_dir := 1
var _patrol_t := 0.0
var _attack_cd := 0.0
var _stagger_t := 0.0
var _hitflash := 0.0
var _player: Node2D

signal died(pos: Vector2, cells: int)

func setup(pos: Vector2, player: Node2D, hp_scale: float = 1.0) -> void:
	global_position = pos
	_player = player
	hp = int(HP_BASE * hp_scale)
	_patrol_t = randf_range(0.8, 2.0)

	sprite = Sprite2D.new()
	sprite.texture = load("res://assets/characters/garde.png")
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.scale = Vector2.ONE * (SPRITE_SIZE / 64.0)
	add_child(sprite)

	var col := CollisionShape2D.new()
	var s := CapsuleShape2D.new()
	s.radius = 12.0
	s.height = 28.0
	col.shape = s
	col.position = Vector2(0, -2)
	add_child(col)

func is_dead() -> bool:
	return _state == FSM.DEAD

func take_damage(amount: int, kb: Vector2 = Vector2.ZERO) -> void:
	if is_dead():
		return
	hp -= amount
	_hitflash = 0.14
	velocity += kb
	if hp <= 0:
		_die()
	else:
		_state = FSM.STAGGER
		_stagger_t = 0.22

func _die() -> void:
	_state = FSM.DEAD
	emit_signal("died", global_position, 1)
	queue_free()

func _physics_process(delta: float) -> void:
	if is_dead():
		return
	if not is_on_floor():
		velocity.y += 920.0 * delta
	_tick(delta)
	move_and_slide()

func _tick(delta: float) -> void:
	if _attack_cd > 0.0: _attack_cd -= delta
	if _hitflash > 0.0:
		_hitflash -= delta
		sprite.self_modulate = Color(3.0, 3.0, 3.0) if _hitflash > 0.0 else Color(1, 1, 1)

	match _state:
		FSM.PATROL:  _do_patrol(delta)
		FSM.CHASE:   _do_chase(delta)
		FSM.ATTACK:  _do_attack(delta)
		FSM.STAGGER:
			velocity.x = lerpf(velocity.x, 0.0, 9.0 * delta)
			_stagger_t -= delta
			if _stagger_t <= 0.0:
				_state = FSM.CHASE

func _do_patrol(delta: float) -> void:
	if _player and is_instance_valid(_player):
		if global_position.distance_to(_player.global_position) < SIGHT_RANGE:
			_state = FSM.CHASE
			return
	_patrol_t -= delta
	if _patrol_t <= 0.0:
		_patrol_dir = -_patrol_dir
		_patrol_t = randf_range(1.2, 2.8)
	velocity.x = _patrol_dir * PATROL_SPEED
	sprite.scale.x = abs(sprite.scale.x) * _patrol_dir

func _do_chase(delta: float) -> void:
	if not _player or not is_instance_valid(_player):
		_state = FSM.PATROL
		return
	var diff := _player.global_position - global_position
	var dist := diff.length()
	if dist > SIGHT_RANGE * 1.6:
		_state = FSM.PATROL
		return
	if dist < ATTACK_RANGE and _attack_cd <= 0.0:
		_state = FSM.ATTACK
		return
	var dir := int(sign(diff.x))
	velocity.x = dir * CHASE_SPEED
	sprite.scale.x = abs(sprite.scale.x) * dir

func _do_attack(delta: float) -> void:
	velocity.x = lerpf(velocity.x, 0.0, 12.0 * delta)
	if _player and is_instance_valid(_player):
		var dist := global_position.distance_to(_player.global_position)
		if dist < ATTACK_RANGE + 14.0:
			var dir := sign(_player.global_position.x - global_position.x)
			_player.take_damage(DMG, Vector2(dir * 210.0, -90.0))
	_attack_cd = ATTACK_CD
	_state = FSM.CHASE
