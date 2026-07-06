# BuffBar.gd — marques de buff façon MMO (haut-droite) : icône + nombre de stacks.
# Ne montre que les améliorations offensives (bordure rouge) et défensives (bordure bleue).
class_name VSBuffBar
extends Control

var buffs: Array = []   # [{icon, count, name, off}]
var slot_tex: Texture2D

func _ready() -> void:
	slot_tex = load("res://assets/ui/wow/slot.png")

func set_buffs(b: Array) -> void:
	buffs = b
	queue_redraw()

func _draw() -> void:
	if buffs.is_empty():
		return
	var font := get_theme_default_font()
	var sz := 42.0
	var pitch := 48.0
	var per_row := 8
	var right := size.x - 18.0
	var top := 80.0
	for i in buffs.size():
		var b: Dictionary = buffs[i]
		var col := i % per_row
		var row := i / per_row
		var x := right - float(col + 1) * pitch
		var y := top + float(row) * pitch
		var c := Vector2(x, y)
		# cadre (teinté selon offensif/défensif)
		if slot_tex:
			var tint := Color(1.0, 0.6, 0.5) if b.get("off", true) else Color(0.55, 0.8, 1.0)
			draw_texture_rect(slot_tex, Rect2(c, Vector2(sz, sz)), false, tint)
		# icône
		var ic: Texture2D = b.get("icon", null)
		if ic:
			var pad := 6.0
			draw_texture_rect(ic, Rect2(c + Vector2(pad, pad), Vector2(sz - 2.0 * pad, sz - 2.0 * pad)), false)
		# nombre de stacks (coin bas-droit)
		var cnt := int(b.get("count", 1))
		if cnt > 1 and font:
			var t := str(cnt)
			var tw := font.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, 15).x
			var tp := c + Vector2(sz - tw - 3.0, sz - 3.0)
			draw_string(font, tp + Vector2(1, 1), t, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(0, 0, 0, 0.8))
			draw_string(font, tp, t, HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(1.0, 0.95, 0.7))
