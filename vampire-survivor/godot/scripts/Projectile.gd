# Projectile.gd — un éclat lancé par l'arme. Dessiné via _draw, déplacé par Main.gd.
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

func _draw() -> void:
	# halo
	draw_circle(Vector2.ZERO, size + 5.0, Color(0.47, 0.90, 1.0, 0.22))
	# éclat (le nœud est déjà orienté par rotation)
	draw_rect(Rect2(-size, -2.5, size * 2.0, 5.0), Color(0.87, 0.97, 1.0))
	draw_rect(Rect2(size - 3.0, -1.5, 5.0, 3.0), Color(0.56, 0.90, 1.0))
