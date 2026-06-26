# Gem.gd — gemme d'expérience lâchée par les monstres. Aimantée par Main.gd.
class_name VSGem
extends Node2D

var value: int = 1
var dead: bool = false

func setup(pos: Vector2, v: int) -> void:
	position = pos
	value = v

func _draw() -> void:
	draw_circle(Vector2.ZERO, 9.0, Color(0.35, 0.78, 1.0, 0.25))
	var pts := PackedVector2Array([
		Vector2(0, -5), Vector2(5, 0), Vector2(0, 5), Vector2(-5, 0)
	])
	draw_colored_polygon(pts, Color(0.33, 0.78, 1.0))
	draw_colored_polygon(PackedVector2Array([
		Vector2(0, -5), Vector2(2.5, -1), Vector2(-1, 0), Vector2(-2.5, -2)
	]), Color(0.75, 0.94, 1.0))
