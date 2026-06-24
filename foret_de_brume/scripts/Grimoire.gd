extends Control
## Grimoire du heros : journal a onglets (Heros, Attributs, Competences,
## Quetes, Histoire, Lieux, Bestiaire, Hauts faits). S'ouvre via la touche J.

const ONGLETS := ["Heros", "Sac", "Attributs", "Competences", "Quetes", "Histoire", "Lieux", "Bestiaire", "Hauts faits"]
const STAT_ORDRE := ["Force", "Dexterite", "Constitution", "Intelligence", "Sagesse", "Charisme"]
const SLOTS_EQUIP := ["Casque", "Arme", "Armure", "Accessoire"]
const SLOT_TEX := preload("res://assets/ui/slot.png")

const COMPETENCES := [
	{"nom": "Frappe", "cout": "gratuit", "desc": "Coup d'arme de base. Degats = Force + bonus d'arme + un peu de hasard."},
	{"nom": "Taillade", "cout": "2 mana", "desc": "Coup puissant a 1.7x les degats, pour briser une defense solide."},
	{"nom": "Boule de feu", "cout": "4 mana", "desc": "Sort offensif a distance, base sur l'Intelligence. Ignore l'armure."},
	{"nom": "Soin", "cout": "4 mana", "desc": "Canalise la lumiere pour restaurer environ 25 points de vie."},
	{"nom": "Garde", "cout": "gratuit", "desc": "Leve le bouclier : divise par deux les degats du prochain coup recu."},
	{"nom": "Potion", "cout": "gratuit", "desc": "Boit une potion du sac pour recuperer des PV en plein combat."},
	{"nom": "Fuir", "cout": "gratuit", "desc": "Abandonne le combat et bat en retraite vers la carte du monde."},
]

# Recits de la campagne (7 regions, 7 artefacts).
const HISTOIRE := [
	{"titre": "La Foret de Brume",
	 "texte": "Depuis des siecles, une brume surnaturelle ronge le royaume. Elle nait d'un mal ancien, scelle jadis par sept gardiens. Aujourd'hui les sceaux faiblissent, et c'est a toi de reprendre le flambeau."},
	{"titre": "La quete des sept artefacts",
	 "texte": "Sept regions, sept gardiens dechus devenus des boss redoutables. Chacun detient un artefact de pouvoir. Reunis les sept reliques pour affronter le Seigneur de la Brume et rompre la malediction."},
	{"titre": "Le voyage",
	 "texte": "Tu progresseras region par region jusqu'au niveau 70. Une fois un gardien vaincu et son artefact en main, reviens a la cite principale : de la, tu choisiras la prochaine contree a liberer."},
]

# Bestiaire : description de chaque creature de la region.
const BESTIAIRE := [
	{"nom": "Gobelin", "desc": "Petit pillard fourbe. Faible seul, redoutable en meute."},
	{"nom": "Squelette", "desc": "Guerrier mort-vivant releve par la brume. Fragile mais acharne."},
	{"nom": "Champignon Geant", "desc": "Creature fongique des cavernes humides. Resiste etonnamment bien aux coups."},
	{"nom": "Orc Guerrier", "desc": "Brute disciplinee armee d'acier. Frappe fort et encaisse."},
	{"nom": "Orc Berserker", "desc": "Orc enrage qui ne connait ni peur ni douleur. Tres dangereux."},
	{"nom": "Chaman Orc", "desc": "Manieur de magie noire. Ses sorts transpercent l'armure."},
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
		b.add_theme_font_size_override("font_size", 13)
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
		"Sac": _onglet_sac()
		"Attributs": _onglet_attributs()
		"Competences": _onglet_competences()
		"Quetes": _onglet_quetes()
		"Histoire": _onglet_histoire()
		"Lieux": _onglet_lieux()
		"Bestiaire": _onglet_bestiaire()
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


func _onglet_sac() -> void:
	# En-tete : or + bonus total.
	var entete := HBoxContainer.new()
	entete.add_theme_constant_override("separation", 24)
	entete.add_child(_label("Or : %d" % CharacterData.gold, 18, OR))
	entete.add_child(_label("Bonus  Atq +%d   Def +%d" % [CharacterData.bonus_atk(), CharacterData.bonus_def()], 16, ENCRE))
	_ajouter(entete)

	_ajouter(_label("Equipement", 19, OR))
	var rangee := HBoxContainer.new()
	rangee.add_theme_constant_override("separation", 16)
	for slot in SLOTS_EQUIP:
		var col := VBoxContainer.new()
		col.add_theme_constant_override("separation", 2)
		var obj_eq = CharacterData.equipement[slot]
		var tex_eq: Texture2D = load(obj_eq["icone"]) if obj_eq != null else null
		var info_eq: String = (obj_eq["nom"] + "\nCliquer pour retirer") if obj_eq != null else "Emplacement vide"
		col.add_child(_slot(72.0, tex_eq, _clic_equip.bind(slot), info_eq))
		var cap := _label(slot, 13, ENCRE)
		cap.custom_minimum_size = Vector2(72, 0)
		cap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		col.add_child(cap)
		rangee.add_child(col)
	_ajouter(rangee)

	_ajouter(_label("", 6))
	_ajouter(_label("Sac", 19, OR))
	if CharacterData.inventaire.is_empty():
		_ajouter(_label("    Ton sac est vide.", 15))
		return
	var grille := GridContainer.new()
	grille.columns = 8
	grille.add_theme_constant_override("h_separation", 8)
	grille.add_theme_constant_override("v_separation", 8)
	for it in CharacterData.inventaire:
		var tex_it: Texture2D = load(it["icone"])
		var info_it: String = it["nom"]
		if it.get("type", "") == "potion":
			info_it += "  (Soin +%d)\nS'utilise en combat" % it.get("soin", 0)
		elif it.get("slot", "") != "":
			info_it += "  (Atq +%d / Def +%d)\nCliquer pour equiper" % [it.get("atk", 0), it.get("def", 0)]
		grille.add_child(_slot(70.0, tex_it, _clic_sac.bind(it), info_it))
	_ajouter(grille)


func _slot(taille: float, icone: Texture2D, on_click: Callable, info: String) -> Control:
	var box := Control.new()
	box.custom_minimum_size = Vector2(taille, taille)
	var bg := NinePatchRect.new()
	bg.texture = SLOT_TEX
	bg.patch_margin_left = 8
	bg.patch_margin_top = 8
	bg.patch_margin_right = 8
	bg.patch_margin_bottom = 8
	bg.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(bg)

	var btn := TextureButton.new()
	if icone != null:
		btn.texture_normal = icone
	btn.ignore_texture_size = true
	btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	btn.position = Vector2(8, 8)
	btn.size = Vector2(taille - 16, taille - 16)
	btn.tooltip_text = info
	btn.pressed.connect(on_click)
	btn.mouse_entered.connect(Audio.play_hover)
	box.add_child(btn)
	return box


func _clic_equip(slot: String) -> void:
	if CharacterData.equipement[slot] == null:
		return
	Audio.play_click()
	CharacterData.desequiper(slot)
	_afficher()


func _clic_sac(obj: Dictionary) -> void:
	if obj.get("slot", "") != "":
		Audio.play_click()
		CharacterData.equiper(obj)
		_afficher()


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
	_ajouter(_label("Aptitudes de combat", 20, OR))
	_ajouter(_label("Le mana se regenere d'un point a chaque tour.", 13))
	_ajouter(_label("", 6))
	for c in COMPETENCES:
		_ajouter(_label("%s   [%s]" % [c["nom"], c["cout"]], 18, OR))
		_ajouter(_label("    " + c["desc"], 14))


func _onglet_histoire() -> void:
	for chap in HISTOIRE:
		_ajouter(_label(chap["titre"], 20, OR))
		_ajouter(_label("    " + chap["texte"], 15))
		_ajouter(_label("", 6))
	_ajouter(_label("Region actuelle : %s" % CharacterData.region_courante, 17, ENCRE))
	var n: int = CharacterData.artefacts.size()
	_ajouter(_label("Artefacts reunis : %d / 7" % n, 17,
		Color(0.2, 0.5, 0.2) if n > 0 else ENCRE))
	if n > 0:
		for a in CharacterData.artefacts:
			_ajouter(_label("  - %s" % str(a), 14, OR))


func _onglet_bestiaire() -> void:
	var vus: int = CharacterData.monstres_vus.size()
	_ajouter(_label("Creatures rencontrees : %d / %d" % [vus, BESTIAIRE.size()], 18, OR))
	_ajouter(_label("", 6))
	for m in BESTIAIRE:
		var nom_m: String = m["nom"]
		if CharacterData.monstres_vus.has(nom_m):
			var tues: int = int(CharacterData.monstres_vaincus.get(nom_m, 0))
			_ajouter(_label(nom_m, 18, OR))
			_ajouter(_label("    " + m["desc"], 14))
			_ajouter(_label("    Vaincus : %d" % tues, 13, Color(0.2, 0.5, 0.2)))
		else:
			_ajouter(_label("??? (creature inconnue)", 18, Color(0.5, 0.45, 0.4)))
			_ajouter(_label("    Affronte-la pour reveler sa fiche.", 13, Color(0.5, 0.45, 0.4)))


func _onglet_quetes() -> void:
	_ajouter(_label("Quetes en cours", 19, OR))
	if CharacterData.quetes_actives.is_empty():
		_ajouter(_label("    Aucune quete en cours."))
	else:
		for q in CharacterData.quetes_actives:
			var prete: bool = CharacterData.quete_prete(q)
			_ajouter(_label("  - %s%s" % [q["nom"], "  (a rendre !)" if prete else ""], 17,
				Color(0.2, 0.5, 0.2) if prete else ENCRE))
			_ajouter(_label("      " + q["desc"], 13))
			for o in q["objectifs"]:
				_ajouter(_label("        - " + CharacterData.progression_objectif(o), 13))
	_ajouter(_label("", 8))
	_ajouter(_label("Quetes accomplies", 19, OR))
	if CharacterData.quetes_reussies.is_empty():
		_ajouter(_label("    Aucune pour l'instant."))
	else:
		for id in CharacterData.quetes_reussies:
			var titre: String = str(id)
			if CharacterData.CATALOGUE_QUETES.has(id):
				titre = CharacterData.CATALOGUE_QUETES[id]["nom"]
			_ajouter(_label("  (v) %s" % titre, 16, Color(0.2, 0.5, 0.2)))


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
