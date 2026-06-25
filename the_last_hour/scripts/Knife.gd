# Knife.gd — couteau lancé par le joueur, peut traverser 1 ennemi.
class_name TLHKnife
extends Node2D

var vel: Vector2
var dmg: int
var life := 2.2
var _enemies: Array
var _rect: ColorRect
var _hit_set: Array = []
const MAX_PIERCE := 1

func setup(from: Vector2, direction: int, speed: float, damage: int, enemies: Array) -> void:
	global_position = from
	vel = Vector2(direction * speed, 0.0)
	dmg = damage
	_enemies = enemies

	_rect = ColorRect.new()
	_rect.size = Vector2(16, 3)
	_rect.color = Color(0.88, 0.88, 0.95)
	_rect.position = Vector2(-8, -1.5)
	if direction < 0:
		_rect.position.x = -8
	add_child(_rect)
	rotation = atan2(vel.y, vel.x)

func _process(delta: float) -> void:
	global_position += vel * delta
	life -= delta
	if life <= 0.0:
		queue_free()
		return
	var pierce_count := 0
	for e in _enemies:
		if not is_instance_valid(e) or e.is_dead():
			continue
		if _hit_set.has(e):
			continue
		if global_position.distance_to(e.global_position) < 26.0:
			e.take_damage(dmg, vel.normalized() * 90.0)
			_hit_set.append(e)
			pierce_count += 1
			if pierce_count > MAX_PIERCE:
				queue_free()
				return
