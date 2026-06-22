extends Control
## Village a portraits : on clique sur un habitant (aubergiste, forgeron,
## marchand de potions) pour lui parler, acheter, se reposer. Inventaire (I).

const INSET := preload("res://assets/ui/panelInset_brown.png")

# PNJ : nom, portrait, type, texte d'accueil.
const PNJS := [
	{"nom": "Aubergiste Brigitte", "portrait": 5, "type": "auberge",
		"texte": "Bienvenue a l'auberge, voyageur ! Une chambre, un repas chaud et toutes les rumeurs du pays."},
	{"nom": "Forgeron Aldric", "portrait": 10, "type": "forge",
		"texte": "Besoin d'acier ? J'ai les meilleures armes et armures de la region, forgees a la main."},
	{"nom": "Marchand Yara", "portrait": 15, "type": "potions",
		"texte": "Potions, elixirs et remedes ! De quoi survivre aux donjons les plus sombres."},
]

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


func _ready() -> void:
	$Titre.text = CharacterData.destination
	_construire_pnjs()
	$BtnRetour.pressed.connect(_on_retour)
	$BtnRetour.mouse_entered.connect(Audio.play_hover)
	$Boutique/BtnFermerBoutique.pressed.connect(_fermer_tout)
	$Inventaire/BtnFermerInv.pressed.connect(_fermer_tout)


# --- Portraits des PNJ -----------------------------------------------------

func _construire_pnjs() -> void:
	var largeur := 220.0
	var ecart := 60.0
	var total := PNJS.size() * largeur + (PNJS.size() - 1) * ecart
	var x0 := (1152.0 - total) / 2.0
	for i in PNJS.size():
		var pnj: Dictionary = PNJS[i]
		var pos := Vector2(x0 + i * (largeur + ecart), 170)

		var cadre := NinePatchRect.new()
		cadre.texture = INSET
		cadre.patch_margin_left = 16
		cadre.patch_margin_top = 16
		cadre.patch_margin_right = 16
		cadre.patch_margin_bottom = 16
		cadre.position = pos
		cadre.size = Vector2(largeur, 240)
		cadre.pivot_offset = Vector2(largeur, 240) * 0.5
		$NPCs.add_child(cadre)

		var portrait := TextureRect.new()
		portrait.texture = load("res://assets/portraits/%d.png" % pnj["portrait"])
		portrait.position = Vector2(18, 18)
		portrait.size = Vector2(largeur - 36, 204)
		portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cadre.add_child(portrait)

		var nom := Label.new()
		nom.text = pnj["nom"]
		nom.position = Vector2(pos.x - 10, pos.y + 248)
		nom.size = Vector2(largeur + 20, 26)
		nom.add_theme_font_size_override("font_size", 17)
		nom.add_theme_color_override("font_color", Color(1, 0.97, 0.85))
		nom.add_theme_color_override("font_outline_color", Color(0.1, 0.07, 0.03))
		nom.add_theme_constant_override("outline_size", 5)
		nom.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		nom.mouse_filter = Control.MOUSE_FILTER_IGNORE
		$NPCs.add_child(nom)

		var bouton := Button.new()
		bouton.flat = true
		bouton.position = pos
		bouton.size = Vector2(largeur, 240)
		bouton.pressed.connect(_ouvrir_dialogue.bind(i))
		bouton.mouse_entered.connect(_survol.bind(cadre, true))
		bouton.mouse_exited.connect(_survol.bind(cadre, false))
		$NPCs.add_child(bouton)


func _survol(cadre: Control, entre: bool) -> void:
	if entre:
		Audio.play_hover()
	var tw := create_tween()
	tw.tween_property(cadre, "scale", Vector2(1.06, 1.06) if entre else Vector2.ONE, 0.1)


# --- Dialogue --------------------------------------------------------------

func _ouvrir_dialogue(idx: int) -> void:
	Audio.play_click()
	_ouvert = true
	var pnj: Dictionary = PNJS[idx]
	$Dialogue/NomPNJ.text = pnj["nom"]
	$Dialogue/Texte.text = pnj["texte"]
	for c in $Dialogue/Actions.get_children():
		c.queue_free()
	match pnj["type"]:
		"auberge":
			_bouton_action("Se reposer (10 or)", _se_reposer)
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
			info += "  (Soin +%d) — s'utilise en combat" % obj.get("soin", 0)
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
		l.text = "%s : %s" % [slot, obj["nom"] if obj else "—"]
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
