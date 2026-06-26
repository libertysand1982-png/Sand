# Item.gd — objet lâché par un boss (arme / armure / potion). Ramassé au contact.
class_name VSItem
extends Node2D

var kind: String = "potion"
var dead: bool = false
var _tex: Texture2D
var _bob: float = 0.0
var _sprite: Sprite2D

func setup(pos: Vector2, k: String, tex: Texture2D) -> void:
	position = pos
	kind = k
	_tex = tex
	_bob = randf() * TAU

func _ready() -> void:
	_sprite = Sprite2D.new()
	_sprite.texture = _tex
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprite.scale = Vector2(2.4, 2.4)   # icône 16px -> ~38px
	add_child(_sprite)

func _process(delta: float) -> void:
	_bob += delta * 3.0
	if _sprite:
		_sprite.position.y = sin(_bob) * 3.0 - 2.0
	queue_redraw()

func _draw() -> void:
	# halo doré + ombre
	draw_set_transform(Vector2(0, 18), 0.0, Vector2(1, 0.4))
	draw_circle(Vector2.ZERO, 12.0, Color(0, 0, 0, 0.25))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var pulse := 0.5 + 0.5 * sin(_bob * 1.5)
	draw_circle(Vector2.ZERO, 22.0, Color(1.0, 0.88, 0.4, 0.10 + 0.10 * pulse))
