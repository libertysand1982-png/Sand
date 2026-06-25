# Arrow.gd — projectile ennemi (flèche ou balle de boss).
class_name TLHArrow
extends Node2D

var vel: Vector2
var dmg: int
var life := 3.5
var _rect: ColorRect

func setup(from: Vector2, velocity_vec: Vector2, damage: int) -> void:
	global_position = from
	vel = velocity_vec
	dmg = damage

	_rect = ColorRect.new()
	_rect.size = Vector2(14, 4)
	_rect.color = Color(0.85, 0.65, 0.25)
	_rect.position = Vector2(-7, -2)
	add_child(_rect)

func _process(delta: float) -> void:
	vel.y += 110.0 * delta
	global_position += vel * delta
	rotation = vel.angle()
	life -= delta
	if life <= 0.0:
		queue_free()
