# Nova.gd — effet visuel du sort « Onde arcanique » lancé à chaque montée de niveau.
# Anneau lumineux qui s'étend et s'estompe ; s'anime seul (même pendant la pause de choix).
class_name VSNova
extends Node2D

var t := 0.0
var dur := 0.55
var max_r := 220.0

func _process(delta: float) -> void:
	t += delta
	queue_redraw()
	if t >= dur:
		queue_free()

func _draw() -> void:
	var k := clampf(t / dur, 0.0, 1.0)
	var r := max_r * (1.0 - pow(1.0 - k, 3.0))   # s'étend vite puis ralentit
	var a := 1.0 - k
	# halo central
	draw_circle(Vector2.ZERO, r * 0.5, Color(0.55, 0.80, 1.0, a * 0.12))
	# anneau (épais translucide + cœur clair)
	draw_arc(Vector2.ZERO, r, 0.0, TAU, 72, Color(0.40, 0.70, 1.0, a * 0.5), 10.0, true)
	draw_arc(Vector2.ZERO, r, 0.0, TAU, 72, Color(0.85, 0.95, 1.0, a * 0.9), 4.0, true)
