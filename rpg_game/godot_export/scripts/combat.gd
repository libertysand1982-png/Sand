extends Node2D

# ── Données du combat chargées depuis GameState ───────────────────────────────
var personnage = {}
var monstre    = {}
var tour       = 0
var combat_fini = false
var joueur_gagne = false

@onready var texte_combat  = $CanvasLayer/TexteCombat
@onready var texte_log     = $CanvasLayer/Log
@onready var btn_attaquer  = $CanvasLayer/BtnAttaquer
@onready var btn_defendre  = $CanvasLayer/BtnDefendre
@onready var btn_fuir      = $CanvasLayer/BtnFuir
@onready var barre_pv      = $CanvasLayer/BarrePV
@onready var barre_pv_mob  = $CanvasLayer/BarrePVMob

var log_combat = []
var en_defense = false

func _ready():
	personnage = GameState.character.duplicate(true)
	monstre    = GameState.monstre_actuel.duplicate(true)
	monstre["pv_actuel"] = monstre.get("hp", 10)

	btn_attaquer.pressed.connect(_attaquer)
	btn_defendre.pressed.connect(_defendre)
	btn_fuir.pressed.connect(_fuir)

	_maj_affichage()
	_ajouter_log("⚔️ Combat contre %s !" % monstre.get("name", "?"))
	_ajouter_log("PV monstre : %d | CA : %d" % [monstre["pv_actuel"], monstre.get("ac", 12)])

func _maj_affichage():
	var pv     = personnage.get("hp", 10)
	var pv_max = personnage.get("max_hp", 10)
	var pv_mob = monstre.get("pv_actuel", 0)
	var pv_mob_max = monstre.get("hp", 10)

	texte_combat.text = "Tour %d\n%s  PV: %d/%d\n%s  PV: %d/%d" % [
		tour,
		personnage.get("name", "Héros"), pv, pv_max,
		monstre.get("name", "Monstre"), pv_mob, pv_mob_max
	]

	if barre_pv:
		barre_pv.value     = float(pv) / float(pv_max) * 100.0
	if barre_pv_mob:
		barre_pv_mob.value = float(pv_mob) / float(pv_mob_max) * 100.0

func _ajouter_log(msg: String):
	log_combat.append(msg)
	if log_combat.size() > 6:
		log_combat.pop_front()
	texte_log.text = "\n".join(log_combat)

func _lancer_de(faces: int) -> int:
	return randi_range(1, faces)

func _parse_degats(chaine: String) -> int:
	var regex = RegEx.new()
	regex.compile(r"(\d+)d(\d+)([+-]\d+)?")
	var m = regex.search(chaine)
	if m == null:
		return 1
	var nb    = int(m.get_string(1))
	var faces = int(m.get_string(2))
	var mod   = int(m.get_string(3)) if m.get_string(3) != "" else 0
	var total = mod
	for i in nb:
		total += _lancer_de(faces)
	return max(1, total)

func _attaquer():
	if combat_fini:
		return
	en_defense = false
	var jet   = _lancer_de(20)
	var bonus = personnage.get("attack_bonus", 0)

	if jet == 1:
		_ajouter_log("💨 FUMBLE — attaque ratée !")
	elif jet == 20:
		var degats = _parse_degats("1d6") + _parse_degats("1d6")
		monstre["pv_actuel"] -= degats
		_ajouter_log("💥 CRITIQUE ! %d dégâts !" % degats)
	elif (jet + bonus) >= monstre.get("ac", 12):
		var degats = max(1, _parse_degats("1d6") + bonus)
		monstre["pv_actuel"] -= degats
		_ajouter_log("⚔️ Touché ! %d dégâts" % degats)
	else:
		_ajouter_log("❌ Raté ! (%d vs CA%d)" % [jet + bonus, monstre.get("ac", 12)])

	monstre["pv_actuel"] = max(0, monstre["pv_actuel"])

	if monstre["pv_actuel"] <= 0:
		_victoire()
		return

	await get_tree().create_timer(0.5).timeout
	_tour_monstre()

func _defendre():
	if combat_fini:
		return
	en_defense = true
	_ajouter_log("🛡️ Posture défensive (+4 CA ce tour)")
	await get_tree().create_timer(0.5).timeout
	_tour_monstre()

func _fuir():
	if combat_fini:
		return
	var jet = _lancer_de(20)
	if jet >= 12:
		_ajouter_log("🏃 Fuite réussie ! (jet %d)" % jet)
		await get_tree().create_timer(1.0).timeout
		_fin_combat(false)
	else:
		_ajouter_log("🏃 Fuite échouée ! (jet %d)" % jet)
		await get_tree().create_timer(0.5).timeout
		_tour_monstre()

func _tour_monstre():
	if combat_fini:
		return
	tour += 1
	var ca_joueur = personnage.get("armor_class", 10) + (4 if en_defense else 0)
	en_defense = false
	var jet   = _lancer_de(20)
	var bonus = monstre.get("attack_bonus", 0)

	if jet == 20:
		var degats = _parse_degats(monstre.get("damage", "1d6")) * 2
		personnage["hp"] -= degats
		_ajouter_log("💀 %s CRITIQUE ! %d dégâts !" % [monstre.get("name","?"), degats])
	elif (jet + bonus) >= ca_joueur:
		var degats = max(1, _parse_degats(monstre.get("damage", "1d6")))
		personnage["hp"] -= degats
		_ajouter_log("👹 %s touche ! %d dégâts" % [monstre.get("name","?"), degats])
	else:
		_ajouter_log("👹 %s rate !" % monstre.get("name","?"))

	personnage["hp"] = max(0, personnage["hp"])
	_maj_affichage()

	if personnage["hp"] <= 0:
		_defaite()
		return

	_maj_affichage()

func _victoire():
	combat_fini  = true
	joueur_gagne = true
	var xp   = monstre.get("xp", 0)
	var butin = monstre.get("loot", [])
	var butin_str = ""
	if butin.size() > 0:
		butin_str = "\nButin : " + str(butin[0][0])
	_ajouter_log("☠️ %s vaincu ! +%d XP%s" % [monstre.get("name","?"), xp, butin_str])
	_maj_affichage()
	btn_attaquer.text = "Continuer"
	btn_attaquer.pressed.disconnect(_attaquer)
	btn_attaquer.pressed.connect(_fin_victoire)
	btn_defendre.visible = false
	btn_fuir.visible     = false

func _defaite():
	combat_fini = true
	_ajouter_log("💀 Vous êtes tombé au combat...")
	_maj_affichage()
	btn_attaquer.text = "Recommencer"
	btn_attaquer.pressed.disconnect(_attaquer)
	btn_attaquer.pressed.connect(_fin_defaite)
	btn_defendre.visible = false
	btn_fuir.visible     = false

func _fin_victoire():
	GameState.character = personnage
	get_tree().change_scene_to_file("res://WorldMap.tscn")

func _fin_defaite():
	personnage["hp"] = personnage.get("max_hp", 10) / 2
	GameState.character = personnage
	get_tree().change_scene_to_file("res://MainMenu.tscn")

func _fin_combat(_gagne: bool):
	GameState.character = personnage
	get_tree().change_scene_to_file("res://WorldMap.tscn")
