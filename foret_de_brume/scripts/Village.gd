extends Node2D
## Village top-down vivant : le heros se balade, parle aux PNJ (E),
## marchand (boutique de grimoires), aubergiste, donneur de quetes,
## et inventaire (I) avec or et equipement.

const VITESSE := 200.0
const RAYON := 95.0

# --- Parametres isometriques de la ferme ---
const ISO_W := 64.0
const ISO_H := 32.0
const ORIGINE := Vector2(576, 150)
const SCALE_ISO := 0.5

# Grange et maison (batiments fermes : murs + toit, meme cellule).
const GRANGE := ["woodWall_W", "woodWall_N", "woodWallDoorClosed_E", "roofSingleWall_E"]
const MAISON := ["woodWall_W", "woodWallWindow_N", "woodWall_E", "roof_E"]

# PNJ : nom, sprite, position, type, texte.
const PNJS := [
	{"nom": "Marchand Aldric", "sprite": "Male_1_Idle0", "p": Vector2(420, 500), "type": "vendeur",
		"texte": "Bienvenue a la ferme ! J'ai armes et armures de qualite. Jette un oeil a mes etals."},
	{"nom": "Aubergiste Brigitte", "sprite": "Male_3_Idle0", "p": Vector2(720, 520), "type": "aubergiste",
		"texte": "Une chambre pour la nuit, voyageur ? Repose-toi donc, l'aventure attendra bien."},
	{"nom": "Fermier Cedric", "sprite": "Male_5_Idle0", "p": Vector2(230, 470), "type": "quete",
		"texte": "Des gobelins infestent la Caverne d'Ombre et pietinent mes champs. Aiderais-tu un pauvre fermier ?"},
]

# Catalogue de la boutique (equipement).
const CATALOGUE := [
	{"nom": "Hache de fer", "icone": "res://assets/equip/iron-axe.png", "slot": "Arme", "atk": 5, "def": 0, "prix": 40},
	{"nom": "Katana", "icone": "res://assets/equip/katana.png", "slot": "Arme", "atk": 7, "def": 0, "prix": 75},
	{"nom": "Rapiere", "icone": "res://assets/equip/rapier.png", "slot": "Arme", "atk": 6, "def": 0, "prix": 55},
	{"nom": "Arc long", "icone": "res://assets/equip/long-bow.png", "slot": "Arme", "atk": 5, "def": 1, "prix": 50},
	{"nom": "Armure de cuir", "icone": "res://assets/equip/leather-armor.png", "slot": "Armure", "atk": 0, "def": 3, "prix": 35},
	{"nom": "Cotte de mailles", "icone": "res://assets/equip/scale-mail.png", "slot": "Armure", "atk": 0, "def": 5, "prix": 65},
	{"nom": "Armure de plaques", "icone": "res://assets/equip/plate-armor.png", "slot": "Armure", "atk": 0, "def": 8, "prix": 110},
	{"nom": "Heaume de fer", "icone": "res://assets/equip/iron-helmet.png", "slot": "Casque", "atk": 0, "def": 2, "prix": 28},
	{"nom": "Heaume de plaques", "icone": "res://assets/equip/plate-helmet.png", "slot": "Casque", "atk": 0, "def": 3, "prix": 45},
	{"nom": "Cape royale", "icone": "res://assets/equip/royal-cape.png", "slot": "Accessoire", "atk": 1, "def": 2, "prix": 50},
	{"nom": "Brassards runiques", "icone": "res://assets/equip/runed-bracers.png", "slot": "Accessoire", "atk": 2, "def": 1, "prix": 48},
]

var _pnj_proche := -1
var _ouvert := false
var _tex_idle: Texture2D
var _tex_walk: Texture2D
var _marche := false
var _frame_t := 0.0
var _facing := 1
var _pas_t := 0.0

@onready var _hero: Node2D = $Monde/Hero
@onready var _sprite: Sprite2D = $Monde/Hero/Sprite
@onready var _invite: Label = $UI/Invite


func _ready() -> void:
	$UI/Titre.text = CharacterData.destination
	var n := CharacterData.chevalier_index + 1
	_tex_idle = load("res://assets/knights/knight%d_idle.png" % n)
	_tex_walk = load("res://assets/knights/knight%d_walk.png" % n)
	_sprite.texture = _tex_idle
	_sprite.hframes = 4

	_construire_village()
	_construire_pnjs()

	$UI/BtnRetour.pressed.connect(_on_retour)
	$UI/BtnRetour.mouse_entered.connect(Audio.play_hover)
	$UI/Boutique/BtnFermerBoutique.pressed.connect(_fermer_tout)
	$UI/Inventaire/BtnFermerInv.pressed.connect(_fermer_tout)


# --- Construction ----------------------------------------------------------

func _ajouter(chemin: String, pos: Vector2, echelle := 1.0, off_y := 0.0) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = load(chemin)
	s.position = pos + Vector2(0, off_y)
	s.scale = Vector2(echelle, echelle)
	$Monde.add_child(s)
	return s


func iso(cell: Vector2) -> Vector2:
	return ORIGINE + Vector2((cell.x - cell.y) * ISO_W, (cell.x + cell.y) * ISO_H)


func _piece_iso(nom: String, cell: Vector2) -> void:
	var s := Sprite2D.new()
	s.texture = load("res://assets/iso/%s.png" % nom)
	s.scale = Vector2(SCALE_ISO, SCALE_ISO)
	s.position = iso(cell)
	$Monde.add_child(s)


func _batiment_iso(recette: Array, cell: Vector2) -> void:
	for p in recette:
		_piece_iso(p, cell)


func _construire_village() -> void:
	# Sol isometrique : champ cultive au centre, terre autour.
	var cells := []
	for c in range(7):
		for r in range(6):
			cells.append(Vector2(c, r))
	cells.sort_custom(func(a, b): return (a.x + a.y) < (b.x + b.y))
	var champ := func(cell): return cell.x >= 2 and cell.x <= 5 and cell.y >= 2 and cell.y <= 4
	for cell in cells:
		_piece_iso("dirtFarmland_E" if champ.call(cell) else "dirt_E", cell)
	# Rangees de mais sur le champ.
	var field := []
	for c in range(2, 6):
		for r in range(2, 5):
			field.append(Vector2(c, r))
	field.sort_custom(func(a, b): return (a.x + a.y) < (b.x + b.y))
	for cell in field:
		_piece_iso("corn_E", cell)
	# Clotures autour du champ.
	for r in range(2, 5):
		_piece_iso("fenceHigh_N", Vector2(1, r))
	for c in range(2, 6):
		_piece_iso("fenceLow_E", Vector2(c, 5))
	# Batiments : grange et maison (en haut).
	_batiment_iso(GRANGE, Vector2(0, 0))
	_batiment_iso(MAISON, Vector2(3, 0))
	_batiment_iso(GRANGE, Vector2(6, 1))


func _construire_pnjs() -> void:
	for i in PNJS.size():
		var pnj: Dictionary = PNJS[i]
		var s := _ajouter("res://assets/npc/%s.png" % pnj["sprite"], pnj["p"], 0.5, -70.0)
		var etiquette := Label.new()
		etiquette.text = pnj["nom"]
		etiquette.add_theme_font_size_override("font_size", 14)
		etiquette.add_theme_color_override("font_color", Color(1, 0.97, 0.85))
		etiquette.add_theme_color_override("font_outline_color", Color(0.1, 0.07, 0.03))
		etiquette.add_theme_constant_override("outline_size", 4)
		etiquette.position = pnj["p"] + Vector2(-80, -120)
		etiquette.size = Vector2(160, 20)
		etiquette.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		$Monde.add_child(etiquette)


# --- Deplacement du heros --------------------------------------------------

func _process(delta: float) -> void:
	if not _ouvert:
		var dir := _direction()
		if dir != Vector2.ZERO:
			_hero.position += dir * VITESSE * delta
			_hero.position.x = clampf(_hero.position.x, 40, 1112)
			_hero.position.y = clampf(_hero.position.y, 130, 600)
			if not _marche:
				_changer_anim(true)
			if dir.x < -0.1:
				_facing = -1
			elif dir.x > 0.1:
				_facing = 1
			_pas_t += delta
			if _pas_t >= 0.34:
				_pas_t = 0.0
				Audio.jouer("step")
		elif _marche:
			_changer_anim(false)
		_maj_proximite()

	_frame_t += delta
	var periode := 0.085 if _marche else 0.18
	if _frame_t >= periode:
		_frame_t = 0.0
		_sprite.frame = (_sprite.frame + 1) % _sprite.hframes
	_sprite.flip_h = _facing < 0


func _direction() -> Vector2:
	var d := Vector2.ZERO
	if Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP):
		d.y -= 1
	if Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN):
		d.y += 1
	if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
		d.x -= 1
	if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
		d.x += 1
	return d.normalized()


func _changer_anim(marche: bool) -> void:
	_marche = marche
	_sprite.texture = _tex_walk if marche else _tex_idle
	_sprite.hframes = 8 if marche else 4
	_sprite.frame = 0


func _maj_proximite() -> void:
	var meilleur := -1
	var dmin := RAYON
	for i in PNJS.size():
		var d: float = _hero.position.distance_to(PNJS[i]["p"])
		if d < dmin:
			dmin = d
			meilleur = i
	_pnj_proche = meilleur
	if meilleur < 0:
		_invite.visible = false
	else:
		_invite.text = "[E] Parler a %s" % PNJS[meilleur]["nom"]
		_invite.visible = true


# --- Entrees ---------------------------------------------------------------

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	match event.keycode:
		KEY_E:
			if not _ouvert and _pnj_proche >= 0:
				_ouvrir_dialogue(_pnj_proche)
		KEY_I:
			if _ouvert and $UI/Inventaire.visible:
				_fermer_tout()
			elif not _ouvert:
				_ouvrir_inventaire()
		KEY_ESCAPE:
			_fermer_tout()


# --- Dialogue --------------------------------------------------------------

func _ouvrir_dialogue(idx: int) -> void:
	Audio.play_click()
	_ouvert = true
	_invite.visible = false
	var pnj: Dictionary = PNJS[idx]
	$UI/Dialogue/NomPNJ.text = pnj["nom"]
	$UI/Dialogue/Texte.text = pnj["texte"]
	_definir_actions(pnj["type"])
	$UI/Dialogue.visible = true


func _definir_actions(type: String) -> void:
	for c in $UI/Dialogue/Actions.get_children():
		c.queue_free()
	match type:
		"vendeur":
			_bouton_action("Voir les grimoires", _ouvrir_boutique)
			_bouton_action("Au revoir", _fermer_tout)
		"aubergiste":
			_bouton_action("Se reposer", _se_reposer)
			_bouton_action("Au revoir", _fermer_tout)
		"quete":
			if CharacterData.possede_quete("Les gobelins de la Caverne"):
				$UI/Dialogue/Texte.text = "Reviens quand les gobelins de la Caverne d'Ombre seront chasses."
				_bouton_action("Au revoir", _fermer_tout)
			else:
				_bouton_action("Accepter la quete", _accepter_quete)
				_bouton_action("Plus tard", _fermer_tout)


func _bouton_action(texte: String, cible: Callable) -> void:
	var b := Button.new()
	b.text = texte
	b.custom_minimum_size = Vector2(0, 38)
	b.pressed.connect(cible)
	b.mouse_entered.connect(Audio.play_hover)
	$UI/Dialogue/Actions.add_child(b)


func _se_reposer() -> void:
	Audio.play_click()
	$UI/Dialogue/Texte.text = "Vous vous reposez a l'auberge. Vous voila frais et dispos !"
	_definir_actions("")
	_bouton_action("Au revoir", _fermer_tout)


func _accepter_quete() -> void:
	Audio.play_click()
	CharacterData.quetes.append({
		"nom": "Les gobelins de la Caverne",
		"texte": "Chasser les gobelins de la Caverne d'Ombre."})
	$UI/Dialogue/Texte.text = "Quete acceptee ! Que les anciens te protegent, brave heros."
	for c in $UI/Dialogue/Actions.get_children():
		c.queue_free()
	_bouton_action("Au revoir", _fermer_tout)


# --- Boutique --------------------------------------------------------------

func _ouvrir_boutique() -> void:
	Audio.play_click()
	$UI/Dialogue.visible = false
	_remplir_boutique()
	$UI/Boutique.visible = true


func _remplir_boutique() -> void:
	$UI/Boutique/OrBoutique.text = "Or : %d" % CharacterData.gold
	for c in $UI/Boutique/Liste.get_children():
		c.queue_free()
	for art in CATALOGUE:
		var ligne := HBoxContainer.new()
		ligne.add_theme_constant_override("separation", 10)

		var icone := TextureRect.new()
		icone.texture = load(art["icone"])
		icone.custom_minimum_size = Vector2(44, 44)
		icone.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icone.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		ligne.add_child(icone)

		var nom := Label.new()
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

		$UI/Boutique/Liste.add_child(ligne)


func _acheter(art: Dictionary) -> void:
	if CharacterData.gold < art["prix"]:
		$UI/Boutique/OrBoutique.text = "Or insuffisant ! (%d)" % CharacterData.gold
		return
	Audio.play_click()
	CharacterData.gold -= art["prix"]
	CharacterData.ajouter_objet({"nom": art["nom"], "icone": art["icone"],
		"slot": art["slot"], "atk": art["atk"], "def": art["def"]})
	$UI/Boutique/OrBoutique.text = "Or : %d (achete !)" % CharacterData.gold


# --- Inventaire ------------------------------------------------------------

func _ouvrir_inventaire() -> void:
	Audio.play_click()
	_ouvert = true
	_invite.visible = false
	$UI/Inventaire/OrInv.text = "Or : %d" % CharacterData.gold
	_remplir_grille()
	_remplir_equipement()
	$UI/Inventaire.visible = true


func _remplir_grille() -> void:
	for c in $UI/Inventaire/Grille.get_children():
		c.queue_free()
	for obj in CharacterData.inventaire:
		var b := TextureButton.new()
		b.texture_normal = load(obj["icone"])
		b.ignore_texture_size = true
		b.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		b.custom_minimum_size = Vector2(88, 88)
		var info := obj["nom"]
		if obj.get("slot", "") != "":
			info += "  (Atq +%d / Def +%d)\nCliquer pour equiper" % [obj.get("atk", 0), obj.get("def", 0)]
		b.tooltip_text = info
		b.pressed.connect(_equiper.bind(obj))
		b.mouse_entered.connect(Audio.play_hover)
		$UI/Inventaire/Grille.add_child(b)


func _remplir_equipement() -> void:
	for c in $UI/Inventaire/Equip.get_children():
		c.queue_free()
	for slot in ["Arme", "Armure", "Casque", "Accessoire"]:
		var l := Label.new()
		var obj = CharacterData.equipement[slot]
		l.text = "%s : %s" % [slot, obj["nom"] if obj else "—"]
		l.add_theme_color_override("font_color", Color(0.3, 0.2, 0.1))
		l.add_theme_font_size_override("font_size", 15)
		$UI/Inventaire/Equip.add_child(l)
	var total := Label.new()
	total.text = "Bonus total : Atq +%d   Def +%d" % [CharacterData.bonus_atk(), CharacterData.bonus_def()]
	total.add_theme_color_override("font_color", Color(0.5, 0.32, 0.08))
	total.add_theme_font_size_override("font_size", 16)
	$UI/Inventaire/Equip.add_child(total)


func _equiper(obj: Dictionary) -> void:
	if obj.get("slot", "") == "":
		return
	Audio.play_click()
	CharacterData.equiper(obj)
	_remplir_grille()
	_remplir_equipement()


# --- Divers ----------------------------------------------------------------

func _fermer_tout() -> void:
	Audio.play_click()
	$UI/Dialogue.visible = false
	$UI/Boutique.visible = false
	$UI/Inventaire.visible = false
	_ouvert = false


func _on_retour() -> void:
	Audio.play_click()
	get_tree().change_scene_to_file("res://scenes/WorldMap.tscn")
