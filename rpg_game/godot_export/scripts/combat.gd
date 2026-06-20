extends Node2D

var personnage   = {}
var monstre      = {}
var tour         = 0
var combat_fini  = false
var en_defense   = false

@onready var texte_combat = $CanvasLayer/TexteCombat
@onready var texte_log    = $CanvasLayer/Log
@onready var btn_attaquer = $CanvasLayer/BtnAttaquer
@onready var btn_defendre = $CanvasLayer/BtnDefendre
@onready var btn_fuir     = $CanvasLayer/BtnFuir
@onready var barre_pv_bg  = $CanvasLayer/BarrePV_BG
@onready var barre_pv     = $CanvasLayer/BarrePV
@onready var barre_mob_bg = $CanvasLayer/BarreMob_BG
@onready var barre_mob    = $CanvasLayer/BarreMob
@onready var label_pv     = $CanvasLayer/LabelPV
@onready var label_mob    = $CanvasLayer/LabelMob

# Audio
@onready var snd_attaque  = $AudioAttaque
@onready var snd_touche   = $AudioTouche
@onready var snd_rate     = $AudioRate
@onready var snd_mort     = $AudioMort
@onready var snd_victoire = $AudioVictoire
@onready var snd_fuite    = $AudioFuite
@onready var snd_defense  = $AudioDefense

var log_combat = []

func _ready():
	personnage = GameState.character.duplicate(true)
	monstre    = GameState.monstre_actuel.duplicate(true)
	monstre["pv_actuel"] = monstre.get("hp", 10)

	# Chargement sons
	if snd_attaque:  snd_attaque.stream  = load("res://assets/audio/drawKnife2.ogg")
	if snd_touche:   snd_touche.stream   = load("res://assets/audio/knifeSlice.ogg")
	if snd_rate:     snd_rate.stream     = load("res://assets/audio/switch1.ogg")
	if snd_mort:     snd_mort.stream     = load("res://assets/audio/metalLatch.ogg")
	if snd_victoire: snd_victoire.stream = load("res://assets/audio/handleCoins2.ogg")
	if snd_fuite:    snd_fuite.stream    = load("res://assets/audio/footstep07.ogg")
	if snd_defense:  snd_defense.stream  = load("res://assets/audio/metalClick.ogg")

	# Connexion boutons
	btn_attaquer.pressed.connect(_attaquer)
	btn_defendre.pressed.connect(_defendre)
	btn_fuir.pressed.connect(_fuir)

	# Textures barres PV
	_configurer_barres()
	_maj_affichage()
	_ajouter_log("⚔️ Combat contre %s !" % monstre.get("name", "?"))
	_ajouter_log("PV: %d | CA: %d | Dégâts: %s" % [
		monstre["pv_actuel"], monstre.get("ac", 12), monstre.get("damage","1d6")
	])

func _configurer_barres():
	# Barres PV joueur (rouge)
	if barre_pv_bg:
		var tex_bg = load("res://assets/ui/barBack_horizontalMid.png")
		barre_pv_bg.texture = tex_bg
	if barre_pv:
		var tex = load("res://assets/ui/barRed_horizontalMid.png")
		barre_pv.texture = tex

	# Barres PV monstre (verte)
	if barre_mob_bg:
		var tex_bg = load("res://assets/ui/barBack_horizontalMid.png")
		barre_mob_bg.texture = tex_bg
	if barre_mob:
		var tex = load("res://assets/ui/barGreen_horizontalMid.png")
		barre_mob.texture = tex

func _maj_affichage():
	var pv       = personnage.get("hp", 10)
	var pv_max   = personnage.get("max_hp", 10)
	var pv_mob   = monstre.get("pv_actuel", 0)
	var pv_mob_max = monstre.get("hp", 10)

	texte_combat.text = "Tour %d\n\n%s\n%s" % [
		tour,
		personnage.get("name", "Héros"),
		monstre.get("name", "Monstre")
	]

	if label_pv:
		label_pv.text = "PV: %d/%d" % [pv, pv_max]
	if label_mob:
		label_mob.text = "PV: %d/%d" % [pv_mob, pv_mob_max]

	# Redimensionner les barres
	var ratio_pv  = float(pv) / float(max(pv_max, 1))
	var ratio_mob = float(pv_mob) / float(max(pv_mob_max, 1))
	if barre_pv:
		barre_pv.scale.x  = clamp(ratio_pv, 0.0, 1.0)
	if barre_mob:
		barre_mob.scale.x = clamp(ratio_mob, 0.0, 1.0)

func _ajouter_log(msg: String):
	log_combat.append(msg)
	if log_combat.size() > 7:
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
	if snd_attaque: snd_attaque.play()

	var jet   = _lancer_de(20)
	var bonus = personnage.get("attack_bonus", 0)

	if jet == 1:
		_ajouter_log("💨 FUMBLE — attaque ratée !")
		if snd_rate: snd_rate.play()
	elif jet == 20:
		var degats = _parse_degats("1d6") + _parse_degats("1d6") + max(0, bonus)
		monstre["pv_actuel"] -= degats
		if snd_touche: snd_touche.play()
		_ajouter_log("💥 COUP CRITIQUE ! %d dégâts !" % degats)
	elif (jet + bonus) >= monstre.get("ac", 12):
		var degats = max(1, _parse_degats("1d6") + bonus)
		monstre["pv_actuel"] -= degats
		if snd_touche: snd_touche.play()
		_ajouter_log("⚔️ Touché ! %d dégâts (jet %d)" % [degats, jet + bonus])
	else:
		if snd_rate: snd_rate.play()
		_ajouter_log("❌ Raté ! (%d vs CA%d)" % [jet + bonus, monstre.get("ac", 12)])

	monstre["pv_actuel"] = max(0, monstre["pv_actuel"])
	_maj_affichage()

	if monstre["pv_actuel"] <= 0:
		_victoire()
		return

	await get_tree().create_timer(0.6).timeout
	_tour_monstre()

func _defendre():
	if combat_fini:
		return
	en_defense = true
	if snd_defense: snd_defense.play()
	_ajouter_log("🛡️ Posture défensive ! (+4 CA ce tour)")
	await get_tree().create_timer(0.6).timeout
	_tour_monstre()

func _fuir():
	if combat_fini:
		return
	var jet = _lancer_de(20)
	if jet >= 12:
		if snd_fuite: snd_fuite.play()
		_ajouter_log("🏃 Fuite réussie ! (jet %d ≥ 12)" % jet)
		await get_tree().create_timer(1.0).timeout
		_fin_combat()
	else:
		_ajouter_log("🏃 Fuite échouée ! (jet %d < 12)" % jet)
		await get_tree().create_timer(0.6).timeout
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
		if snd_touche: snd_touche.play()
		_ajouter_log("💀 %s CRITIQUE ! %d dégâts !" % [monstre.get("name","?"), degats])
	elif (jet + bonus) >= ca_joueur:
		var degats = max(1, _parse_degats(monstre.get("damage", "1d6")))
		personnage["hp"] -= degats
		if snd_touche: snd_touche.play()
		_ajouter_log("👹 %s touche ! %d dégâts" % [monstre.get("name","?"), degats])
	else:
		if snd_rate: snd_rate.play()
		_ajouter_log("👹 %s rate !" % monstre.get("name","?"))

	personnage["hp"] = max(0, personnage["hp"])
	_maj_affichage()

	if personnage["hp"] <= 0:
		_defaite()

func _victoire():
	combat_fini = true
	var xp    = monstre.get("xp", 0)
	var loot  = monstre.get("loot", [])
	var butin = ""
	if loot.size() > 0:
		butin = "\nButin : " + str(loot[0][0])
	if snd_victoire: snd_victoire.play()
	_ajouter_log("☠️ %s vaincu ! +%d XP%s" % [monstre.get("name","?"), xp, butin])

	# XP
	personnage["xp"] = personnage.get("xp", 0) + xp
	_sauvegarder()
	_maj_affichage()

	btn_attaquer.text = "✅  Continuer"
	btn_defendre.visible = false
	btn_fuir.visible     = false
	btn_attaquer.pressed.disconnect(_attaquer)
	btn_attaquer.pressed.connect(_fin_combat)

func _defaite():
	combat_fini = true
	if snd_mort: snd_mort.play()
	_ajouter_log("💀 Vous êtes tombé au combat...")

	# Récupère avec la moitié des PV max
	personnage["hp"] = max(1, personnage.get("max_hp", 10) / 2)
	_sauvegarder()
	_maj_affichage()

	btn_attaquer.text = "💀  Recommencer"
	btn_defendre.visible = false
	btn_fuir.visible     = false
	btn_attaquer.pressed.disconnect(_attaquer)
	btn_attaquer.pressed.connect(_retour_menu)

func _fin_combat():
	_sauvegarder()
	get_tree().change_scene_to_file("res://WorldMap.tscn")

func _retour_menu():
	_sauvegarder()
	get_tree().change_scene_to_file("res://MainMenu.tscn")

func _sauvegarder():
	GameState.character = personnage
	GameState.save()

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE and not combat_fini:
			_fuir()
