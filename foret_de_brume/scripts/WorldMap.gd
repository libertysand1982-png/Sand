extends Control
## Carte du monde "La Foret de Brume" facon carte au tresor a l'encre.
## Genere les lieux interactifs, les routes, le decor et la bordure.

const ENCRE := Color(0.27, 0.2, 0.13)
const ENCRE_PALE := Color(0.4, 0.3, 0.18)

# Lieux interactifs : nom, icone, position (centre), description.
const LIEUX := [
	{"nom": "Chateau de l'Aube", "icone": "castle", "pos": Vector2(380, 300),
		"desc": "La citadelle royale, coeur du royaume et point de depart de ta quete."},
	{"nom": "Bourg de Boisclair", "icone": "houses", "pos": Vector2(560, 410),
		"desc": "Un village prospere ou marchands et aubergistes accueillent les aventuriers."},
	{"nom": "Abbaye Saint-Gral", "icone": "church", "pos": Vector2(740, 250),
		"desc": "Un monastere ancien dont les moines veillent sur d'antiques reliques."},
	{"nom": "Mine de Fer-Noir", "icone": "mine", "pos": Vector2(884, 168),
		"desc": "Des galeries profondes creusees dans la montagne. On y murmure des dangers."},
	{"nom": "Ruines de Mornkeep", "icone": "runis", "pos": Vector2(250, 472),
		"desc": "Les vestiges hantes d'une forteresse oubliee. Un donjon pour les plus braves."},
	{"nom": "Port de Lamer", "icone": "dock", "pos": Vector2(958, 470),
		"desc": "Un port anime d'ou partent les navires vers des terres lointaines."},
	{"nom": "Phare des Brumes", "icone": "lighthouse", "pos": Vector2(1058, 378),
		"desc": "Sa lumiere perce le brouillard et guide les marins egares."},
	{"nom": "Cimetiere Oublie", "icone": "graveyard", "pos": Vector2(200, 252),
		"desc": "Un champ de pierres tombales ou les morts ne reposent pas toujours en paix."},
	{"nom": "Moulin du Val", "icone": "mill", "pos": Vector2(470, 524),
		"desc": "Un vieux moulin a vent au bord de la riviere, refuge d'un meunier bourru."},
	{"nom": "Camp du Nord", "icone": "houseViking", "pos": Vector2(650, 132),
		"desc": "Un campement de farouches guerriers du nord, allies incertains."},
]

# Routes reliant les lieux (par index).
const ROUTES := [
	[0, 1], [1, 2], [2, 3], [0, 4], [1, 8], [1, 5], [5, 6], [0, 7], [1, 9], [9, 2],
]

# Decor non interactif : icone, position, taille.
const DECOR := [
	# Chaine de montagnes au nord
	{"i": "rocksMountain", "p": Vector2(740, 150), "t": 82},
	{"i": "rocksTall", "p": Vector2(800, 135), "t": 74},
	{"i": "rocksMountain", "p": Vector2(840, 158), "t": 88},
	{"i": "rocksTall", "p": Vector2(930, 138), "t": 70},
	{"i": "rocksMountain", "p": Vector2(980, 160), "t": 84},
	{"i": "rocksMountain", "p": Vector2(1040, 150), "t": 76},
	# La grande foret de Brume (centre-ouest)
	{"i": "bush", "p": Vector2(320, 360), "t": 66},
	{"i": "bush", "p": Vector2(370, 400), "t": 72},
	{"i": "bush", "p": Vector2(300, 430), "t": 60},
	{"i": "bush", "p": Vector2(420, 370), "t": 70},
	{"i": "bush", "p": Vector2(450, 430), "t": 64},
	{"i": "bush", "p": Vector2(340, 480), "t": 68},
	{"i": "bush", "p": Vector2(290, 520), "t": 62},
	{"i": "bush", "p": Vector2(400, 510), "t": 66},
	{"i": "bush", "p": Vector2(520, 360), "t": 60},
	{"i": "bush", "p": Vector2(250, 380), "t": 58},
	# Lac et navire a l'est
	{"i": "lake", "p": Vector2(990, 548), "t": 132},
	{"i": "lakeRound", "p": Vector2(1070, 520), "t": 110},
	{"i": "ship", "p": Vector2(1010, 520), "t": 52},
	# Details
	{"i": "flag", "p": Vector2(440, 250), "t": 60},
	{"i": "fence", "p": Vector2(620, 452), "t": 64},
	{"i": "rocks", "p": Vector2(700, 470), "t": 48},
	{"i": "rocks", "p": Vector2(560, 210), "t": 44},
]

var _calligraphie: Node2D
var _lieu_courant := -1


func _ready() -> void:
	_calligraphie = $Calligraphie

	_remplir_panneau_heros()
	_dessiner_bordure_et_routes()
	_construire_decor()
	_construire_lieux()

	$BtnRetour.pressed.connect(_on_retour)
	$BtnRetour.mouse_entered.connect(Audio.play_hover)
	$PanneauInfo/BtnVoyager.pressed.connect(_on_voyager)
	$PanneauInfo/BtnVoyager.mouse_entered.connect(Audio.play_hover)


# --- Panneau du heros ------------------------------------------------------

func _remplir_panneau_heros() -> void:
	var portrait := $PanneauHeros/CadrePortrait/Portrait as TextureRect
	portrait.texture = load("res://assets/portraits/%d.png" % CharacterData.portrait_index)
	$PanneauHeros/Nom.text = CharacterData.nom
	$PanneauHeros/Classe.text = "%s %s" % [CharacterData.race_nom, CharacterData.classe_nom]


# --- Bordure + routes (Line2D) ---------------------------------------------

func _dessiner_bordure_et_routes() -> void:
	# Double bordure encrée.
	_cadre(Vector2(18, 74), Vector2(1134, 630), 3.0, ENCRE)
	_cadre(Vector2(26, 82), Vector2(1126, 622), 1.5, ENCRE_PALE)

	# Routes ondulees entre les lieux.
	for r in ROUTES:
		var a: Vector2 = LIEUX[r[0]]["pos"]
		var b: Vector2 = LIEUX[r[1]]["pos"]
		_route(a, b)


func _cadre(haut_gauche: Vector2, bas_droite: Vector2, largeur: float, couleur: Color) -> void:
	var l := Line2D.new()
	l.width = largeur
	l.default_color = couleur
	l.closed = true
	l.points = PackedVector2Array([
		haut_gauche,
		Vector2(bas_droite.x, haut_gauche.y),
		bas_droite,
		Vector2(haut_gauche.x, bas_droite.y),
	])
	_calligraphie.add_child(l)


func _route(a: Vector2, b: Vector2) -> void:
	var l := Line2D.new()
	l.width = 3.0
	l.default_color = ENCRE
	l.begin_cap_mode = Line2D.LINE_CAP_ROUND
	l.end_cap_mode = Line2D.LINE_CAP_ROUND
	l.joint_mode = Line2D.LINE_JOINT_ROUND
	# Trois points avec une legere ondulation perpendiculaire (effet trace a la main).
	var milieu := (a + b) * 0.5
	var perp := (b - a).orthogonal().normalized()
	var ondu := 14.0 * (1.0 if int(a.x + b.y) % 2 == 0 else -1.0)
	l.points = PackedVector2Array([a, milieu + perp * ondu, b])
	_calligraphie.add_child(l)


# --- Decor -----------------------------------------------------------------

func _construire_decor() -> void:
	for d in DECOR:
		var t := TextureRect.new()
		t.texture = load("res://assets/map/%s.png" % d["i"])
		t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		var taille: float = d["t"]
		t.size = Vector2(taille, taille)
		t.position = d["p"] - Vector2(taille, taille) * 0.5
		t.modulate = ENCRE
		t.mouse_filter = Control.MOUSE_FILTER_IGNORE
		$Decor.add_child(t)


# --- Lieux interactifs -----------------------------------------------------

func _construire_lieux() -> void:
	for i in LIEUX.size():
		var lieu := LIEUX[i]
		var taille := 86.0

		var bouton := TextureButton.new()
		bouton.texture_normal = load("res://assets/map/%s.png" % lieu["icone"])
		bouton.ignore_texture_size = true
		bouton.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		bouton.custom_minimum_size = Vector2(taille, taille)
		bouton.size = Vector2(taille, taille)
		bouton.position = lieu["pos"] - Vector2(taille, taille) * 0.5
		bouton.modulate = ENCRE
		bouton.pivot_offset = Vector2(taille, taille) * 0.5
		bouton.mouse_entered.connect(_survol_lieu.bind(bouton, true))
		bouton.mouse_exited.connect(_survol_lieu.bind(bouton, false))
		bouton.pressed.connect(_selectionner_lieu.bind(i))
		$Lieux.add_child(bouton)

		var etiquette := Label.new()
		etiquette.text = lieu["nom"]
		etiquette.add_theme_font_size_override("font_size", 14)
		etiquette.add_theme_color_override("font_color", ENCRE)
		etiquette.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		etiquette.size = Vector2(200, 22)
		etiquette.position = lieu["pos"] + Vector2(-100, taille * 0.5 - 6)
		etiquette.mouse_filter = Control.MOUSE_FILTER_IGNORE
		$Lieux.add_child(etiquette)


func _survol_lieu(bouton: TextureButton, entre: bool) -> void:
	if entre:
		Audio.play_hover()
	var cible := Vector2(1.18, 1.18) if entre else Vector2.ONE
	var tw := create_tween()
	tw.tween_property(bouton, "scale", cible, 0.12).set_trans(Tween.TRANS_BACK)


func _selectionner_lieu(index: int) -> void:
	Audio.play_click()
	_lieu_courant = index
	$PanneauInfo/NomLieu.text = LIEUX[index]["nom"]
	$PanneauInfo/Desc.text = LIEUX[index]["desc"]
	$PanneauInfo.visible = true


# --- Actions ---------------------------------------------------------------

func _on_voyager() -> void:
	Audio.play_click()
	if _lieu_courant >= 0:
		print("Voyage vers : ", LIEUX[_lieu_courant]["nom"])


func _on_retour() -> void:
	Audio.play_click()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
