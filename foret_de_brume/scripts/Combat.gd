extends Control
## Combat tour par tour facon Darkest Dungeon / Beggar's Road.
## Heros (chevalier) a gauche contre des ennemis a droite ; menu d'actions,
## ciblage, animations d'attaque, barres de PV.

const ENEMIS := [
	{"nom": "Sorcier des Brumes", "sheet": "fire_wizard_idle", "frames": 7, "pv": 22, "force": 7},
	{"nom": "Apprenti Maudit", "sheet": "wanderer_idle", "frames": 8, "pv": 16, "force": 5},
	{"nom": "Mage Foudroyant", "sheet": "lightning_mage_idle", "frames": 7, "pv": 19, "force": 6},
]
const POS_ENNEMIS := [Vector2(770, 330), Vector2(940, 410), Vector2(880, 250)]

var _hero := {}
var _enemis := []
var _cible := 0
var _occupe := false


func _ready() -> void:
	_creer_hero()
	_creer_enemis(2)
	$Message.text = "Les profondeurs de %s grouillent d'ennemis !" % CharacterData.destination
	_construire_actions()
	await get_tree().create_timer(0.8).timeout
	_tour_joueur()


func _process(delta: float) -> void:
	for f in _combattants():
		f["t"] += delta
		if f["t"] >= 0.16:
			f["t"] = 0.0
			f["sprite"].frame = (f["sprite"].frame + 1) % f["frames"]


func _combattants() -> Array:
	var t := [_hero]
	t.append_array(_enemis)
	return t


# --- Creation des combattants ---------------------------------------------

func _creer_combattant(nom: String, tex: Texture2D, frames: int, pos: Vector2, face_gauche: bool, pv: int, force: int) -> Dictionary:
	var node := Node2D.new()
	node.position = pos
	$Combattants.add_child(node)

	var sprite := Sprite2D.new()
	sprite.texture = tex
	sprite.hframes = frames
	sprite.scale = Vector2(1.7, 1.7)
	sprite.flip_h = face_gauche
	node.add_child(sprite)

	var fond := ColorRect.new()
	fond.color = Color(0.1, 0.05, 0.05, 0.9)
	fond.size = Vector2(96, 12)
	fond.position = Vector2(-48, -110)
	node.add_child(fond)
	var fill := ColorRect.new()
	fill.color = Color(0.8, 0.2, 0.2)
	fill.size = Vector2(96, 12)
	fill.position = Vector2(-48, -110)
	node.add_child(fill)

	var etiquette := Label.new()
	etiquette.text = nom
	etiquette.add_theme_font_size_override("font_size", 14)
	etiquette.add_theme_color_override("font_color", Color(1, 0.96, 0.85))
	etiquette.add_theme_color_override("font_outline_color", Color(0.1, 0.06, 0.02))
	etiquette.add_theme_constant_override("outline_size", 4)
	etiquette.position = Vector2(-70, -134)
	etiquette.size = Vector2(140, 20)
	etiquette.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	node.add_child(etiquette)

	return {"nom": nom, "node": node, "sprite": sprite, "frames": frames, "t": 0.0,
		"pv": pv, "pv_max": pv, "force": force, "fill": fill, "mort": false, "defense": false}


func _creer_hero() -> void:
	var n := CharacterData.chevalier_index + 1
	var con: int = CharacterData.stats.get("Constitution", 10)
	var force: int = CharacterData.stats.get("Force", 10)
	var pv := 24 + con * 2
	_hero = _creer_combattant(CharacterData.nom, load("res://assets/knights/knight%d_idle.png" % n),
		4, Vector2(280, 390), false, pv, force)
	_hero["idle"] = load("res://assets/knights/knight%d_idle.png" % n)
	_hero["attack"] = load("res://assets/knights/knight%d_attack.png" % n)


func _creer_enemis(nb: int) -> void:
	for i in nb:
		var d: Dictionary = ENEMIS[i % ENEMIS.size()]
		var e := _creer_combattant(d["nom"], load("res://assets/enemies/%s.png" % d["sheet"]),
			d["frames"], POS_ENNEMIS[i], true, d["pv"], d["force"])
		_enemis.append(e)


# --- Menu d'actions --------------------------------------------------------

func _construire_actions() -> void:
	_bouton("Attaquer", _action_attaquer)
	_bouton("Frappe puissante", _action_frappe)
	_bouton("Defendre", _action_defendre)
	_bouton("Fuir", _action_fuir)
	_creer_selecteurs_cibles()


func _bouton(texte: String, cible: Callable) -> void:
	var b := Button.new()
	b.text = texte
	b.custom_minimum_size = Vector2(0, 46)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.pressed.connect(cible)
	b.mouse_entered.connect(Audio.play_hover)
	$Panneau/Actions.add_child(b)


func _creer_selecteurs_cibles() -> void:
	for i in _enemis.size():
		var b := Button.new()
		b.flat = true
		b.focus_mode = Control.FOCUS_NONE
		b.size = Vector2(120, 170)
		b.position = POS_ENNEMIS[i] + Vector2(-60, -140)
		b.pressed.connect(_choisir_cible.bind(i))
		$Cibles.add_child(b)


func _choisir_cible(i: int) -> void:
	if _enemis[i]["mort"]:
		return
	_cible = i
	Audio.play_hover()
	_maj_marqueur()


func _maj_marqueur() -> void:
	for i in _enemis.size():
		if _enemis[i]["mort"]:
			continue
		_enemis[i]["sprite"].modulate = Color(1.3, 1.2, 0.8) if i == _cible else Color(0.85, 0.85, 0.9)


func _activer_actions(actif: bool) -> void:
	for b in $Panneau/Actions.get_children():
		b.disabled = not actif


# --- Tours -----------------------------------------------------------------

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
	await _jouer_tour_joueur(_hero["force"] + CharacterData.bonus_atk() + randi() % 5, false)


func _action_frappe() -> void:
	await _jouer_tour_joueur(int((_hero["force"] + CharacterData.bonus_atk()) * 1.7) + randi() % 4, false)


func _action_defendre() -> void:
	_activer_actions(false)
	_hero["defense"] = true
	$Message.text = "%s leve son bouclier." % _hero["nom"]
	await get_tree().create_timer(0.5).timeout
	await _tour_ennemis()
	_tour_joueur()


func _action_fuir() -> void:
	Audio.play_click()
	get_tree().change_scene_to_file("res://scenes/WorldMap.tscn")


func _jouer_tour_joueur(degats: int, _inutile: bool) -> void:
	if _occupe:
		return
	if _enemis[_cible]["mort"]:
		_cible = _premier_vivant()
	_occupe = true
	_activer_actions(false)
	await _attaque(_hero, _enemis[_cible], degats, true)
	_occupe = false
	if _tous_morts():
		return _fin(true)
	await _tour_ennemis()
	_tour_joueur()


func _tour_ennemis() -> void:
	for e in _enemis:
		if e["mort"]:
			continue
		await _attaque(e, _hero, e["force"] + randi() % 4, false)
		if _hero["mort"]:
			return


# --- Resolution d'une attaque ----------------------------------------------

func _attaque(att: Dictionary, cible: Dictionary, degats: int, est_hero: bool) -> void:
	$Message.text = "%s attaque %s !" % [att["nom"], cible["nom"]]
	if est_hero:
		att["sprite"].texture = att["attack"]
		att["sprite"].hframes = 5
		att["frames"] = 5

	var base: Vector2 = att["node"].position
	var avant: Vector2 = base + (cible["node"].position - base).normalized() * 80.0
	var t1 := create_tween()
	t1.tween_property(att["node"], "position", avant, 0.14).set_trans(Tween.TRANS_QUAD)
	await t1.finished

	_appliquer_degats(cible, degats)

	var t2 := create_tween()
	t2.tween_property(att["node"], "position", base, 0.2).set_trans(Tween.TRANS_QUAD)
	await t2.finished

	if est_hero:
		att["sprite"].texture = att["idle"]
		att["sprite"].hframes = 4
		att["frames"] = 4
	await get_tree().create_timer(0.25).timeout


func _appliquer_degats(cible: Dictionary, degats: int) -> void:
	if cible == _hero:
		degats = maxi(1, degats - CharacterData.bonus_def())
	if cible["defense"]:
		degats = maxi(1, degats / 2)
		cible["defense"] = false
	cible["pv"] = maxi(0, cible["pv"] - degats)
	_maj_barre(cible)
	_degats_flottants(cible["node"].position, degats)
	Audio.play_click()

	var flash := create_tween()
	cible["sprite"].modulate = Color(2, 0.6, 0.6)
	flash.tween_property(cible["sprite"], "modulate", Color(1, 1, 1), 0.25)

	if cible["pv"] <= 0 and not cible["mort"]:
		cible["mort"] = true
		var mort := create_tween()
		mort.tween_property(cible["sprite"], "modulate", Color(0.3, 0.3, 0.35, 0.4), 0.4)
		$Message.text = "%s est vaincu !" % cible["nom"]


func _maj_barre(f: Dictionary) -> void:
	var ratio: float = float(f["pv"]) / float(f["pv_max"])
	f["fill"].size.x = 96.0 * ratio


func _degats_flottants(pos: Vector2, degats: int) -> void:
	var l := Label.new()
	l.text = "-%d" % degats
	l.add_theme_font_size_override("font_size", 28)
	l.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
	l.add_theme_color_override("font_outline_color", Color(0.2, 0.05, 0))
	l.add_theme_constant_override("outline_size", 5)
	l.position = pos + Vector2(-20, -150)
	$Combattants.add_child(l)
	var tw := create_tween()
	tw.tween_property(l, "position", l.position + Vector2(0, -50), 0.7)
	tw.parallel().tween_property(l, "modulate:a", 0.0, 0.7)
	tw.tween_callback(l.queue_free)


# --- Utilitaires / fin -----------------------------------------------------

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
		var butin := 40
		CharacterData.gold += butin
		$Message.text = "Victoire ! Tu empoches %d pieces d'or." % butin
	else:
		$Message.text = "Tu es vaincu... tu bats en retraite."
	await get_tree().create_timer(2.2).timeout
	get_tree().change_scene_to_file("res://scenes/WorldMap.tscn")
