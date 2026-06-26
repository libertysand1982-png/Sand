# Wheel.gd — roue de sorts (bas-gauche) : icônes + recharge radiale + touche.
# Affichage seul ; les sorts se lancent au clavier (1..4). Données fournies par Main.
class_name VSWheel
extends Control

var slots: Array = []   # [{icon:Texture2D, key:String, frac:float, left:float, ready:bool}]
var slot_tex: Texture2D
var slot_cd_tex: Texture2D

func _ready() -> void:
	slot_tex = load("res://assets/spells/slot.png")
	slot_cd_tex = load("res://assets/spells/slot_cd.png")

func set_data(data: Array) -> void:
	slots = data
	queue_redraw()

func _draw() -> void:
	var n := slots.size()
	if n == 0:
		return
	var cx := 100.0
	var cy := size.y - 100.0
	var ring_r := 100.0
	var slot_r := 29.0
	var font := get_theme_default_font()
	for i in n:
		var ang := deg_to_rad(-104.0 + i * (120.0 / float(maxi(1, n - 1))))
		var c := Vector2(cx + cos(ang) * ring_r, cy + sin(ang) * ring_r)
		_draw_slot(c, slot_r, slots[i], font)

func _draw_slot(c: Vector2, r: float, s: Dictionary, font: Font) -> void:
	var ready: bool = s["ready"]
	# cadre rond (pack CraftPix : doré = prêt, gris = recharge)
	draw_circle(c, r + 2.0, Color(0, 0, 0, 0.45))
	var frame := slot_tex if ready else slot_cd_tex
	var fsz := r * 2.1
	if frame:
		draw_texture_rect(frame, Rect2(c - Vector2(fsz / 2.0, fsz / 2.0), Vector2(fsz, fsz)), false)
	else:
		draw_circle(c, r, Color(0.12, 0.10, 0.16, 0.92))
	# icône
	var tex: Texture2D = s["icon"]
	if tex:
		var isz := r * 1.25
		var col := Color(1, 1, 1, 1.0) if ready else Color(1, 1, 1, 0.5)
		draw_texture_rect(tex, Rect2(c - Vector2(isz / 2.0, isz / 2.0), Vector2(isz, isz)), false, col)
	# camembert de recharge
	if not ready:
		_draw_pie(c, r * 0.9, clampf(s["frac"], 0.0, 1.0), Color(0, 0, 0, 0.5))
		if font:
			var txt := str(int(ceil(s["left"])))
			var w := font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 18).x
			draw_string(font, c + Vector2(-w / 2.0, 6), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(1, 1, 1, 0.95))
	# pastille de touche
	if font:
		var kp := c + Vector2(r - 6.0, -r + 6.0)
		draw_circle(kp, 9.0, Color(0.1, 0.08, 0.13, 0.95))
		draw_string(font, kp + Vector2(-4, 5), s["key"], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(1.0, 0.9, 0.5))

func _draw_pie(c: Vector2, r: float, frac: float, col: Color) -> void:
	if frac <= 0.0:
		return
	var pts := PackedVector2Array([c])
	var steps := 36
	var start := -PI / 2.0
	for i in steps + 1:
		var a := start + frac * TAU * (float(i) / steps)
		pts.append(c + Vector2(cos(a), sin(a)) * r)
	draw_colored_polygon(pts, col)
