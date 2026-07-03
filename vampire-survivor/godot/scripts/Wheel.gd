# Wheel.gd — barre de skills horizontale (bas-centre) : 5 capacités + jauge de
# puissance + emplacement d'ultime. Affichage seul ; tout se lance au clavier/manette.
class_name VSWheel
extends Control

var slots: Array = []        # [{icon, key, frac, left, ready}]
var power: float = 0.0       # 0..1
var ult: Dictionary = {}     # {icon, key, ready}
var slot_tex: Texture2D
var slot_cd_tex: Texture2D

func _ready() -> void:
	slot_tex = load("res://assets/spells/slot.png")
	slot_cd_tex = load("res://assets/spells/slot_cd.png")

func set_data(d: Dictionary) -> void:
	slots = d.get("slots", [])
	power = d.get("power", 0.0)
	ult = d.get("ult", {})
	queue_redraw()

func _draw() -> void:
	var n := slots.size()
	if n == 0:
		return
	var font := get_theme_default_font()
	var pitch := 60.0
	var r := 26.0
	var has_ult: bool = not ult.is_empty()
	var total := n * pitch + (pitch * 1.3 if has_ult else 0.0)
	var cx := size.x / 2.0
	var y := size.y - 52.0
	var x0 := cx - total / 2.0 + pitch / 2.0

	# jauge de puissance
	var full := power >= 1.0
	var gw := n * pitch - 8.0
	var gx := cx - total / 2.0 + 4.0
	var gy := y - r - 16.0
	draw_rect(Rect2(gx - 1, gy - 1, gw + 2, 10), Color(0, 0, 0, 0.55))
	var pc := Color(1.0, 0.82, 0.32) if full else Color(0.45, 0.6, 1.0)
	draw_rect(Rect2(gx, gy, gw * clampf(power, 0.0, 1.0), 8), pc)
	if font:
		var lbl := "ULTIME PRÊT !" if full else "Puissance"
		draw_string(font, Vector2(gx, gy - 4), lbl, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, pc)

	# slots de capacités
	for i in n:
		_draw_slot(Vector2(x0 + i * pitch, y), r, slots[i], font, false)

	# emplacement d'ultime (un peu plus gros, séparé)
	if has_ult:
		var ux := x0 + (n - 1) * pitch + pitch * 1.3
		var ud: Dictionary = ult.duplicate()
		ud["ready"] = full
		ud["frac"] = 0.0
		ud["left"] = 0.0
		_draw_slot(Vector2(ux, y), r + 4.0, ud, font, true)

func _draw_slot(c: Vector2, r: float, s: Dictionary, font: Font, is_ult: bool) -> void:
	var ready: bool = s.get("ready", true)
	draw_circle(c, r + 2.0, Color(0, 0, 0, 0.45))
	var frame := slot_tex if ready else slot_cd_tex
	var fsz := r * 2.35
	if frame:
		draw_texture_rect(frame, Rect2(c - Vector2(fsz / 2.0, fsz / 2.0), Vector2(fsz, fsz)), false)
	# halo doré pour l'ultime prêt
	if is_ult and ready:
		draw_circle(c, r + 6.0, Color(1.0, 0.85, 0.35, 0.30))
	var tex: Texture2D = s.get("icon", null)
	if tex:
		var isz := r * 1.3
		var col := Color(1, 1, 1, 1.0) if ready else Color(1, 1, 1, 0.5)
		draw_texture_rect(tex, Rect2(c - Vector2(isz / 2.0, isz / 2.0), Vector2(isz, isz)), false, col)
	if not ready and float(s.get("left", 0.0)) > 0.0:
		_draw_pie(c, r * 0.9, clampf(float(s.get("frac", 0.0)), 0.0, 1.0), Color(0, 0, 0, 0.5))
		if font:
			var txt := str(int(ceil(float(s["left"]))))
			var w := font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 18).x
			draw_string(font, c + Vector2(-w / 2.0, 6), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(1, 1, 1, 0.95))
	if font:
		var kp := c + Vector2(-r + 1.0, r + 12.0)
		draw_string(font, kp, str(s.get("key", "")), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(1.0, 0.9, 0.55))

func _draw_pie(c: Vector2, r: float, frac: float, col: Color) -> void:
	if frac <= 0.0:
		return
	var pts := PackedVector2Array([c])
	var steps := 32
	var start := -PI / 2.0
	for i in steps + 1:
		var a := start + frac * TAU * (float(i) / steps)
		pts.append(c + Vector2(cos(a), sin(a)) * r)
	draw_colored_polygon(pts, col)
