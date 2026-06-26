# Projectile.gd — boule de feu lancée par l'arme automatique (sprite orienté + halo).
class_name VSProjectile
extends Node2D

var vel: Vector2
var dmg: float
var hits_left: int
var size: float
var life: float = 2.2
var hitset: Dictionary = {}   # sert de "set" : ennemis déjà touchés
var dead: bool = false

func setup(pos: Vector2, dir: Vector2, spd: float, d: float, p: int, sz: float) -> void:
	position = pos
	vel = dir * spd
	rotation = dir.angle()
	dmg = d
	hits_left = p + 1
	size = sz

func _ready() -> void:
	var s := Sprite2D.new()
	s.texture = load("res://assets/fx/fireball.png")
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var sc := (size * 2.4) / 18.0   # l'orbe fait 18px ; échelle selon la taille
	s.scale = Vector2(sc, sc)
	add_child(s)

func _draw() -> void:
	# halo lumineux chaud sous le sprite
	draw_circle(Vector2.ZERO, size + 4.0, Color(1.0, 0.6, 0.2, 0.22))
