# EnemyShot.gd — projectile de boss : orbe sombre que le joueur doit esquiver.
class_name VSEnemyShot
extends Node2D

var vel: Vector2
var dmg: float
var radius := 9.0
var life := 5.0

func setup(pos: Vector2, dir: Vector2, spd: float, d: float, r: float = 9.0) -> void:
	position = pos
	vel = dir * spd
	dmg = d
	radius = r

func _draw() -> void:
	draw_circle(Vector2.ZERO, radius + 5.0, Color(0.60, 0.20, 0.90, 0.22))
	draw_circle(Vector2.ZERO, radius, Color(0.45, 0.12, 0.65))
	draw_circle(Vector2.ZERO, radius * 0.55, Color(0.95, 0.60, 1.00))
