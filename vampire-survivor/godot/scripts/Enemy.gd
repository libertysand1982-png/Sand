# Enemy.gd — un monstre. Données + sprite + barre de vie (gardes). Déplacé par Main.gd.
class_name VSEnemy
extends Node2D

const TYPES := {
	"gobelin": {"sprite": "gobelin", "hp": 26.0,  "speed": 76.0, "dmg": 8.0,  "xp": 1, "radius": 15.0, "size": 42.0, "bar": false},
	"bandit":  {"sprite": "bandit",  "hp": 62.0,  "speed": 58.0, "dmg": 12.0, "xp": 3, "radius": 16.0, "size": 44.0, "bar": false},
	"garde":   {"sprite": "garde",   "hp": 155.0, "speed": 45.0, "dmg": 20.0, "xp": 6, "radius": 18.0, "size": 50.0, "bar": true},
}

var type_key: String
var hp: float
var maxhp: float
var speed: float
var dmg: float
var xp: int
var radius: float
var size: float
var facing: int = 1
var hitflash: float = 0.0
var show_bar: bool = false
var dead: bool = false

var sprite: Sprite2D
var base_scale: Vector2
var _texture: Texture2D

func setup(tkey: String, pos: Vector2, hp_scale: float, tex: Texture2D) -> void:
	type_key = tkey
	var def: Dictionary = TYPES[tkey]
	position = pos
	maxhp = round(def["hp"] * hp_scale)
	hp = maxhp
	speed = def["speed"]
	dmg = def["dmg"]
	xp = def["xp"]
	radius = def["radius"]
	size = def["size"]
	show_bar = def["bar"]
	_texture = tex

func _ready() -> void:
	base_scale = Vector2(size / 64.0, size / 64.0)
	sprite = Sprite2D.new()
	sprite.texture = _texture
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.scale = base_scale
	add_child(sprite)

func _draw() -> void:
	# Barre de vie au-dessus des ennemis costauds, seulement s'ils sont blessés.
	if show_bar and hp < maxhp and hp > 0.0:
		var w := 44.0
		var x := -w / 2.0
		var y := -size * 0.62
		draw_rect(Rect2(x - 1.0, y - 1.0, w + 2.0, 8.0), Color(0, 0, 0, 0.6))
		draw_rect(Rect2(x, y, w, 6.0), Color(0.10, 0.05, 0.05))
		draw_rect(Rect2(x, y, w * clampf(hp / maxhp, 0.0, 1.0), 6.0), Color(0.85, 0.26, 0.31))
