# DangerZone.gd — zone d'explosion télégraphiée (boss) : un cercle d'alerte se
# remplit, puis BOOM. Piloté par Main via tick() (se fige donc en pause/niveau).
# `oneshot` = Cataclysme : dégâts massifs qui ignorent l'armure (fuis ou protège-toi).
class_name VSDangerZone
extends Node2D

var radius := 85.0
var delay := 1.0
var dmg := 20.0
var oneshot := false
var t := 0.0

func setup(pos: Vector2, r: float, d: float, dm: float, one := false) -> void:
	position = pos
	radius = r
	delay = d
	dmg = dm
	oneshot = one

# Avance le minuteur ; renvoie true au moment de l'explosion.
func tick(delta: float) -> bool:
	t += delta
	queue_redraw()
	return t >= delay

func _draw() -> void:
	var frac := clampf(t / delay, 0.0, 1.0)
	if oneshot:
		# Cataclysme : anneau violet menaçant qui pulse, bord clignotant à la fin
		var edge := Color(0.85, 0.3, 1.0, 0.9)
		if frac > 0.7:
			edge = Color(1.0, 0.5, 1.0, 0.6 + 0.4 * absf(sin(t * 30.0)))
		draw_circle(Vector2.ZERO, radius, Color(0.5, 0.1, 0.7, 0.14))
		draw_circle(Vector2.ZERO, radius * frac, Color(0.7, 0.2, 0.95, 0.30))
		draw_arc(Vector2.ZERO, radius, 0.0, TAU, 56, edge, 5.0)
		draw_arc(Vector2.ZERO, radius - 6.0, 0.0, TAU, 56, Color(1.0, 0.7, 1.0, 0.5), 2.0)
	else:
		draw_circle(Vector2.ZERO, radius, Color(1.0, 0.20, 0.10, 0.10))
		draw_circle(Vector2.ZERO, radius * frac, Color(1.0, 0.30, 0.15, 0.28))
		draw_arc(Vector2.ZERO, radius, 0.0, TAU, 48, Color(1.0, 0.25, 0.20, 0.85), 3.0)
