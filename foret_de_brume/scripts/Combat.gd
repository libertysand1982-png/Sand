extends Control
## Combat tour par tour facon Darkest Dungeon.
## Heros (chevalier) vs ennemis (orcs, chaman, squelettes) avec animations
## attaque/blessure/mort, sort magique + VFX, butin et sons.

# Roster d'ennemis : nom, prefixe de fichier, pv, force, magie.
const BESTIAIRE := {
	"orc_warrior": {"nom": "Orc Guerrier", "base": "Orc_Warrior", "pv": 26, "force": 8, "magie": false},
	"orc_berserk": {"nom": "Orc Berserker", "base": "Orc_Berserk", "pv": 34, "force": 10, "magie": false},
	"orc_shaman": {"nom": "Chaman Orc", "base": "Orc_Shaman", "pv": 20, "force": 7, "magie": true},
	"skeleton": {"nom": "Squelette", "base": "Skeleton", "pv": 18, "force": 6, "magie": false},
}

# Rencontres par donjon.
const RENCONTRES := {
	"Caverne d'Ombre": ["skeleton", "skeleton", "orc_warrior"],
	"Pyramide Engloutie": ["orc_warrior", "orc_shaman"],
	"Cimetiere du Dragon": ["orc_berserk", "skeleton", "orc_warrior"],
}
const POS_ENNEMIS := [Vector2(760, 360), Vector2(950, 420), Vector2(870, 280)]

# Table de butin (equipement).
const BUTIN := [
	{"nom": "Cimeterre", "icone": "res://assets/equip/scimitar.png", "slot": "Arme", "atk": 6, "def": 0},
	{"nom": "Armure de cuir", "icone": "res://assets/equip/leather-armor.png", "slot": "Armure", "atk": 0, "def": 3},
	{"nom": "Heaume de fer", "icone": "res://assets/equip/iron-helmet.png", "slot": "Casque", "atk": 0, "def": 2},
	{"nom": "Brassards runiques", "icone": "res://assets/equip/runed-bracers.png", "slot": "Accessoire", "atk": 2, "def": 1},
]

const HAUTEUR_CIBLE := 170.0

var _hero := {}
var _enemis := []
var _cible := 0
var _occupe := false


func _ready() -> void:
	_creer_hero()
	_creer_enemis()
	$Message.text = "Les profondeurs de %s grouillent d'ennemis !" % CharacterData.destination
	_construire_actions()
	await get_tree().create_timer(0.8).timeout
	_tour_joueur()


func _process(delta: float) -> void:
	for f in _tous():
		if f["etat"] == "idle" and not f["mort"]:
			f["t"] += delta
			if f["t"] >= 0.16:
				f["t"] = 0.0
				var n: int = f["frames"]["idle"]
				f["sprite"].frame = (f["sprite"].frame + 1) % n


func _tous() -> Array:
	var t := [_hero]
	t.append_array(_enemis)
	return t


# --- Creation -------------------------------------------------------------

func _frames(tex: Texture2D) -> int:
	return maxi(1, int(round(float(tex.get_width()) / float(tex.get_height()))))


func _creer_combattant(nom: String, texs: Dictionary, pos: Vector2, face_gauche: bool, pv: int, force: int, magie := false) -> Dictionary:
	var node := Node2D.new()
	node.position = pos
	$Combattants.add_child(node)

	var idle: Texture2D = texs["idle"]
	var sprite := Sprite2D.new()
	sprite.texture = idle
	sprite.hframes = _frames(idle)
	var ech := HAUTEUR_CIBLE / float(idle.get_height())
	sprite.scale = Vector2(ech if not face_gauche else -ech, ech)
	node.add_child(sprite)

	var frames := {}
	for k in texs:
		frames[k] = _frames(texs[k])

	var fond := ColorRect.new()
	fond.color = Color(0.1, 0.05, 0.05, 0.9)
	fond.size = Vector2(100, 12)
	fond.position = Vector2(-50, -120)
	node.add_child(fond)
	var fill := ColorRect.new()
	fill.color = Color(0.8, 0.2, 0.2)
	fill.size = Vector2(100, 12)
	fill.position = Vector2(-50, -120)
	node.add_child(fill)

	var label := Label.new()
	label.text = nom
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(1, 0.96, 0.85))
	label.add_theme_color_override("font_outline_color", Color(0.1, 0.06, 0.02))
	label.add_theme_constant_override("outline_size", 4)
	label.position = Vector2(-80, -144)
	label.size = Vector2(160, 20)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	node.add_child(label)

	return {"nom": nom, "node": node, "sprite": sprite, "texs": texs, "frames": frames,
		"t": 0.0, "pv": pv, "pv_max": pv, "force": force, "magie": magie,
		"fill": fill, "mort": false, "defense": false, "etat": "idle"}


func _creer_hero() -> void:
	var n := CharacterData.chevalier_index + 1
	var texs := {
		"idle": load("res://assets/knights/knight%d_idle.png" % n),
		"attack": load("res://assets/knights/knight%d_attack.png" % n),
		"hurt": load("res://assets/knights/knight%d_hurt.png" % n),
	}
	var con: int = CharacterData.stats.get("Constitution", 10)
	var force: int = CharacterData.stats.get("Force", 10)
	_hero = _creer_combattant(CharacterData.nom, texs, Vector2(290, 400), false, 26 + con * 2, force)


func _creer_enemis() -> void:
	var liste: Array = RENCONTRES.get(CharacterData.destination, ["orc_warrior", "skeleton"])
	for i in mini(liste.size(), 3):
		var d: Dictionary = BESTIAIRE[liste[i]]
		var b: String = d["base"]
		var texs := {
			"idle": load("res://assets/enemies/%s_idle.png" % b),
			"attack": load("res://assets/enemies/%s_attack.png" % b),
			"hurt": load("res://assets/enemies/%s_hurt.png" % b),
			"dead": load("res://assets/enemies/%s_dead.png" % b),
		}
		_enemis.append(_creer_combattant(d["nom"], texs, POS_ENNEMIS[i], true, d["pv"], d["force"], d["magie"]))


# --- Actions ---------------------------------------------------------------

func _construire_actions() -> void:
	_bouton("Attaquer", _action_attaquer)
	_bouton("Sort magique", _action_sort)
	_bouton("Defendre", _action_defendre)
	_bouton("Fuir", _action_fuir)
	for i in _enemis.size():
		var b := Button.new()
		b.flat = true
		b.focus_mode = Control.FOCUS_NONE
		b.size = Vector2(130, 180)
		b.position = POS_ENNEMIS[i] + Vector2(-65, -150)
		b.pressed.connect(_choisir_cible.bind(i))
		$Cibles.add_child(b)


func _bouton(texte: String, cible: Callable) -> void:
	var b := Button.new()
	b.text = texte
	b.custom_minimum_size = Vector2(0, 46)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.pressed.connect(cible)
	b.mouse_entered.connect(Audio.play_hover)
	$Panneau/Actions.add_child(b)


func _choisir_cible(i: int) -> void:
	if _enemis[i]["mort"]:
		return
	_cible = i
	Audio.play_hover()
	_maj_marqueur()


func _maj_marqueur() -> void:
	for i in _enemis.size():
		if not _enemis[i]["mort"]:
			_enemis[i]["node"].scale = Vector2(1.12, 1.12) if i == _cible else Vector2.ONE


func _activer_actions(actif: bool) -> void:
	for b in $Panneau/Actions.get_children():
		b.disabled = not actif


func _tour_joueur() -> void:
	if _hero["mort"]:
		return _fin(false)
	if _tous_morts():
		return _fin(true)
	_cible = _premier_vivant()
	_maj_marqueur()
	$Message.text = "%s, a toi de jouer !" % _hero["nom"]
	_activer_actions(true)


func _action_attaquer() -> void:
	var deg := _hero["force"] + CharacterData.bonus_atk() + randi() % 5
	await _jouer_tour(deg, false)


func _action_sort() -> void:
	var int_: int = CharacterData.stats.get("Intelligence", 10)
	await _jouer_tour(int_ + 4 + randi() % 6, true)


func _action_defendre() -> void:
	_activer_actions(false)
	_hero["defense"] = true
	$Message.text = "%s leve sa garde." % _hero["nom"]
	await get_tree().create_timer(0.5).timeout
	await _tour_ennemis()
	_tour_joueur()


func _action_fuir() -> void:
	Audio.play_click()
	get_tree().change_scene_to_file("res://scenes/WorldMap.tscn")


func _jouer_tour(degats: int, magique: bool) -> void:
	if _occupe:
		return
	_occupe = true
	_activer_actions(false)
	if _enemis[_cible]["mort"]:
		_cible = _premier_vivant()
	await _attaque(_hero, _enemis[_cible], degats, magique)
	_occupe = false
	if _tous_morts():
		return _fin(true)
	await _tour_ennemis()
	_tour_joueur()


func _tour_ennemis() -> void:
	for e in _enemis:
		if e["mort"]:
			continue
		var deg: int = e["force"] + randi() % 4
		await _attaque(e, _hero, deg, e["magie"])
		if _hero["mort"]:
			return


# --- Resolution + animations ----------------------------------------------

func _set_anim(f: Dictionary, etat: String) -> void:
	if not f["texs"].has(etat):
		etat = "idle"
	f["sprite"].texture = f["texs"][etat]
	f["sprite"].hframes = f["frames"][etat]
	f["sprite"].frame = 0
	f["etat"] = etat


func _jouer_anim(f: Dictionary, etat: String) -> void:
	_set_anim(f, etat)
	var n: int = f["frames"][etat]
	for i in n:
		f["sprite"].frame = i
		await get_tree().create_timer(0.06).timeout


func _attaque(att: Dictionary, cible: Dictionary, degats: int, magique: bool) -> void:
	$Message.text = "%s %s %s !" % [att["nom"], "lance un sort sur" if magique else "attaque", cible["nom"]]
	Audio.jouer("hit" if magique else "swing")

	var base: Vector2 = att["node"].position
	var avant: Vector2 = base + (cible["node"].position - base).normalized() * (40.0 if magique else 75.0)
	var t1 := create_tween()
	t1.tween_property(att["node"], "position", avant, 0.13)
	_set_anim(att, "attack")
	await t1.finished

	if magique:
		_vfx_magie(cible["node"].position)
		await get_tree().create_timer(0.15).timeout
	_appliquer_degats(cible, degats)

	var t2 := create_tween()
	t2.tween_property(att["node"], "position", base, 0.18)
	await t2.finished
	_set_anim(att, "idle")

	if not cible["mort"]:
		await _jouer_anim(cible, "hurt")
		if not cible["mort"]:
			_set_anim(cible, "idle")
	await get_tree().create_timer(0.15).timeout


func _appliquer_degats(cible: Dictionary, degats: int) -> void:
	if cible == _hero:
		degats = maxi(1, degats - CharacterData.bonus_def())
	if cible["defense"]:
		degats = maxi(1, degats / 2)
		cible["defense"] = false
	cible["pv"] = maxi(0, cible["pv"] - degats)
	_maj_barre(cible)
	_degats_flottants(cible["node"].position, degats)
	Audio.jouer("hurt" if cible == _hero else "hit")

	if cible["pv"] <= 0 and not cible["mort"]:
		cible["mort"] = true
		cible["node"].scale = Vector2.ONE
		Audio.jouer("death")
		await _jouer_anim(cible, "dead")
		cible["etat"] = "mort"
		cible["sprite"].modulate = Color(0.6, 0.6, 0.65, 0.85)
		$Message.text = "%s est vaincu !" % cible["nom"]


func _maj_barre(f: Dictionary) -> void:
	f["fill"].size.x = 100.0 * (float(f["pv"]) / float(f["pv_max"]))


func _degats_flottants(pos: Vector2, degats: int) -> void:
	var l := Label.new()
	l.text = "-%d" % degats
	l.add_theme_font_size_override("font_size", 30)
	l.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
	l.add_theme_color_override("font_outline_color", Color(0.2, 0.05, 0))
	l.add_theme_constant_override("outline_size", 5)
	l.position = pos + Vector2(-20, -160)
	$Combattants.add_child(l)
	var tw := create_tween()
	tw.tween_property(l, "position", l.position + Vector2(0, -55), 0.7)
	tw.parallel().tween_property(l, "modulate:a", 0.0, 0.7)
	tw.tween_callback(l.queue_free)


func _vfx_magie(pos: Vector2) -> void:
	var tex: Texture2D = load("res://assets/enemies/magic_effect.png")
	var s := Sprite2D.new()
	s.texture = tex
	s.hframes = _frames(tex)
	s.position = pos + Vector2(0, -40)
	s.scale = Vector2(2, 2)
	s.modulate = Color(0.7, 0.5, 1.0)
	$Combattants.add_child(s)
	for i in s.hframes:
		s.frame = i
		await get_tree().create_timer(0.05).timeout
	s.queue_free()


# --- Fin / utilitaires -----------------------------------------------------

func _premier_vivant() -> int:
	for i in _enemis.size():
		if not _enemis[i]["mort"]:
			return i
	return 0


func _tous_morts() -> bool:
	for e in _enemis:
		if not e["mort"]:
			return false
	return true


func _fin(victoire: bool) -> void:
	_activer_actions(false)
	if victoire:
		var butin := 30 + randi() % 26
		CharacterData.gold += butin
		var msg := "Victoire ! Butin : %d or" % butin
		if randf() < 0.6:
			var objet: Dictionary = BUTIN[randi() % BUTIN.size()].duplicate()
			CharacterData.ajouter_objet(objet)
			msg += " + %s" % objet["nom"]
		Audio.jouer("coins")
		$Message.text = msg
	else:
		$Message.text = "Tu es vaincu... tu bats en retraite."
	await get_tree().create_timer(2.4).timeout
	get_tree().change_scene_to_file("res://scenes/WorldMap.tscn")
