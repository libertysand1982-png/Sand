# Wheel.gd — barre d'action façon WoW (bas-centre) : globe de VIE (gauche),
# 5 capacités (centre), globe de PUISSANCE/mana (droite, plein = ultime prêt).
# Affichage seul ; tout se lance au clavier/manette.
class_name VSWheel
extends Control

var slots: Array = []        # [{icon, key, frac, left, ready}]  (5 capacités)
var power: float = 0.0       # 0..1  (jauge d'ultime = globe de mana)
var ult: Dictionary = {}     # {icon, key}
var hp_frac: float = 1.0
var hp_text: String = ""

var slot_tex: Texture2D
var orb_frame: Texture2D
var orb_fill: Texture2D

const GOLD := Color(1.0, 0.88, 0.55)
const CD := Color(0.5, 0.48, 0.56)

func _ready() -> void:
	slot_tex = load("res://assets/ui/wow/slot.png")
	orb_frame = load("res://assets/ui/wow/orb_frame.png")
	orb_fill = load("res://assets/ui/wow/orb_fill.png")

func set_data(d: Dictionary) -> void:
	slots = d.get("slots", [])
	power = d.get("power", 0.0)
	ult = d.get("ult", {})
	hp_frac = d.get("hp", 1.0)
	hp_text = d.get("hp_text", "")
	queue_redraw()

func _draw() -> void:
	var n := slots.size()
	if n == 0:
		return
	var font := get_theme_default_font()
	var pitch := 68.0
	var slot_r := 29.0
	var orb := 122.0
	var gap := 20.0
	var slots_w := n * pitch
	var total := orb + gap + slots_w + gap + orb
	var cx := size.x / 2.0
	var cy := size.y - 88.0
	var x0 := cx - total / 2.0

	# Globe de VIE (gauche)
	_draw_orb(Vector2(x0 + orb / 2.0, cy), orb, hp_frac, Color(1.0, 0.24, 0.20), font, false)
	if font and hp_text != "":
		var hw := font.get_string_size(hp_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 15).x
		draw_string(font, Vector2(x0 + orb / 2.0 - hw / 2.0, cy + orb / 2.0 + 16.0),
				hp_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(1, 0.9, 0.9))

	# Capacités (centre)
	var sx := x0 + orb + gap + pitch / 2.0
	for i in n:
		_draw_slot(Vector2(sx + i * pitch, cy), slot_r, slots[i], font)

	# Globe de PUISSANCE / mana (droite) — plein = ULTIME prêt
	var full := power >= 1.0
	var oc := Color(0.55, 0.82, 1.0) if full else Color(0.30, 0.55, 1.0)
	var opos := Vector2(x0 + total - orb / 2.0, cy)
	_draw_orb(opos, orb, power, oc, font, true)
	var uicon: Texture2D = ult.get("icon", null)
	if uicon:
		var isz := orb * 0.42
		var col := Color(1, 1, 1, 1.0) if full else Color(1, 1, 1, 0.5)
		draw_texture_rect(uicon, Rect2(opos - Vector2(isz / 2.0, isz / 2.0), Vector2(isz, isz)), false, col)
	if font:
		var lbl := "ULTIME !" if full else "Ultime"
		var lc := GOLD if full else Color(0.7, 0.8, 1.0)
		var lw := font.get_string_size(lbl, HORIZONTAL_ALIGNMENT_LEFT, -1, 14).x
		draw_string(font, Vector2(opos.x - lw / 2.0, cy + orb / 2.0 + 16.0), lbl, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, lc)
		draw_string(font, Vector2(opos.x - 6.0, cy - orb / 2.0 + 2.0), "6", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, GOLD)

# Globe rempli bas->haut (liquide) + cadre par-dessus.
func _draw_orb(c: Vector2, s: float, frac: float, tint: Color, font: Font, ready_glow: bool) -> void:
	var f := clampf(frac, 0.0, 1.0)
	if orb_fill and f > 0.01:
		var texw := float(orb_fill.get_width())
		var texh := float(orb_fill.get_height())
		var src := Rect2(0.0, texh * (1.0 - f), texw, texh * f)
		var dst := Rect2(c.x - s / 2.0, c.y - s / 2.0 + s * (1.0 - f), s, s * f)
		draw_texture_rect_region(orb_fill, dst, src, tint)
	if ready_glow and frac >= 1.0:
		draw_arc(c, s / 2.0 - 6.0, 0.0, TAU, 48, Color(1.0, 0.9, 0.4, 0.85), 3.0)
	if orb_frame:
		draw_texture_rect(orb_frame, Rect2(c - Vector2(s / 2.0, s / 2.0), Vector2(s, s)), false)

func _draw_slot(c: Vector2, r: float, s: Dictionary, font: Font) -> void:
	var ready: bool = s.get("ready", true)
	var fsz := r * 2.15
	var evo: bool = s.get("evolved", false)
	# lueur dorée sous les slots évolués
	if evo:
		draw_rect(Rect2(c - Vector2(fsz / 2.0 + 3.0, fsz / 2.0 + 3.0), Vector2(fsz + 6.0, fsz + 6.0)),
				Color(1.0, 0.82, 0.3, 0.30))
	# cadre-slot (fond sombre opaque) d'abord
	if slot_tex:
		var frame_c := Color(1, 1, 1) if ready else CD
		if evo:
			frame_c = Color(1.0, 0.85, 0.45) if ready else Color(0.7, 0.6, 0.4)
		draw_texture_rect(slot_tex, Rect2(c - Vector2(fsz / 2.0, fsz / 2.0), Vector2(fsz, fsz)), false, frame_c)
	# icône par-dessus
	var tex: Texture2D = s.get("icon", null)
	if tex:
		var isz := r * 1.72
		var col := Color(1, 1, 1, 1.0) if ready else Color(1, 1, 1, 0.4)
		draw_texture_rect(tex, Rect2(c - Vector2(isz / 2.0, isz / 2.0), Vector2(isz, isz)), false, col)
	# étoile dorée d'évolution (coin haut-droit)
	if evo and font:
		draw_string(font, c + Vector2(r - 6.0, -r + 12.0), "★", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(1.0, 0.88, 0.4))
	# recharge (camembert + secondes)
	if not ready and float(s.get("left", 0.0)) > 0.0:
		_draw_pie(c, r * 0.94, clampf(float(s.get("frac", 0.0)), 0.0, 1.0), Color(0, 0, 0, 0.55))
		if font:
			var txt := str(int(ceil(float(s["left"]))))
			var w := font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 18).x
			draw_string(font, c + Vector2(-w / 2.0, 6), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(1, 1, 1, 0.95))
	# touche
	if font:
		draw_string(font, c + Vector2(-r + 3.0, -r + 14.0), str(s.get("key", "")),
				HORIZONTAL_ALIGNMENT_LEFT, -1, 13, GOLD)

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
