extends Resource
# Character.gd — Équivalent de engine/character.py

var name: String = "Héros"
var race: String = "Humain"
var char_class: String = "Guerrier"
var level: int = 1
var xp: int = 0
var xp_next: int = 300
var hp: int = 12
var max_hp: int = 12
var mp: int = 4
var max_mp: int = 4
var gold: int = 50
var base_stats: Dictionary = {
	"FORCE": 10, "DEXTÉRITÉ": 10, "CONSTITUTION": 10,
	"INTELLIGENCE": 10, "SAGESSE": 10, "CHARISME": 10
}
var skills: Dictionary = {}
var inventory: Array = []
var equipment: Dictionary = {}  # slot -> item dict
var attack_bonus: int = 0
var armor_class: int = 10

func stat_modifier(stat: String) -> int:
	var val = base_stats.get(stat, 10)
	return int(floor((val - 10) / 2.0))

func calculate_derived():
	var con_mod = stat_modifier("CONSTITUTION")
	var str_mod = stat_modifier("FORCE")
	max_hp = max(1, 8 + con_mod + (level - 1) * 5)
	hp = max_hp
	attack_bonus = str_mod + int(floor(level / 4.0))
	armor_class = 10 + stat_modifier("DEXTÉRITÉ")
	# Équipement
	var armor = equipment.get("armor")
	if armor:
		armor_class = armor.get("ac_bonus", 10) + stat_modifier("DEXTÉRITÉ")
	var weapon = equipment.get("weapon")
	if weapon:
		pass  # weapon modifiers applied in combat

func skill_check(skill: String, difficulty: int) -> Dictionary:
	var roll = randi_range(1, 20)
	var mod = stat_modifier("SAGESSE")  # default
	var total = roll + mod + skills.get(skill, 0)
	return {
		"success": total >= difficulty,
		"roll": roll,
		"total": total,
		"desc": "d20→%d + %d = %d vs DD%d" % [roll, mod, total, difficulty]
	}

func gain_xp(amount: int) -> bool:
	xp += amount
	if xp >= xp_next:
		_level_up()
		return true
	return false

func _level_up():
	level += 1
	xp_next = int(xp_next * 1.5)
	var old_max = max_hp
	calculate_derived()
	hp = min(hp + (max_hp - old_max), max_hp)
