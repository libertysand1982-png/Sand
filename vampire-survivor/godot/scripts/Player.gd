# Player.gd — le héros (HeroKnight animé) : AnimatedSprite2D + caméra.
# La logique est pilotée par Main.gd.
class_name VSPlayer
extends Node2D

var anim: AnimatedSprite2D
var cam: Camera2D
var disp_scale := 1.45
var dying := false

# Stats
var radius := 16.0
var speed := 205.0
var maxhp := 100.0
var hp := 100.0
var level := 1
var xp := 0
var xp_to_next := 5
var facing := 1
var invuln := 0.0
var pickup := 80.0
var step_timer := 0.0

# Arme (frappe automatique)
var fire_cd := 0.0
var fire_interval := 0.85
var proj_damage := 24.0
var proj_speed := 430.0
var proj_count := 1
var pierce := 0
var proj_size := 12.0

# Sort de montée de niveau (onde arcanique)
var nova_radius_mul := 1.0
var nova_dmg_mul := 1.0

func _ready() -> void:
	anim = AnimatedSprite2D.new()
	anim.scale = Vector2(disp_scale, disp_scale)
	anim.offset = Vector2(0, -6)
	add_child(anim)

	cam = Camera2D.new()
	cam.position_smoothing_enabled = true
	cam.position_smoothing_speed = 9.0
	add_child(cam)
	cam.make_current()

func set_frames(sf: SpriteFrames) -> void:
	anim.sprite_frames = sf
	anim.play("idle")

func reset(pos: Vector2) -> void:
	position = pos
	dying = false
	radius = 16.0
	speed = 205.0
	maxhp = 100.0
	hp = 100.0
	level = 1
	xp = 0
	xp_to_next = 5
	facing = 1
	invuln = 0.0
	pickup = 80.0
	step_timer = 0.0
	fire_cd = 0.0
	fire_interval = 0.85
	proj_damage = 24.0
	proj_speed = 430.0
	proj_count = 1
	pierce = 0
	proj_size = 12.0
	nova_radius_mul = 1.0
	nova_dmg_mul = 1.0
	anim.scale = Vector2(disp_scale, disp_scale)
	anim.modulate = Color(1, 1, 1, 1)
	anim.flip_h = false
	if anim.sprite_frames:
		anim.play("idle")

func xp_pct() -> float:
	return float(xp) / float(xp_to_next)

func hp_pct() -> float:
	return hp / maxhp

func _draw() -> void:
	# ombre portée (ellipse aplatie sous les pieds)
	draw_set_transform(Vector2(0, 30), 0.0, Vector2(1, 0.4))
	draw_circle(Vector2.ZERO, 17, Color(0, 0, 0, 0.28))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
