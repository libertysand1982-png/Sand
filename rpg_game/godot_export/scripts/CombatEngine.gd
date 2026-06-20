extends RefCounted
# CombatEngine.gd — Équivalent de engine/combat.py

var character  # Character resource
var monster: Dictionary = {}
var log: Array = []
var turn: int = 0
var player_defending: bool = false
var combat_over: bool = false
var player_won: bool = false
var status_effects: Dictionary = {}  # name -> {duration, value}

func _init(char, mon: Dictionary):
	character = char
	monster = mon.duplicate(true)
	monster["current_hp"] = mon.get("hp", 10)

func parse_damage(dmg_str: String) -> Dictionary:
	var regex = RegEx.new()
	regex.compile(r"(\d+)d(\d+)([+-]\d+)?")
	var m = regex.search(dmg_str)
	if m == null:
		return {"total": 1, "desc": "1"}
	var count = int(m.get_string(1))
	var sides = int(m.get_string(2))
	var mod   = int(m.get_string(3)) if m.get_string(3) != "" else 0
	var rolls = []
	var total = mod
	for i in count:
		var r = randi_range(1, sides)
		rolls.append(r)
		total += r
	total = max(1, total)
	return {"total": total, "desc": "%dd%d→%s%+d=%d" % [count, sides, str(rolls), mod, total]}

func add_log(msg: String):
	log.append(msg)

func player_attack():
	var weapon = character.equipment.get("weapon", {"name": "Poing", "damage": "1d4"})
	var str_mod = character.stat_modifier("FORCE")
	var atk_roll = randi_range(1, 20)

	if atk_roll == 1:
		add_log("⚔️ FUMBLE! Attaque ratée!")
		return

	var fear_pen = -2 if status_effects.has("fear") else 0
	var total_atk = atk_roll + character.attack_bonus + fear_pen
	var monster_ac = monster.get("ac", 12)

	if atk_roll == 20:  # Critique
		var d1 = parse_damage(weapon.get("damage", "1d6"))
		var d2 = parse_damage(weapon.get("damage", "1d6"))
		var dmg = d1["total"] + d2["total"] + max(0, str_mod)
		monster["current_hp"] -= dmg
		add_log("⚔️ COUP CRITIQUE! %s → %d dégâts!" % [weapon.get("name","?"), dmg])
	elif total_atk >= monster_ac:
		var d = parse_damage(weapon.get("damage", "1d6"))
		var dmg = max(1, d["total"] + str_mod)
		monster["current_hp"] -= dmg
		add_log("⚔️ %s=%d vs CA%d → TOUCHÉ! %d dégâts" % [total_atk, total_atk, monster_ac, dmg])
	else:
		add_log("⚔️ %d vs CA%d → RATÉ!" % [total_atk, monster_ac])

	if monster["current_hp"] <= 0:
		monster["current_hp"] = 0
		combat_over = true
		player_won = true
		add_log("☠️ %s est vaincu!" % monster.get("name","?"))

func player_flee() -> bool:
	var dex_mod = character.stat_modifier("DEXTÉRITÉ")
	var r = randi_range(1, 20) + dex_mod
	if r >= 12:
		combat_over = true
		player_won = false
		add_log("🏃 Fuite réussie! (%d ≥ 12)" % r)
		return true
	add_log("🏃 Fuite échouée! (%d < 12)" % r)
	return false

func player_defend():
	player_defending = true
	add_log("🛡️ Posture défensive (+4 CA)")

func enemy_turn():
	if combat_over:
		return
	var ac_bonus = 4 if player_defending else 0
	var player_ac = character.armor_class + ac_bonus
	var atk_roll = randi_range(1, 20)
	var total_atk = atk_roll + monster.get("attack_bonus", 0)

	if atk_roll == 20:
		var d = parse_damage(monster.get("damage", "1d6"))
		var dmg = d["total"] * 2
		character.hp -= dmg
		add_log("👹 %s CRITIQUE! %d dégâts!" % [monster.get("name","?"), dmg])
	elif total_atk >= player_ac:
		var d = parse_damage(monster.get("damage", "1d6"))
		character.hp -= d["total"]
		add_log("👹 %s touche! %d dégâts" % [monster.get("name","?"), d["total"]])
	else:
		add_log("👹 %s rate!" % monster.get("name","?"))

	player_defending = false
	if character.hp <= 0:
		character.hp = 0
		combat_over = true
		player_won = false
		add_log("💀 Vous êtes tombé au combat...")
	turn += 1
