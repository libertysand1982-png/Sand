# Nova.gd — anneau lumineux qui s'étend (sort de niveau + bursts des sorts actifs).
# Couleurs paramétrables ; s'anime seul même pendant une pause de jeu.
class_name VSNova
extends Node2D

var t := 0.0
var dur := 0.55
var max_r := 220.0
var ring_color := Color(0.85, 0.95, 1.0)
var glow_color := Color(0.55, 0.80, 1.0)

func _process(delta: float) -> void:
	t += delta
	queue_redraw()
	if t >= dur:
		queue_free()

func _draw() -> void:
	var k := clampf(t / dur, 0.0, 1.0)
	var r := max_r * (1.0 - pow(1.0 - k, 3.0))
	var a := 1.0 - k
	draw_circle(Vector2.ZERO, r * 0.5, Color(glow_color.r, glow_color.g, glow_color.b, a * 0.12))
	draw_arc(Vector2.ZERO, r, 0.0, TAU, 72, Color(glow_color.r, glow_color.g, glow_color.b, a * 0.5), 10.0, true)
	draw_arc(Vector2.ZERO, r, 0.0, TAU, 72, Color(ring_color.r, ring_color.g, ring_color.b, a * 0.9), 4.0, true)
