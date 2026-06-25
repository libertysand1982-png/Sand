# Bolt.gd — éclairs en dents de scie reliant le héros à ses cibles (sort Éclair).
class_name VSBolt
extends Node2D

var paths: Array = []   # liste de PackedVector2Array (relatifs à la position)
var t := 0.0
var dur := 0.22

func setup(from: Vector2, tos: Array) -> void:
	position = from
	for p in tos:
		paths.append(_make_path(Vector2.ZERO, p - from))

func _make_path(a0: Vector2, b0: Vector2) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var n := 9
	var perp := (b0 - a0).orthogonal().normalized()
	for i in n + 1:
		var f := float(i) / n
		var base := a0.lerp(b0, f)
		var off := 0.0
		if i > 0 and i < n:
			off = randf_range(-10.0, 10.0)
		pts.append(base + perp * off)
	return pts

func _process(delta: float) -> void:
	t += delta
	queue_redraw()
	if t >= dur:
		queue_free()

func _draw() -> void:
	var a := 1.0 - clampf(t / dur, 0.0, 1.0)
	for p in paths:
		draw_polyline(p, Color(0.55, 0.78, 1.0, a), 4.0, true)
		draw_polyline(p, Color(1.0, 1.0, 1.0, a * 0.9), 1.6, true)
