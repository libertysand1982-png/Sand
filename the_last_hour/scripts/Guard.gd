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
# Samurai spritesheet: 96×96 px per frame
const SAM_FRAME_H   := 96
const SAM_ANIMS := {
	"idle":   [10, 8.0,  true],
	"run":    [16, 12.0, true],
	"attack": [7,  12.0, false],
	"hurt":   [4,  10.0, false],
}

enum FSM { PATROL, CHASE, ATTACK, STAGGER, DEAD }

var sprite: AnimatedSprite2D
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

	sprite = AnimatedSprite2D.new()
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var sc: float = SPRITE_SIZE / float(SAM_FRAME_H)
	sprite.scale = Vector2(sc, sc)
	sprite.sprite_frames = _make_samurai_frames()
	sprite.play("idle")
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

func _make_samurai_frames() -> SpriteFrames:
	var sf := SpriteFrames.new()
	sf.remove_animation("default")
	var anim_files := {
		"idle":   "res://assets/characters/samurai/idle.png",
		"run":    "res://assets/characters/samurai/run.png",
		"attack": "res://assets/characters/samurai/attack.png",
		"hurt":   "res://assets/characters/samurai/hurt.png",
	}
	for raw_name in SAM_ANIMS:
		var anim_name: String = str(raw_name)
		var def: Array = SAM_ANIMS[anim_name]
		var frame_count: int = int(def[0])
		var fps: float = float(def[1])
		var loop: bool = bool(def[2])
		sf.add_animation(anim_name)
		sf.set_animation_speed(anim_name, fps)
		sf.set_animation_loop(anim_name, loop)
		var tex: Texture2D = load(str(anim_files[anim_name]))
		var fw: int = tex.get_width() / frame_count
		for i in frame_count:
			var atlas := AtlasTexture.new()
			atlas.atlas = tex
			atlas.region = Rect2(i * fw, 0, fw, SAM_FRAME_H)
			sf.add_frame(anim_name, atlas)
	return sf

func _update_anim() -> void:
	var anim: String
	match _state:
		FSM.ATTACK:  anim = "attack"
		FSM.STAGGER: anim = "hurt"
		_:           anim = "run" if abs(velocity.x) > 10.0 else "idle"
	if sprite.animation != anim:
		sprite.play(anim)

func take_damage(amount: int, kb: Vector2 = Vector2.ZERO) -> void:
	if is_dead():
		return
	hp -= amount
	_hitflash = 0.14
	velocity += kb
	if hp <= 0:
		_die()
	else:
		AudioManager.play_sfx("enemy_hurt")
		_state = FSM.STAGGER
		_stagger_t = 0.22

func _die() -> void:
	_state = FSM.DEAD
	AudioManager.play_sfx("enemy_death")
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
	_update_anim()

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
	sprite.flip_h = _patrol_dir < 0

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
	sprite.flip_h = dir < 0

func _do_attack(delta: float) -> void:
	velocity.x = lerpf(velocity.x, 0.0, 12.0 * delta)
	if _player and is_instance_valid(_player):
		var dist := global_position.distance_to(_player.global_position)
		if dist < ATTACK_RANGE + 14.0:
			var dir: float = sign(_player.global_position.x - global_position.x)
			_player.take_damage(DMG, Vector2(dir * 210.0, -90.0))
	_attack_cd = ATTACK_CD
	_state = FSM.CHASE
