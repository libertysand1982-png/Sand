extends Control
## Village : petits villageois debout (points de clique) sur une rue. On clique
## sur un habitant (aubergiste, donneur de quetes, armurier, marchande) pour lui
## parler, acheter, prendre des contrats, se reposer. Inventaire (I).

const INSET := preload("res://assets/ui/panelInset_brown.png")
const BANNIERE := preload("res://assets/ui/banner_nom.png")

# Points cliquables du village : un lieu (auberge, forge...) place sur le decor.
# rel = position relative (0..1) dans la zone 1152x648 ; portrait = visage du PNJ
# affiche dans la boite de dialogue.
const PNJS := [
	{"nom": "Aubergiste Brigitte", "lieu": "Auberge", "portrait": 5, "type": "auberge",
		"rel": Vector2(0.26, 0.40),
		"texte": "Bienvenue a l'auberge, voyageur ! Une chambre, un repas chaud et toutes les rumeurs du pays."},
	{"nom": "Maitre des contrats", "lieu": "Tableau des contrats", "portrait": 8, "type": "quetes",
		"rel": Vector2(0.5, 0.58),
		"texte": "Le village a besoin de bras solides. Jette un oeil aux contrats affiches au tableau."},
	{"nom": "Maitre d'armes Aldric", "lieu": "Forge", "portrait": 33, "type": "forge",
		"rel": Vector2(0.72, 0.42),
		"texte": "Besoin d'acier ? J'ai les meilleures armes et armures de la region, forgees a la main."},
	{"nom": "Marchande Yara", "lieu": "Marche", "portrait": 15, "type": "potions",
		"rel": Vector2(0.5, 0.30),
		"texte": "Potions, elixirs et remedes ! De quoi survivre aux donjons les plus sombres."},
]

# Decor de fond par village (depose tes illustrations ici ; sinon fond par defaut).
const BG_VILLE := {
	"Bourg de Boisclair": "res://assets/bg/ville_boisclair.png",
	"Hameau de Valombre": "res://assets/bg/ville_valombre.png",
	"Camp des Errants": "res://assets/bg/ville_errants.png",
}

const ARMURERIE := [
	{"nom": "Hache de fer", "icone": "res://assets/equip/iron-axe.png", "slot": "Arme", "atk": 5, "def": 0, "prix": 40},
	{"nom": "Katana", "icone": "res://assets/equip/katana.png", "slot": "Arme", "atk": 7, "def": 0, "prix": 75},
	{"nom": "Rapiere", "icone": "res://assets/equip/rapier.png", "slot": "Arme", "atk": 6, "def": 0, "prix": 55},
	{"nom": "Cimeterre", "icone": "res://assets/equip/scimitar.png", "slot": "Arme", "atk": 6, "def": 0, "prix": 52},
	{"nom": "Arc long", "icone": "res://assets/equip/long-bow.png", "slot": "Arme", "atk": 5, "def": 1, "prix": 50},
	{"nom": "Armure de cuir", "icone": "res://assets/equip/leather-armor.png", "slot": "Armure", "atk": 0, "def": 3, "prix": 35},
	{"nom": "Cotte de mailles", "icone": "res://assets/equip/scale-mail.png", "slot": "Armure", "atk": 0, "def": 5, "prix": 65},
	{"nom": "Armure de plaques", "icone": "res://assets/equip/plate-armor.png", "slot": "Armure", "atk": 0, "def": 8, "prix": 110},
	{"nom": "Heaume de fer", "icone": "res://assets/equip/iron-helmet.png", "slot": "Casque", "atk": 0, "def": 2, "prix": 28},
	{"nom": "Heaume de plaques", "icone": "res://assets/equip/plate-helmet.png", "slot": "Casque", "atk": 0, "def": 3, "prix": 45},
	{"nom": "Cape royale", "icone": "res://assets/equip/royal-cape.png", "slot": "Accessoire", "atk": 1, "def": 2, "prix": 50},
	{"nom": "Brassards runiques", "icone": "res://assets/equip/runed-bracers.png", "slot": "Accessoire", "atk": 2, "def": 1, "prix": 48},
]

const POTIONS := [
	{"nom": "Potion de soin", "icone": "res://assets/items/12.png", "type": "potion", "soin": 20, "prix": 15},
	{"nom": "Grande potion", "icone": "res://assets/items/7.png", "type": "potion", "soin": 40, "prix": 30},
	{"nom": "Elixir supreme", "icone": "res://assets/items/3.png", "type": "potion", "soin": 75, "prix": 55},
]

var _ouvert := false
var _journal: Control = null
var _bust: TextureRect = null


func _ready() -> void:
	$Titre.text = CharacterData.destination
	var sst := $SousTitre as Label
	if sst != null:
		sst.text = "Clique sur un lieu (auberge, forge, marche...) pour interagir"
	# Decor du village si une illustration est fournie pour ce lieu.
	var chemin: String = BG_VILLE.get(CharacterData.destination, "")
	if chemin != "" and ResourceLoader.exists(chemin):
		($Fond as TextureRect).texture = load(chemin)
	_creer_bust()
	_construire_pnjs()
	$BtnRetour.pressed.connect(_on_retour)
	$BtnRetour.mouse_entered.connect(Audio.play_hover)
	$Boutique/BtnFermerBoutique.pressed.connect(_fermer_tout)
	$Inventaire/BtnFermerInv.pressed.connect(_fermer_tout)


# Buste du personnage affiche au-dessus de la boite de dialogue.
func _creer_bust() -> void:
	var cadre := NinePatchRect.new()
	cadre.texture = INSET
	cadre.patch_margin_left = 16
	cadre.patch_margin_top = 16
	cadre.patch_margin_right = 16
	cadre.patch_margin_bottom = 16
	cadre.position = Vector2(8, -128)
	cadre.size = Vector2(108, 122)
	cadre.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$Dialogue.add_child(cadre)
	_bust = TextureRect.new()
	_bust.position = Vector2(12, 12)
	_bust.size = Vector2(84, 98)
	_bust.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_bust.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_bust.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cadre.add_child(_bust)


# --- Points cliquables (lieux) ---------------------------------------------

func _construire_pnjs() -> void:
	# Chaque lieu est une enseigne cliquable posee sur le decor du village.
	var vp := Vector2(1152.0, 648.0)
	for i in PNJS.size():
		var pnj: Dictionary = PNJS[i]
		var lieu: String = pnj["lieu"]
		var larg: float = maxf(150.0, float(lieu.length()) * 12.0 + 56.0)
		var haut := 42.0
		var centre: Vector2 = pnj["rel"] * vp
		var groupe := Control.new()
		groupe.position = centre + Vector2(-larg * 0.5, -haut * 0.5)
		groupe.size = Vector2(larg, haut)
		groupe.pivot_offset = Vector2(larg * 0.5, haut * 0.5)
		$NPCs.add_child(groupe)

		var enseigne := NinePatchRect.new()
		enseigne.texture = BANNIERE
		enseigne.patch_margin_left = 16
		enseigne.patch_margin_top = 8
		enseigne.patch_margin_right = 16
		enseigne.patch_margin_bottom = 8
		enseigne.modulate = Color(0.88, 0.72, 0.44)
		enseigne.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		enseigne.size = Vector2(larg, haut)
		enseigne.mouse_filter = Control.MOUSE_FILTER_IGNORE
		groupe.add_child(enseigne)

		var lbl := Label.new()
		lbl.text = lieu
		lbl.size = Vector2(larg, haut)
		lbl.position = Vector2(0, -1)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 16)
		lbl.add_theme_color_override("font_color", Color(0.28, 0.16, 0.05))
		lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		groupe.add_child(lbl)

		var bouton := Button.new()
		bouton.flat = true
		bouton.position = Vector2.ZERO
		bouton.size = Vector2(larg, haut)
		bouton.pressed.connect(_ouvrir_dialogue.bind(i))
		bouton.mouse_entered.connect(_survol.bind(groupe, true))
		bouton.mouse_exited.connect(_survol.bind(groupe, false))
		groupe.add_child(bouton)

		# Pulsation legere pour signaler que c'est cliquable.
		var t := create_tween().set_loops()
		t.tween_property(groupe, "modulate:a", 0.72, 0.9).set_trans(Tween.TRANS_SINE)
		t.tween_property(groupe, "modulate:a", 1.0, 0.9).set_trans(Tween.TRANS_SINE)


func _survol(groupe: Control, entre: bool) -> void:
	if entre:
		Audio.play_hover()
	var tw := create_tween()
	tw.tween_property(groupe, "scale", Vector2(1.1, 1.1) if entre else Vector2.ONE, 0.1)


# --- Dialogue --------------------------------------------------------------

func _ouvrir_dialogue(idx: int) -> void:
	Audio.play_click()
	_ouvert = true
	var pnj: Dictionary = PNJS[idx]
	if _bust != null:
		_bust.texture = load("res://assets/portraits/%d.png" % pnj["portrait"])
	$Dialogue/NomPNJ.text = pnj["nom"]
	$Dialogue/Texte.text = pnj["texte"]
	for c in $Dialogue/Actions.get_children():
		c.queue_free()
	match pnj["type"]:
		"auberge":
			_bouton_action("Se reposer (10 or)", _se_reposer)
			_bouton_action("Au revoir", _fermer_tout)
		"quetes":
			_bouton_action("Voir les contrats", _ouvrir_contrats)
			_bouton_action("Au revoir", _fermer_tout)
		"forge":
			_bouton_action("Voir l'armurerie", _ouvrir_armurerie)
			_bouton_action("Au revoir", _fermer_tout)
		"potions":
			_bouton_action("Voir les potions", _ouvrir_potions)
			_bouton_action("Au revoir", _fermer_tout)
	$Dialogue.visible = true


func _bouton_action(texte: String, cible: Callable) -> void:
	var b := Button.new()
	b.text = texte
	b.custom_minimum_size = Vector2(0, 38)
	b.pressed.connect(cible)
	b.mouse_entered.connect(Audio.play_hover)
	$Dialogue/Actions.add_child(b)


func _se_reposer() -> void:
	if CharacterData.gold < 10:
		$Dialogue/Texte.text = "Pas assez d'or pour une chambre, l'ami... (10 or requis)"
		return
	Audio.jouer("coins")
	CharacterData.gold -= 10
	$Dialogue/Texte.text = "Tu te reposes a l'auberge. Te voila frais et dispos pour l'aventure !"
	for c in $Dialogue/Actions.get_children():
		c.queue_free()
	_bouton_action("Au revoir", _fermer_tout)


# --- Boutiques -------------------------------------------------------------

func _ouvrir_armurerie() -> void:
	_ouvrir_boutique("Armurerie d'Aldric", ARMURERIE)


func _ouvrir_potions() -> void:
	_ouvrir_boutique("Echoppe de Yara", POTIONS)


# --- Contrats (quetes) -----------------------------------------------------

func _ouvrir_contrats() -> void:
	Audio.play_click()
	$Dialogue.visible = false
	$Boutique/TitreBoutique.text = "Contrats du village"
	$Boutique/OrBoutique.text = "Quetes actives : %d" % CharacterData.quetes_actives.size()
	for c in $Boutique/Liste.get_children():
		c.queue_free()
	for q in CharacterData.quetes_actives:
		_ligne_quete_active(q)
	for id in CharacterData.quetes_disponibles("auberge"):
		_ligne_quete_dispo(id)
	if $Boutique/Liste.get_child_count() == 0:
		var vide := Label.new()
		vide.text = "Aucun contrat disponible pour l'instant."
		vide.add_theme_color_override("font_color", Color(0.3, 0.2, 0.1))
		vide.add_theme_font_size_override("font_size", 16)
		$Boutique/Liste.add_child(vide)
	$Boutique.visible = true


func _ligne_quete_dispo(id: String) -> void:
	var q: Dictionary = CharacterData.CATALOGUE_QUETES[id]
	var ligne := HBoxContainer.new()
	ligne.add_theme_constant_override("separation", 10)
	var txt := Label.new()
	txt.text = "%s - %s" % [q["nom"], q["desc"]]
	txt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	txt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	txt.add_theme_color_override("font_color", Color(0.25, 0.16, 0.08))
	txt.add_theme_font_size_override("font_size", 14)
	ligne.add_child(txt)
	var b := Button.new()
	b.text = "Accepter"
	b.custom_minimum_size = Vector2(110, 36)
	b.pressed.connect(_accepter_q.bind(id))
	b.mouse_entered.connect(Audio.play_hover)
	ligne.add_child(b)
	$Boutique/Liste.add_child(ligne)


func _ligne_quete_active(q: Dictionary) -> void:
	var prete: bool = CharacterData.quete_prete(q)
	var ligne := HBoxContainer.new()
	ligne.add_theme_constant_override("separation", 10)
	var objs := ""
	for o in q["objectifs"]:
		objs += "  [" + CharacterData.progression_objectif(o) + "]"
	var txt := Label.new()
	txt.text = "%s%s" % [q["nom"], objs]
	txt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	txt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	txt.add_theme_color_override("font_color", Color(0.2, 0.5, 0.2) if prete else Color(0.4, 0.3, 0.18))
	txt.add_theme_font_size_override("font_size", 14)
	ligne.add_child(txt)
	if prete:
		var b := Button.new()
		b.text = "Rendre"
		b.custom_minimum_size = Vector2(110, 36)
		b.pressed.connect(_rendre_q.bind(q["id"]))
		b.mouse_entered.connect(Audio.play_hover)
		ligne.add_child(b)
	else:
		var l := Label.new()
		l.text = "en cours"
		l.custom_minimum_size = Vector2(110, 0)
		l.add_theme_color_override("font_color", Color(0.5, 0.4, 0.2))
		l.add_theme_font_size_override("font_size", 13)
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		ligne.add_child(l)
	$Boutique/Liste.add_child(ligne)


func _accepter_q(id: String) -> void:
	Audio.play_click()
	CharacterData.accepter_quete(id)
	_ouvrir_contrats()


func _rendre_q(id: String) -> void:
	if CharacterData.terminer_quete(id):
		Audio.jouer("coins")
	_ouvrir_contrats()


func _ouvrir_boutique(titre: String, catalogue: Array) -> void:
	Audio.play_click()
	$Dialogue.visible = false
	$Boutique/TitreBoutique.text = titre
	$Boutique/OrBoutique.text = "Or : %d" % CharacterData.gold
	for c in $Boutique/Liste.get_children():
		c.queue_free()
	for art in catalogue:
		_ligne_boutique(art)
	$Boutique.visible = true


func _ligne_boutique(art: Dictionary) -> void:
	var ligne := HBoxContainer.new()
	ligne.add_theme_constant_override("separation", 10)

	var icone := TextureRect.new()
	icone.texture = load(art["icone"])
	icone.custom_minimum_size = Vector2(44, 44)
	icone.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icone.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ligne.add_child(icone)

	var nom := Label.new()
	if art.get("type", "") == "potion":
		nom.text = "%s  (Soin +%d)" % [art["nom"], art["soin"]]
	else:
		var stat := ("Atq +%d" % art["atk"]) if art["atk"] > 0 else ("Def +%d" % art["def"])
		nom.text = "%s  (%s)" % [art["nom"], stat]
	nom.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	nom.add_theme_color_override("font_color", Color(0.25, 0.16, 0.08))
	nom.add_theme_font_size_override("font_size", 15)
	nom.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	ligne.add_child(nom)

	var prix := Label.new()
	prix.text = "%d or" % art["prix"]
	prix.custom_minimum_size = Vector2(64, 0)
	prix.add_theme_color_override("font_color", Color(0.55, 0.4, 0.05))
	prix.add_theme_font_size_override("font_size", 16)
	prix.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	ligne.add_child(prix)

	var btn := Button.new()
	btn.text = "Acheter"
	btn.custom_minimum_size = Vector2(110, 36)
	btn.pressed.connect(_acheter.bind(art))
	btn.mouse_entered.connect(Audio.play_hover)
	ligne.add_child(btn)

	$Boutique/Liste.add_child(ligne)


func _acheter(art: Dictionary) -> void:
	if CharacterData.gold < art["prix"]:
		$Boutique/OrBoutique.text = "Or insuffisant ! (%d)" % CharacterData.gold
		return
	Audio.jouer("coins")
	CharacterData.gold -= art["prix"]
	if art.get("type", "") == "potion":
		CharacterData.ajouter_objet({"nom": art["nom"], "icone": art["icone"], "type": "potion",
			"soin": art["soin"], "slot": ""})
	else:
		CharacterData.ajouter_objet({"nom": art["nom"], "icone": art["icone"],
			"slot": art["slot"], "atk": art["atk"], "def": art["def"]})
	$Boutique/OrBoutique.text = "Or : %d (achete !)" % CharacterData.gold


# --- Inventaire ------------------------------------------------------------

func _ouvrir_inventaire() -> void:
	Audio.play_click()
	_ouvert = true
	$Inventaire/OrInv.text = "Or : %d" % CharacterData.gold
	_remplir_grille()
	_remplir_equipement()
	$Inventaire.visible = true


func _remplir_grille() -> void:
	for c in $Inventaire/Grille.get_children():
		c.queue_free()
	for obj in CharacterData.inventaire:
		var b := TextureButton.new()
		b.texture_normal = load(obj["icone"])
		b.ignore_texture_size = true
		b.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		b.custom_minimum_size = Vector2(88, 88)
		var info: String = obj["nom"]
		if obj.get("type", "") == "potion":
			info += "  (Soin +%d) - s'utilise en combat" % obj.get("soin", 0)
		elif obj.get("slot", "") != "":
			info += "  (Atq +%d / Def +%d)\nCliquer pour equiper" % [obj.get("atk", 0), obj.get("def", 0)]
		b.tooltip_text = info
		b.pressed.connect(_equiper.bind(obj))
		b.mouse_entered.connect(Audio.play_hover)
		$Inventaire/Grille.add_child(b)


func _remplir_equipement() -> void:
	for c in $Inventaire/Equip.get_children():
		c.queue_free()
	for slot in ["Arme", "Armure", "Casque", "Accessoire"]:
		var l := Label.new()
		var obj = CharacterData.equipement[slot]
		l.text = "%s : %s" % [slot, obj["nom"] if obj else "-"]
		l.add_theme_color_override("font_color", Color(0.3, 0.2, 0.1))
		l.add_theme_font_size_override("font_size", 15)
		$Inventaire/Equip.add_child(l)
	var total := Label.new()
	total.text = "Bonus total : Atq +%d   Def +%d" % [CharacterData.bonus_atk(), CharacterData.bonus_def()]
	total.add_theme_color_override("font_color", Color(0.5, 0.32, 0.08))
	total.add_theme_font_size_override("font_size", 16)
	$Inventaire/Equip.add_child(total)


func _equiper(obj: Dictionary) -> void:
	if obj.get("slot", "") == "":
		return
	Audio.play_click()
	CharacterData.equiper(obj)
	_remplir_grille()
	_remplir_equipement()


# --- Entrees / divers ------------------------------------------------------

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_I:
			if _ouvert and $Inventaire.visible:
				_fermer_tout()
			elif not _ouvert:
				_ouvrir_inventaire()
		elif event.keycode == KEY_J:
			if _journal == null and not _ouvert:
				_journal = load("res://scenes/Grimoire.tscn").instantiate() as Control
				add_child(_journal)
				_journal.tree_exited.connect(func(): _journal = null)
		elif event.keycode == KEY_ESCAPE:
			_fermer_tout()


func _fermer_tout() -> void:
	Audio.play_click()
	$Dialogue.visible = false
	$Boutique.visible = false
	$Inventaire.visible = false
	_ouvert = false


func _on_retour() -> void:
	Audio.play_click()
	get_tree().change_scene_to_file("res://scenes/WorldMap.tscn")
