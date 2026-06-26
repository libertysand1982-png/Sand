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
# Kobold spritesheet: 96×96 px per frame
const KOB_FRAME_H  := 96
const KOB_ANIMS := {
	"idle":   [9,  8.0,  true],
	"run":    [12, 10.0, true],
	"attack": [7,  12.0, false],
}

enum FSM { IDLE, REPOSITION, SHOOT, STAGGER, DEAD }

var sprite: AnimatedSprite2D
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

	sprite = AnimatedSprite2D.new()
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var sc: float = SPRITE_SIZE / float(KOB_FRAME_H)
	sprite.scale = Vector2(sc, sc)
	sprite.sprite_frames = _make_kobold_frames()
	sprite.play("idle")
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

func _make_kobold_frames() -> SpriteFrames:
	var sf := SpriteFrames.new()
	sf.remove_animation("default")
	var anim_files := {
		"idle":   "res://assets/characters/kobold/idle.png",
		"run":    "res://assets/characters/kobold/run.png",
		"attack": "res://assets/characters/kobold/attack.png",
	}
	for anim_name in KOB_ANIMS:
		var def: Array = KOB_ANIMS[anim_name]
		var frame_count: int = def[0]
		var fps: float = def[1]
		var loop: bool = def[2]
		sf.add_animation(anim_name)
		sf.set_animation_speed(anim_name, fps)
		sf.set_animation_loop(anim_name, loop)
		var tex: Texture2D = load(anim_files[anim_name])
		var fw: int = tex.get_width() / frame_count
		for i in frame_count:
			var atlas := AtlasTexture.new()
			atlas.atlas = tex
			atlas.region = Rect2(i * fw, 0, fw, KOB_FRAME_H)
			sf.add_frame(anim_name, atlas)
	return sf

func _update_anim(diff_x: float) -> void:
	var anim: String
	match _state:
		FSM.SHOOT:   anim = "attack"
		FSM.STAGGER: anim = "attack"
		_:           anim = "run" if abs(velocity.x) > 10.0 else "idle"
	if sprite.animation != anim:
		sprite.play(anim)
	if diff_x != 0.0:
		sprite.flip_h = diff_x < 0.0

func take_damage(amount: int, kb: Vector2 = Vector2.ZERO) -> void:
	if is_dead(): return
	hp -= amount
	_hitflash = 0.12
	velocity += kb
	if hp <= 0:
		_die()
	else:
		AudioManager.play_sfx("enemy_hurt")
		_state = FSM.STAGGER
		_stagger_t = 0.18

func _die() -> void:
	_state = FSM.DEAD
	AudioManager.play_sfx("enemy_death")
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
		_update_anim(0.0)
		return
	var diff := _player.global_position - global_position
	var dist := diff.length()
	if dist > SIGHT:
		_update_anim(0.0)
		return

	_update_anim(diff.x)

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
	sprite.flip_h = dir < 0.0
	AudioManager.play_sfx("arrow_shot", -3.0)
	var vel_vec := Vector2(dir * ARROW_SPEED, -60.0)
	emit_signal("arrow_shot", global_position + Vector2(dir * 14.0, -6.0), vel_vec, ARROW_DMG)
