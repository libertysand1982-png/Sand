# Player.gd — le héros. Sprite + caméra. La logique de jeu est pilotée par Main.gd.
class_name VSPlayer
extends Node2D

const SIZE := 46.0

var sprite: Sprite2D
var cam: Camera2D
var base_scale: Vector2

# Stats
var radius := 15.0
var speed := 205.0
var maxhp := 100.0
var hp := 100.0
var level := 1
var xp := 0
var xp_to_next := 5
var facing := 1
var invuln := 0.0
var pickup := 80.0
var bob := 0.0
var step_timer := 0.0

# Arme (frappe automatique)
var fire_cd := 0.0
var fire_interval := 0.85
var proj_damage := 24.0
var proj_speed := 430.0
var proj_count := 1
var pierce := 0
var proj_size := 11.0

func _ready() -> void:
	base_scale = Vector2(SIZE / 64.0, SIZE / 64.0)
	sprite = Sprite2D.new()
	sprite.texture = load("res://assets/characters/hero.png")
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.scale = base_scale
	add_child(sprite)

	cam = Camera2D.new()
	cam.position_smoothing_enabled = true
	cam.position_smoothing_speed = 9.0
	add_child(cam)
	cam.make_current()

func reset(pos: Vector2) -> void:
	position = pos
	radius = 15.0
	speed = 205.0
	maxhp = 100.0
	hp = 100.0
	level = 1
	xp = 0
	xp_to_next = 5
	facing = 1
	invuln = 0.0
	pickup = 80.0
	bob = 0.0
	step_timer = 0.0
	fire_cd = 0.0
	fire_interval = 0.85
	proj_damage = 24.0
	proj_speed = 430.0
	proj_count = 1
	pierce = 0
	proj_size = 11.0
	sprite.scale = base_scale
	sprite.position = Vector2.ZERO
	sprite.modulate = Color(1, 1, 1, 1)

func xp_pct() -> float:
	return float(xp) / float(xp_to_next)

func hp_pct() -> float:
	return hp / maxhp
