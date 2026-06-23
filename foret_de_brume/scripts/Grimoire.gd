extends Control
## Grimoire du heros : journal a onglets (Heros, Attributs, Competences,
## Quetes, Lieux, Hauts faits). S'ouvre en surimpression (touche J).

const ONGLETS := ["Heros", "Attributs", "Competences", "Quetes", "Lieux", "Hauts faits"]
const STAT_ORDRE := ["Force", "Dexterite", "Constitution", "Intelligence", "Sagesse", "Charisme"]

const COMPETENCES := [
	{"nom": "Frappe", "desc": "Coup d'arme de base. Degats = Force + arme."},
	{"nom": "Taillade", "desc": "Coup puissant (x1.7). Coute 2 mana."},
	{"nom": "Boule de feu", "desc": "Sort offensif. Degats bases sur l'Intelligence. Coute 4 mana."},
	{"nom": "Soin", "desc": "Restaure des PV. Coute 4 mana."},
	{"nom": "Garde", "desc": "Reduit de moitie les degats subis au prochain coup."},
]

const HAUTS_FAITS := [
	{"nom": "Premier sang", "desc": "Remporter un premier combat", "cond": "combat"},
	{"nom": "Explorateur", "desc": "Visiter 3 lieux differents", "cond": "explorer"},
	{"nom": "Fortune", "desc": "Posseder 200 pieces d'or", "cond": "fortune"},
	{"nom": "Maitre d'armes", "desc": "Equiper une arme et une armure", "cond": "armes"},
	{"nom": "Heros legendaire", "desc": "Atteindre le niveau 5", "cond": "niveau5"},
]

const ENCRE := Color(0.3, 0.2, 0.1)
const OR := Color(0.55, 0.4, 0.05)

var _onglet := "Heros"


func _ready() -> void:
	$Livre/Titre.text = "Grimoire de %s" % CharacterData.nom
	for nom in ONGLETS:
		var b := Button.new()
		b.text = nom
		b.pressed.connect(_changer_onglet.bind(nom))
		b.mouse_entered.connect(Audio.play_hover)
		$Livre/Onglets.add_child(b)
	$Livre/BtnFermer.pressed.connect(_fermer)
	_afficher()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_J or event.keycode == KEY_ESCAPE:
			get_viewport().set_input_as_handled()
			_fermer()


func _changer_onglet(nom: String) -> void:
	Audio.play_click()
	_onglet = nom
	_afficher()


func _vider() -> void:
	for c in $Livre/Defile/Contenu.get_children():
		c.queue_free()


func _ajouter(noeud: Control) -> void:
	$Livre/Defile/Contenu.add_child(noeud)


func _label(texte: String, taille := 17, couleur := ENCRE) -> Label:
	var l := Label.new()
	l.text = texte
	l.add_theme_font_size_override("font_size", taille)
	l.add_theme_color_override("font_color", couleur)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return l


func _afficher() -> void:
	_vider()
	match _onglet:
		"Heros": _onglet_heros()
		"Attributs": _onglet_attributs()
		"Competences": _onglet_competences()
		"Quetes": _onglet_quetes()
		"Lieux": _onglet_lieux()
		"Hauts faits": _onglet_hauts_faits()


# --- Onglets ---------------------------------------------------------------

func _onglet_heros() -> void:
	var entete := HBoxContainer.new()
	entete.add_theme_constant_override("separation", 18)
	var portrait := TextureRect.new()
	portrait.texture = load("res://assets/portraits/%d.png" % CharacterData.portrait_index)
	portrait.custom_minimum_size = Vector2(150, 150)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	entete.add_child(portrait)

	var infos := VBoxContainer.new()
	infos.add_child(_label("%s" % CharacterData.nom, 24))
	infos.add_child(_label("%s  %s" % [CharacterData.race_nom, CharacterData.classe_nom], 18))
	infos.add_child(_label("Niveau %d   (XP %d / %d)" % [CharacterData.niveau, CharacterData.xp, CharacterData.xp_suivant], 16))
	infos.add_child(_label("Points de vie : %d" % CharacterData.pv_max(), 16, Color(0.7, 0.2, 0.2)))
	infos.add_child(_label("Mana : %d" % CharacterData.mana_max(), 16, Color(0.2, 0.35, 0.7)))
	infos.add_child(_label("Or : %d" % CharacterData.gold, 16, OR))
	entete.add_child(infos)
	_ajouter(entete)

	_ajouter(_label("", 8))
	_ajouter(_label("Equipement", 19, OR))
	for slot in ["Arme", "Armure", "Casque", "Accessoire"]:
		var obj = CharacterData.equipement[slot]
		_ajouter(_label("  %s : %s" % [slot, obj["nom"] if obj else "-"]))
	_ajouter(_label("  Bonus : Atq +%d   Def +%d" % [CharacterData.bonus_atk(), CharacterData.bonus_def()], 15, OR))


func _onglet_attributs() -> void:
	_ajouter(_label("Points a distribuer : %d" % CharacterData.points_attributs, 18,
		Color(0.2, 0.5, 0.2) if CharacterData.points_attributs > 0 else ENCRE))
	for s in STAT_ORDRE:
		var ligne := HBoxContainer.new()
		ligne.add_theme_constant_override("separation", 10)
		var nom := _label(s, 18)
		nom.custom_minimum_size = Vector2(220, 0)
		ligne.add_child(nom)
		var val := _label(str(int(CharacterData.stats.get(s, 8))), 18)
		val.custom_minimum_size = Vector2(50, 0)
		ligne.add_child(val)
		if CharacterData.points_attributs > 0:
			var plus := Button.new()
			plus.text = "+"
			plus.custom_minimum_size = Vector2(40, 30)
			plus.pressed.connect(_augmenter.bind(s))
			plus.mouse_entered.connect(Audio.play_hover)
			ligne.add_child(plus)
		_ajouter(ligne)


func _augmenter(stat: String) -> void:
	if CharacterData.points_attributs <= 0:
		return
	Audio.play_click()
	CharacterData.stats[stat] = int(CharacterData.stats.get(stat, 8)) + 1
	CharacterData.points_attributs -= 1
	_afficher()


func _onglet_competences() -> void:
	for c in COMPETENCES:
		_ajouter(_label(c["nom"], 19, OR))
		_ajouter(_label("    " + c["desc"], 15))


func _onglet_quetes() -> void:
	_ajouter(_label("Quetes en cours", 19, OR))
	if CharacterData.quetes.is_empty():
		_ajouter(_label("    Aucune quete en cours."))
	else:
		for q in CharacterData.quetes:
			_ajouter(_label("  - %s" % q["nom"], 17))
			_ajouter(_label("      " + q.get("texte", ""), 14))
	_ajouter(_label("", 8))
	_ajouter(_label("Quetes accomplies", 19, OR))
	if CharacterData.quetes_reussies.is_empty():
		_ajouter(_label("    Aucune pour l'instant."))
	else:
		for q in CharacterData.quetes_reussies:
			_ajouter(_label("  (v) %s" % str(q), 16, Color(0.2, 0.5, 0.2)))


func _onglet_lieux() -> void:
	_ajouter(_label("Lieux visites", 19, OR))
	if CharacterData.lieux_visites.is_empty():
		_ajouter(_label("    Tu n'as encore explore aucun lieu."))
	else:
		for lieu in CharacterData.lieux_visites:
			_ajouter(_label("  - %s" % str(lieu), 17))


func _onglet_hauts_faits() -> void:
	for hf in HAUTS_FAITS:
		var debloque := _hf_debloque(hf["cond"])
		var couleur := Color(0.85, 0.65, 0.1) if debloque else Color(0.5, 0.45, 0.4)
		var prefixe := "[*] " if debloque else "[ ] "
		_ajouter(_label(prefixe + hf["nom"], 18, couleur))
		_ajouter(_label("    " + hf["desc"] + ("  (debloque !)" if debloque else ""), 14))


func _hf_debloque(cond: String) -> bool:
	match cond:
		"combat":
			for h in CharacterData.hauts_faits:
				if h["nom"] == "Premier sang":
					return true
			return false
		"explorer":
			return CharacterData.lieux_visites.size() >= 3
		"fortune":
			return CharacterData.gold >= 200
		"armes":
			return CharacterData.equipement["Arme"] != null and CharacterData.equipement["Armure"] != null
		"niveau5":
			return CharacterData.niveau >= 5
	return false


func _fermer() -> void:
	Audio.play_click()
	queue_free()
