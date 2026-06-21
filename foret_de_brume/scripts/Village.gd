extends Control
## Scene de village en diorama isometrique medieval (pieces Kenney).
## Sol pave + maisons (mur + toit), marche, portail, garde anime.

# --- Parametres isometriques (ajustables) ---
const SCALE := 0.52
const ISO_W := 66.0           # demi-largeur du losange
const ISO_H := 33.0           # demi-hauteur du losange
const ORIGINE := Vector2(576, 250)
const ANCRE_Y := 30.0

const SOLS := ["stone_E", "stoneTile_E", "dirt_E", "planks_E"]

# Batiments : nom, cellule, recette (bas -> haut), cliquable, description.
const BATIMENTS := [
	{"nom": "Taverne du Sanglier", "cell": Vector2(0, 0), "recette": ["woodWall_E", "roofSingleWall_E"],
		"clic": true, "desc": "On y boit, on y chante, et l'aubergiste connait toutes les rumeurs du pays."},
	{"nom": "Forge de Maitre Aldric", "cell": Vector2(2, 0), "recette": ["stoneWall_E", "roof_E"],
		"clic": true, "desc": "Le martele du forgeron resonne jour et nuit. Armes et armures sur commande."},
	{"nom": "Echoppe du Marche", "cell": Vector2(4, 2), "recette": ["stoneWallWindow_E", "roof_E"],
		"clic": true, "desc": "Potions, parchemins et babioles venues des quatre coins du royaume."},
	{"nom": "Maison", "cell": Vector2(4, 0), "recette": ["woodWallWindow_E", "roofSingle_E"], "clic": false, "desc": ""},
	{"nom": "Maison", "cell": Vector2(0, 2), "recette": ["woodWallDoorClosed_E", "roofSingleWall_E"], "clic": false, "desc": ""},
	{"nom": "Porte du village", "cell": Vector2(2, 4), "recette": ["stoneWallGateOpen_E"], "clic": false, "desc": ""},
]

# Decor isometrique : piece, cellule.
const DECOR := [
	{"piece": "stoneColumn_E", "cell": Vector2(4, 4)},
	{"piece": "sacksCrate_E", "cell": Vector2(2, 2)},
	{"piece": "hayBales_E", "cell": Vector2(1, 3)},
	{"piece": "chestClosed_E", "cell": Vector2(3, 3)},
	{"piece": "sack_E", "cell": Vector2(1, 1)},
]

var _garde: Sprite2D
var _anim_t := 0.0
var _sprites_bat := {}


func _ready() -> void:
	$Titre.text = CharacterData.destination
	_construire_sol()
	_construire_village()
	_ajouter_garde()
	$BtnRetour.pressed.connect(_on_retour)
	$BtnRetour.mouse_entered.connect(Audio.play_hover)


func _process(delta: float) -> void:
	if _garde:
		_anim_t += delta
		if _anim_t >= 0.18:
			_anim_t = 0.0
			_garde.frame = (_garde.frame + 1) % 4


func iso(cell: Vector2) -> Vector2:
	return ORIGINE + Vector2((cell.x - cell.y) * ISO_W, (cell.x + cell.y) * ISO_H + ANCRE_Y)


func _piece(nom: String, cell: Vector2) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = load("res://assets/iso/%s.png" % nom)
	s.scale = Vector2(SCALE, SCALE)
	s.position = iso(cell)
	s.set_meta("base_y", s.position.y)
	$IsoVillage.add_child(s)
	return s


func _construire_sol() -> void:
	for c in range(5):
		for r in range(5):
			_piece(SOLS[(c + r) % SOLS.size()], Vector2(c, r))


func _construire_village() -> void:
	for d in DECOR:
		_piece(d["piece"], d["cell"])
	for i in BATIMENTS.size():
		var b: Dictionary = BATIMENTS[i]
		var sprites := []
		for p in b["recette"]:
			sprites.append(_piece(p, b["cell"]))
		_sprites_bat[i] = sprites
		if b.get("clic", false):
			_creer_hotspot(i, b["cell"])


func _ajouter_garde() -> void:
	_garde = Sprite2D.new()
	_garde.texture = load("res://assets/knights/knight%d_idle.png" % (CharacterData.chevalier_index + 1))
	_garde.hframes = 4
	_garde.scale = Vector2(1.6, 1.6)
	_garde.position = iso(Vector2(2, 2)) + Vector2(0, 10)
	$IsoVillage.add_child(_garde)


func _creer_hotspot(idx: int, cell: Vector2) -> void:
	var p := iso(cell)
	var b := Button.new()
	b.flat = true
	b.focus_mode = Control.FOCUS_NONE
	b.size = Vector2(130, 180)
	b.position = p + Vector2(-65, -160)
	b.mouse_entered.connect(_survol.bind(idx, true))
	b.mouse_exited.connect(_survol.bind(idx, false))
	b.pressed.connect(_selectionner.bind(idx))
	$Hotspots.add_child(b)


func _survol(idx: int, entre: bool) -> void:
	if entre:
		Audio.play_hover()
	var dy := -12.0 if entre else 0.0
	for s in _sprites_bat[idx]:
		var base: float = s.get_meta("base_y")
		var tw := create_tween()
		tw.tween_property(s, "position:y", base + dy, 0.12).set_trans(Tween.TRANS_BACK)


func _selectionner(idx: int) -> void:
	Audio.play_click()
	$PanneauInfo/NomLieu.text = BATIMENTS[idx]["nom"]
	$PanneauInfo/Desc.text = BATIMENTS[idx]["desc"]
	$PanneauInfo.visible = true


func _on_retour() -> void:
	Audio.play_click()
	get_tree().change_scene_to_file("res://scenes/WorldMap.tscn")
