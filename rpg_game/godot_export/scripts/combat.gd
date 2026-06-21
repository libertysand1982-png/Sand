extends Node2D

@onready var label_lieu = $CanvasLayer/LabelLieu
@onready var stat_heros = $CanvasLayer/StatHeros
@onready var stat_monstre = $CanvasLayer/StatMonstre
@onready var journal = $CanvasLayer/JournalCombat
@onready var label_monstre = $CanvasLayer/LabelMonstre
@onready var btn_attaquer = $CanvasLayer/BtnAttaquer
@onready var btn_potion = $CanvasLayer/BtnPotion
@onready var btn_fuir = $CanvasLayer/BtnFuir
@onready var btn_continuer = $CanvasLayer/BtnContinuer
@onready var btn_recommencer = $CanvasLayer/BtnRecommencer

var monstre: Dictionary = {}
var monstre_hp_actuel: int = 0
var combat_termine: bool = false
var texte_journal: String = ""


func _ready():
	var type = GameState.monstre_actuel
	if type in GameState.monstres_def:
		monstre = GameState.monstres_def[type].duplicate(true)
	else:
		monstre = GameState.monstres_def["gobelin"].duplicate(true)

	monstre_hp_actuel = monstre["hp_max"]
	label_lieu.text = "Combat - " + GameState.lieu_actuel
	label_monstre.text = monstre["nom"]

	_ajouter_journal("[color=#ffaa44]Un " + monstre["nom"] + " apparait ![/color]")
	_maj_stats()

	btn_attaquer.pressed.connect(_attaquer)
	btn_potion.pressed.connect(_utiliser_potion)
	btn_fuir.pressed.connect(_fuir)
	btn_continuer.pressed.connect(_apres_victoire)
	btn_recommencer.pressed.connect(_retour_menu)


func _attaquer():
	if combat_termine:
		return

	# Tour du joueur : jet d attaque
	var jet = randi_range(1, 20) + GameState.joueur_atk
	if jet >= monstre["ac"]:
		var degats = randi_range(1, 8) + max(0, GameState.joueur_atk - 5)
		monstre_hp_actuel -= degats
		_ajouter_journal("[color=#88ff88]Vous attaquez : " + str(degats) + " degats ![/color]")
	else:
		_ajouter_journal("[color=#aaaaaa]Votre attaque rate ! (jet:" + str(jet) + " vs CA:" + str(monstre["ac"]) + ")[/color]")

	if monstre_hp_actuel <= 0:
		_victoire()
		return

	# Tour du monstre
	var jet_m = randi_range(1, 20)
	if jet_m >= GameState.joueur_ca:
		var degats_m = randi_range(monstre["damage_min"], monstre["damage_max"])
		GameState.joueur_hp -= degats_m
		_ajouter_journal("[color=#ff6666]" + monstre["nom"] + " vous attaque : " + str(degats_m) + " degats ![/color]")
	else:
		_ajouter_journal("[color=#aaaaaa]" + monstre["nom"] + " rate ! (jet:" + str(jet_m) + " vs CA:" + str(GameState.joueur_ca) + ")[/color]")

	if GameState.joueur_hp <= 0:
		GameState.joueur_hp = 0
		_defaite()
		return

	_maj_stats()


func _utiliser_potion():
	if combat_termine:
		return
	if GameState.utiliser_potion():
		_ajouter_journal("[color=#44ff88]Vous utilisez une potion ! PV restaures.[/color]")
		_maj_stats()
	else:
		_ajouter_journal("[color=#ffaa44]Aucune potion disponible ![/color]")


func _fuir():
	if combat_termine:
		return
	var jet = randi_range(1, 20)
	if jet >= 10:
		_ajouter_journal("[color=#aaffff]Vous fuyez le combat ![/color]")
		await get_tree().create_timer(1.5).timeout
		get_tree().change_scene_to_file("res://WorldMap.tscn")
	else:
		_ajouter_journal("[color=#ff8844]Fuite impossible ! Le monstre vous bloque.[/color]")
		# Tour du monstre
		var degats_m = randi_range(monstre["damage_min"], monstre["damage_max"])
		GameState.joueur_hp -= degats_m
		_ajouter_journal("[color=#ff6666]" + monstre["nom"] + " vous frappe pendant la fuite : " + str(degats_m) + " degats ![/color]")
		if GameState.joueur_hp <= 0:
			GameState.joueur_hp = 0
			_defaite()
		_maj_stats()


func _victoire():
	combat_termine = true
	var xp = monstre["xp"]
	var or_m = monstre["or"]
	GameState.joueur_xp += xp
	GameState.joueur_or += or_m
	GameState.enregistrer_kill(GameState.monstre_actuel)
	GameState.verifier_niveau()

	_ajouter_journal("")
	_ajouter_journal("[color=#ffdd00]VICTOIRE ! " + monstre["nom"] + " vaincu ![/color]")
	_ajouter_journal("[color=#ffaa44]+" + str(xp) + " XP, +" + str(or_m) + " or[/color]")

	# Verifier si des quetes ont ete completees
	var quetes_faites = []
	for qid in GameState.quetes_actives:
		var q = GameState.quetes_def[qid]
		if "monstre" in q and q["monstre"] == GameState.monstre_actuel:
			var kills = GameState.kill_counts.get(GameState.monstre_actuel, 0)
			if kills >= q["nb"]:
				quetes_faites.append(qid)
	for qid in quetes_faites:
		var q = GameState.quetes_def[qid]
		_ajouter_journal("[color=#44ffaa]Quete completee : " + q["titre"] + " (+" + str(q["xp"]) + "XP, +" + str(q["or"]) + "or)[/color]")
		GameState.completer_quete(qid)

	btn_attaquer.visible = false
	btn_potion.visible = false
	btn_fuir.visible = false
	btn_continuer.visible = true
	_maj_stats()


func _defaite():
	combat_termine = true
	_ajouter_journal("")
	_ajouter_journal("[color=#ff3333]DEFAITE ! Vous avez ete vaincu...[/color]")
	_ajouter_journal("[color=#ffaa44]Vous vous relevez avec 1 PV.[/color]")
	GameState.joueur_hp = 1

	btn_attaquer.visible = false
	btn_potion.visible = false
	btn_fuir.visible = false
	btn_recommencer.visible = true
	_maj_stats()


func _apres_victoire():
	get_tree().change_scene_to_file("res://WorldMap.tscn")


func _retour_menu():
	get_tree().change_scene_to_file("res://WorldMap.tscn")


func _maj_stats():
	stat_heros.text = ("PV: " + str(GameState.joueur_hp) + "/" + str(GameState.joueur_hp_max)
		+ "\nATK: " + str(GameState.joueur_atk) + "  CA: " + str(GameState.joueur_ca))
	var hp_m = max(0, monstre_hp_actuel)
	stat_monstre.text = ("PV: " + str(hp_m) + "/" + str(monstre["hp_max"])
		+ "\nAC: " + str(monstre["ac"]))


func _ajouter_journal(ligne: String):
	texte_journal += ligne + "\n"
	journal.text = texte_journal
