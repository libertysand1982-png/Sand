# Jailer.gd — Le Geôlier, boss final. 3 phases, 3 attaques.
class_name TLHJailer
extends CharacterBody2D

const HP_MAX      := 900
const BASE_DMG    := 28
const SPRITE_SIZE := 72.0
# Samurai spritesheet: 96×96 px per frame (boss uses larger scale)
const SAM_FRAME_H := 96
const SAM_ANIMS := {
	"idle":   [10, 8.0,  true],
	"run":    [16, 12.0, true],
	"attack": [7,  14.0, false],
	"hurt":   [4,  10.0, false],
}

enum Phase { ONE, TWO, THREE }
enum FSM   { IDLE, CHARGE, SLAM, BURST, STAGGER, DEAD }

var sprite: AnimatedSprite2D
var hp := HP_MAX
var phase: Phase = Phase.ONE
var _state: FSM = FSM.IDLE
var _state_t := 0.0
var _attack_cd := 0.0
var _hitflash := 0.0
var _player: Node2D
var _charge_dir := 1
var _charge_speed := 0.0

signal died()
signal hp_changed(current: int, maximum: int)
signal phase_changed(n: int)
signal burst_bullet(from: Vector2, velocity_vec: Vector2, damage: int)

func setup(pos: Vector2, player: Node2D) -> void:
	global_position = pos
	_player = player

	sprite = AnimatedSprite2D.new()
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var sc: float = SPRITE_SIZE / float(SAM_FRAME_H)
	sprite.scale = Vector2(sc, sc)
	sprite.sprite_frames = _make_jailer_frames()
	sprite.modulate = Color(1.1, 0.35, 0.35)
	sprite.play("idle")
	add_child(sprite)

	var col := CollisionShape2D.new()
	var s := CapsuleShape2D.new()
	s.radius = 22.0
	s.height = 52.0
	col.shape = s
	col.position = Vector2(0, -4)
	add_child(col)

	_attack_cd = 1.5

func is_dead() -> bool:
	return _state == FSM.DEAD

func _make_jailer_frames() -> SpriteFrames:
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

func _update_anim(dir: int) -> void:
	var anim: String
	match _state:
		FSM.CHARGE:  anim = "run"
		FSM.SLAM, FSM.BURST: anim = "attack"
		FSM.STAGGER: anim = "hurt"
		_:           anim = "idle"
	if sprite.animation != anim:
		sprite.play(anim)
	if dir != 0:
		sprite.flip_h = dir < 0

func take_damage(amount: int, kb: Vector2 = Vector2.ZERO) -> void:
	if is_dead(): return
	hp -= amount
	_hitflash = 0.12
	velocity += kb * 0.3
	emit_signal("hp_changed", hp, HP_MAX)
	_check_phase_change()
	if hp <= 0:
		_die()
	else:
		AudioManager.play_sfx("enemy_hurt", -5.0)
		_state = FSM.STAGGER
		_state_t = 0.16

func _check_phase_change() -> void:
	if phase == Phase.ONE and hp <= HP_MAX * 2 / 3.0:
		phase = Phase.TWO
		sprite.modulate = Color(1.3, 0.25, 0.25)
		AudioManager.play_sfx("boss_roar")
		emit_signal("phase_changed", 2)
	elif phase == Phase.TWO and hp <= HP_MAX / 3.0:
		phase = Phase.THREE
		sprite.modulate = Color(1.6, 0.15, 0.15)
		AudioManager.play_sfx("boss_roar")
		emit_signal("phase_changed", 3)

func _die() -> void:
	_state = FSM.DEAD
	emit_signal("died")
	queue_free()

func _physics_process(delta: float) -> void:
	if is_dead(): return
	if not is_on_floor():
		velocity.y += 980.0 * delta

	if _hitflash > 0.0:
		_hitflash -= delta
		sprite.self_modulate = Color(4.0, 4.0, 4.0) if _hitflash > 0.0 else Color(1, 1, 1)

	_tick(delta)
	var dir: int = 0
	if _player and is_instance_valid(_player):
		dir = int(sign(_player.global_position.x - global_position.x))
	_update_anim(dir)
	move_and_slide()

func _tick(delta: float) -> void:
	if _attack_cd > 0.0: _attack_cd -= delta
	if _state_t > 0.0:   _state_t   -= delta

	match _state:
		FSM.IDLE:
			velocity.x = lerpf(velocity.x, 0.0, 4.0 * delta)
			if _attack_cd <= 0.0 and _player and is_instance_valid(_player):
				_choose_attack()

		FSM.CHARGE:
			velocity.x = _charge_dir * _charge_speed
			_state_t -= delta
			if is_on_wall() or _state_t <= 0.0:
				velocity.x = 0.0
				_state = FSM.IDLE
				_attack_cd = _get_cd()
			if _player and is_instance_valid(_player):
				if global_position.distance_to(_player.global_position) < 55.0:
					var kb_dir := sign(_player.global_position.x - global_position.x)
					_player.take_damage(BASE_DMG, Vector2(kb_dir * 320.0, -130.0))

		FSM.SLAM:
			velocity.x = lerpf(velocity.x, 0.0, 6.0 * delta)
			_state_t -= delta
			if _state_t <= 0.0:
				AudioManager.play_sfx("boss_slam")
				if _player and is_instance_valid(_player):
					var dist := global_position.distance_to(_player.global_position)
					if dist < 200.0:
						var kb_dir := sign(_player.global_position.x - global_position.x)
						_player.take_damage(int(BASE_DMG * 1.5), Vector2(kb_dir * 280.0, -180.0))
				_state = FSM.IDLE
				_attack_cd = _get_cd()

		FSM.BURST:
			velocity.x = lerpf(velocity.x, 0.0, 6.0 * delta)
			_state_t -= delta
			if _state_t <= 0.0:
				_fire_burst()
				_state = FSM.IDLE
				_attack_cd = _get_cd()

		FSM.STAGGER:
			velocity.x = lerpf(velocity.x, 0.0, 12.0 * delta)
			if _state_t <= 0.0:
				_state = FSM.IDLE

func _choose_attack() -> void:
	var r := randf()
	match phase:
		Phase.ONE:
			if r < 0.65: _start_charge()
			else:         _start_slam()
		Phase.TWO:
			if r < 0.4:   _start_charge()
			elif r < 0.7: _start_slam()
			else:          _start_burst()
		Phase.THREE:
			if r < 0.25:  _start_charge()
			elif r < 0.55: _start_slam()
			else:           _start_burst()

func _start_charge() -> void:
	if not _player or not is_instance_valid(_player): return
	_state = FSM.CHARGE
	AudioManager.play_sfx("boss_charge")
	_charge_dir = int(sign(_player.global_position.x - global_position.x))
	_charge_speed = 360.0 if phase == Phase.ONE else 500.0
	_state_t = 0.9
	sprite.flip_h = _charge_dir < 0

func _start_slam() -> void:
	_state = FSM.SLAM
	_state_t = 0.65

func _start_burst() -> void:
	_state = FSM.BURST
	_state_t = 0.55

func _fire_burst() -> void:
	AudioManager.play_sfx("boss_burst")
	var count := 6 if phase == Phase.TWO else 10
	for i in count:
		var angle := (TAU / count) * i
		var dir := Vector2.from_angle(angle)
		emit_signal("burst_bullet", global_position, dir * 240.0, 11)

func _get_cd() -> float:
	match phase:
		Phase.ONE:   return randf_range(1.6, 2.4)
		Phase.TWO:   return randf_range(1.1, 1.7)
		Phase.THREE: return randf_range(0.6, 1.1)
	return 2.0
