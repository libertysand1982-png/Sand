# Enemy.gd — un monstre animé (AnimatedSprite2D). Déplacé par Main.gd.
class_name VSEnemy
extends Node2D

var anim: AnimatedSprite2D
var type_key: String
var hp: float
var maxhp: float
var speed: float
var dmg: float
var xp: int
var radius: float
var disp_scale: float
var show_bar: bool = false
var hitflash: float = 0.0
var slow_timer: float = 0.0   # ralentissement (sort de Gel)
var is_boss: bool = false
var tier: int = 0             # palier du boss (1..9, 10 = final)
var boss_kind: String = ""    # "night" / "bringer" / "final"
var boss_title: String = ""   # nom affiché sur la barre de boss
var pat_a: float = 2.5        # recharge pattern A (anneaux / zones)
var pat_b: float = 4.0        # recharge pattern B (tirs visés / invocations)
var pat_c: float = 2.5        # recharge corps-à-corps (fauchage / bond)
var phase: int = 1            # phase du boss final (1..3)
var spin: float = 0.0         # angle courant des patterns en spirale
var is_elite: bool = false    # ennemi d'élite (doré, coriace, lâche un coffre)
var dead: bool = false
var dying: bool = false

var _frames: SpriteFrames

func setup(tkey: String, pos: Vector2, hp_scale: float, frames: SpriteFrames, def: Dictionary) -> void:
	type_key = tkey
	position = pos
	maxhp = round(def["hp"] * hp_scale)
	hp = maxhp
	speed = def["speed"]
	dmg = def["dmg"]
	xp = def["xp"]
	radius = def["radius"]
	disp_scale = def["scale"]
	show_bar = def["bar"]
	_frames = frames

func _ready() -> void:
	anim = AnimatedSprite2D.new()
	anim.sprite_frames = _frames
	anim.scale = Vector2(disp_scale, disp_scale)
	add_child(anim)
	anim.play("move")
	var n := anim.sprite_frames.get_frame_count("move")
	if n > 1:
		anim.frame = randi() % n   # désynchronise les animations

# Joue la mort puis se libère (appelé par Main quand hp <= 0).
func die() -> void:
	if dying:
		return
	dying = true
	anim.play("death")
	await anim.animation_finished
	queue_free()

func _draw() -> void:
	# ombre
	draw_set_transform(Vector2(0, radius * 1.25), 0.0, Vector2(1, 0.4))
	draw_circle(Vector2.ZERO, radius * 0.85, Color(0, 0, 0, 0.25))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	# aura dorée des élites
	if is_elite:
		draw_circle(Vector2.ZERO, radius * 1.35, Color(1.0, 0.82, 0.25, 0.16))
		draw_arc(Vector2.ZERO, radius * 1.35, 0.0, TAU, 40, Color(1.0, 0.85, 0.35, 0.7), 2.5)
	# barre de vie (monstres costauds blessés)
	if show_bar and hp < maxhp and hp > 0.0:
		var w := 48.0
		var x := -w / 2.0
		var y := -radius * 2.1
		draw_rect(Rect2(x - 1.0, y - 1.0, w + 2.0, 8.0), Color(0, 0, 0, 0.6))
		draw_rect(Rect2(x, y, w, 6.0), Color(0.10, 0.05, 0.05))
		draw_rect(Rect2(x, y, w * clampf(hp / maxhp, 0.0, 1.0), 6.0), Color(0.85, 0.26, 0.31))
