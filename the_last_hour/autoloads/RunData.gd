# RunData — données de la run courante + upgrades permanents inter-runs.
extends Node

# Persistent (survit aux runs via upgrades cellules)
var permanent_hp: int = 0
var permanent_dmg: float = 0.0
var cells_total: int = 0

# Per-run
var max_hp: int = 100
var hp: int = 100
var damage_mult: float = 1.0
var speed_mult: float = 1.0
var knife_dmg: int = 18
var cells: int = 0

func new_run() -> void:
	max_hp = 100 + permanent_hp
	hp = max_hp
	damage_mult = 1.0 + permanent_dmg
	speed_mult = 1.0
	knife_dmg = 18
	cells = 0

func reset_persistent() -> void:
	permanent_hp = 0
	permanent_dmg = 0.0
	cells_total = 0

# Returns true if dead
func take_damage(amount: int) -> bool:
	hp = maxi(0, hp - amount)
	return hp <= 0

func heal(amount: int) -> void:
	hp = mini(max_hp, hp + amount)

func apply_scroll(upgrade_id: String) -> void:
	match upgrade_id:
		"hp_boost":
			max_hp += 25
			hp = mini(max_hp, hp + 25)
		"dmg_boost":
			damage_mult += 0.3
		"speed_boost":
			speed_mult += 0.2
		"knife_upgrade":
			knife_dmg += 10

func spend_cells(cost: int, upgrade_id: String) -> bool:
	if cells < cost:
		return false
	cells -= cost
	match upgrade_id:
		"perm_hp": permanent_hp += 25
		"perm_dmg": permanent_dmg += 0.2
	return true
