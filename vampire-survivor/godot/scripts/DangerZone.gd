# DangerZone.gd — zone d'explosion télégraphiée (boss Porteur de Mort) :
# un cercle d'alerte se remplit, puis BOOM. Piloté par Main via tick()
# (ainsi la zone se fige pendant la pause et le choix d'amélioration).
class_name VSDangerZone
extends Node2D

var radius := 85.0
var delay := 1.0
var dmg := 20.0
var t := 0.0

func setup(pos: Vector2, r: float, d: float, dm: float) -> void:
	position = pos
	radius = r
	delay = d
	dmg = dm

# Avance le minuteur ; renvoie true au moment de l'explosion.
func tick(delta: float) -> bool:
	t += delta
	queue_redraw()
	return t >= delay

func _draw() -> void:
	var frac := clampf(t / delay, 0.0, 1.0)
	draw_circle(Vector2.ZERO, radius, Color(1.0, 0.20, 0.10, 0.10))
	draw_circle(Vector2.ZERO, radius * frac, Color(1.0, 0.30, 0.15, 0.28))
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 48, Color(1.0, 0.25, 0.20, 0.85), 3.0)
