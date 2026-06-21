extends Control
## Carte du monde "La Foret de Brume" — carte top-down peinte.
## Sol d'herbe, lac, foret, et lieux interactifs (pack terrain).

const TREES := ["Tree1", "Tree2", "Tree3", "Fruit_tree1", "Flower_tree1", "Moss_tree1", "Autumn_tree1"]
const ROCKS := ["Rock1_grass_shadow1", "Rock2_grass_shadow1", "Rock4_grass_shadow2",
	"Rock5_grass_shadow1", "Rock6_grass_shadow3"]

# Arbres en lisiere (foret encadrant la clairiere).
const FORET := [
	Vector2(60, 90), Vector2(180, 70), Vector2(300, 85), Vector2(430, 65), Vector2(560, 80),
	Vector2(690, 68), Vector2(820, 82), Vector2(950, 70), Vector2(1090, 88),
	Vector2(55, 200), Vector2(80, 320), Vector2(58, 450), Vector2(95, 560),
	Vector2(1100, 210), Vector2(1095, 340), Vector2(1115, 470),
	Vector2(250, 610), Vector2(470, 618), Vector2(430, 340), Vector2(540, 500),
]

const ROCHERS := [
	Vector2(170, 220), Vector2(700, 300), Vector2(380, 540), Vector2(820, 250), Vector2(610, 580),
]

# Champignons / petits details : fichier, position.
const DETAILS := [
	{"f": "Black_mushrooms1_grass_shadow", "p": Vector2(300, 430)},
	{"f": "Orange_mushrooms1_grass_shadow", "p": Vector2(660, 470)},
	{"f": "Rock_statue_head_grass_shadow", "p": Vector2(500, 250)},
	{"f": "Liana_bridges1_grass_shadow", "p": Vector2(905, 452)},
]

# Lieux interactifs : nom, fichier, position, echelle, description, village (entrable).
const LIEUX := [
	{"nom": "Bourg de Boisclair", "f": "Yurt1_grass_shadow", "p": Vector2(330, 310), "e": 1.4, "village": true,
		"desc": "Le plus grand village de la contree. Marche, taverne et forge t'y attendent."},
	{"nom": "Hameau de Valombre", "f": "Yurt2_grass_shadow", "p": Vector2(520, 470), "e": 1.15, "village": true,
		"desc": "Un paisible hameau au bord de l'eau, repute pour ses pecheurs et ses conteurs."},
	{"nom": "Camp des Errants", "f": "Yurt1_grass_shadow", "p": Vector2(960, 330), "e": 1.0, "village": true,
		"desc": "Un campement de nomades dresse a l'oree de la foret. On y troque de tout."},
	{"nom": "Caverne d'Ombre", "f": "Cave_entrance1_grass_shadow", "p": Vector2(880, 180), "e": 1.25,
		"desc": "Une bouche sombre creusee dans la roche. Un donjon dont nul n'est jamais ressorti indemne."},
	{"nom": "Pyramide Engloutie", "f": "Stone_pyramid1_grass_shadow", "p": Vector2(610, 175), "e": 3.0,
		"desc": "Un monument ancien aux glyphes oublies, garde par d'antiques sortileges."},
	{"nom": "Sanctuaire de Pierre", "f": "Rock_statue_mother_grass_shadow", "p": Vector2(205, 470), "e": 0.8,
		"desc": "Une statue maternelle erodee par les ages. On dit qu'elle exauce les voeux sinceres."},
	{"nom": "Cimetiere du Dragon", "f": "Dragon_bones_full_grass_shadow", "p": Vector2(745, 415), "e": 0.9,
		"desc": "Les ossements colossaux d'un dragon dechu. Un tresor doit sommeiller sous ses cotes."},
]

var _lieu_courant := -1
var _sprites_lieu := {}


func _ready() -> void:
	_remplir_panneau_heros()
	_construire_carte()
	_lancer_musique()

	$BtnRetour.pressed.connect(_on_retour)
	$BtnRetour.mouse_entered.connect(Audio.play_hover)
	$PanneauInfo/BtnVoyager.pressed.connect(_on_voyager)
	$PanneauInfo/BtnVoyager.mouse_entered.connect(Audio.play_hover)


func _remplir_panneau_heros() -> void:
	var portrait := $PanneauHeros/CadrePortrait/Portrait as TextureRect
	portrait.texture = load("res://assets/portraits/%d.png" % CharacterData.portrait_index)
	$PanneauHeros/Nom.text = CharacterData.nom
	$PanneauHeros/Classe.text = "%s %s" % [CharacterData.race_nom, CharacterData.classe_nom]


func _lancer_musique() -> void:
	var flux := load("res://assets/terrain/music/heros_passing.mp3")
	if flux is AudioStreamMP3:
		flux.loop = true
	$Musique.stream = flux
	$Musique.volume_db = -10.0
	$Musique.play()


# --- Construction de la carte ----------------------------------------------

func _sprite(chemin: String, pos: Vector2, echelle := 1.0) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = load(chemin)
	s.position = pos
	s.scale = Vector2(echelle, echelle)
	$Monde.add_child(s)
	return s


func _construire_carte() -> void:
	# Foret en lisiere.
	for i in FORET.size():
		var nom: String = TREES[i % TREES.size()]
		_sprite("res://assets/terrain/trees/%s.png" % nom, FORET[i], randf_range(0.9, 1.2))
	# Rochers.
	for i in ROCHERS.size():
		var nom: String = ROCKS[i % ROCKS.size()]
		_sprite("res://assets/terrain/rocks/%s.png" % nom, ROCHERS[i], randf_range(0.9, 1.3))
	# Details (champignons, statue tete, pont).
	for d in DETAILS:
		_sprite("res://assets/terrain/objects/%s.png" % d["f"], d["p"])
	# Lieux interactifs.
	for i in LIEUX.size():
		var l: Dictionary = LIEUX[i]
		var s := _sprite("res://assets/terrain/objects/%s.png" % l["f"], l["p"], l["e"])
		_sprites_lieu[i] = s
		var taille: Vector2 = s.texture.get_size() * float(l["e"])
		_creer_hotspot(i, l["p"], taille)


func _creer_hotspot(idx: int, pos: Vector2, taille: Vector2) -> void:
	var w: float = max(taille.x, 70.0)
	var h: float = max(taille.y, 70.0)
	var b := Button.new()
	b.flat = true
	b.focus_mode = Control.FOCUS_NONE
	b.size = Vector2(w, h)
	b.position = pos - Vector2(w, h) * 0.5
	b.mouse_entered.connect(_survol.bind(idx, true))
	b.mouse_exited.connect(_survol.bind(idx, false))
	b.pressed.connect(_selectionner.bind(idx))
	$Hotspots.add_child(b)


# --- Interactions ----------------------------------------------------------

func _survol(idx: int, entre: bool) -> void:
	if entre:
		Audio.play_hover()
	var s: Sprite2D = _sprites_lieu[idx]
	var base: float = float(LIEUX[idx]["e"])
	var cible := Vector2(base, base) * (1.12 if entre else 1.0)
	var tw := create_tween()
	tw.tween_property(s, "scale", cible, 0.12).set_trans(Tween.TRANS_BACK)


func _selectionner(idx: int) -> void:
	Audio.play_click()
	_lieu_courant = idx
	$PanneauInfo/NomLieu.text = LIEUX[idx]["nom"]
	$PanneauInfo/Desc.text = LIEUX[idx]["desc"]
	$PanneauInfo/BtnVoyager.text = "Entrer dans le village" if LIEUX[idx].get("village", false) else "S'y rendre"
	$PanneauInfo.visible = true


func _on_voyager() -> void:
	Audio.play_click()
	if _lieu_courant < 0:
		return
	var lieu: Dictionary = LIEUX[_lieu_courant]
	if lieu.get("village", false):
		$Musique.stop()
		CharacterData.destination = lieu["nom"]
		get_tree().change_scene_to_file("res://scenes/Village.tscn")
	else:
		print("Voyage vers : ", lieu["nom"])


func _on_retour() -> void:
	Audio.play_click()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
