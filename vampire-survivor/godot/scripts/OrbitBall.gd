# OrbitBall.gd — boule de feu qui tourne autour du Mage (arme automatique).
# Positionnée par Main (_update_orbit) ; dessine un halo chaud sous le sprite.
class_name VSOrbitBall
extends Node2D

var size := 13.0
var _s: Sprite2D

func _ready() -> void:
	_s = Sprite2D.new()
	_s.texture = load("res://assets/fx/fireball.png")
	_s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var sc := (size * 2.6) / 18.0   # l'orbe fait 18px
	_s.scale = Vector2(sc, sc)
	add_child(_s)
	z_index = 8

func _process(delta: float) -> void:
	# scintillement de la flamme
	_s.rotation += delta * 7.0
	var pulse := 1.0 + 0.12 * sin(float(Time.get_ticks_msec()) * 0.012)
	var base := (size * 2.6) / 18.0
	_s.scale = Vector2(base * pulse, base * pulse)
	queue_redraw()

func _draw() -> void:
	draw_circle(Vector2.ZERO, size + 6.0, Color(1.0, 0.55, 0.15, 0.22))
	draw_circle(Vector2.ZERO, size + 2.0, Color(1.0, 0.75, 0.3, 0.18))
