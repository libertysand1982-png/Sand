extends Control
## Scene de village en diorama isometrique medieval (pieces Kenney).
## Batiments fermes (4 murs + toit) + sol pave + marche + garde anime.

# --- Parametres isometriques (ajustables) ---
const SCALE := 0.5
const ISO_W := 64.0
const ISO_H := 32.0
const ORIGINE := Vector2(540, 150)
const ANCRE_Y := 30.0

const SOLS := ["stone_E", "stoneTile_E", "dirt_E", "planks_E"]

# Recettes de batiments fermes (murs sur les 4 cotes + toit).
const MAISON_BOIS := ["woodWall_W", "woodWall_N", "woodWallDoorClosed_E", "woodWallWindow_S", "roof_E"]
const MAISON_PIERRE := ["stoneWall_W", "stoneWallWindow_N", "stoneWallDoorClosed_E", "stoneWall_S", "roof_N"]
const TOUR := ["stoneWallRound_W", "stoneWallRound_N", "stoneWallRound_E", "stoneWallRound_S", "roof_E"]
const PORTE := ["stoneWall_W", "stoneWall_N", "stoneWallGateOpen_E", "stoneWall_S"]

# Batiments : nom, cellule, recette, cliquable, description.
const BATIMENTS := [
	{"nom": "Taverne du Sanglier", "cell": Vector2(1, 0), "recette": MAISON_BOIS,
		"clic": true, "desc": "On y boit, on y chante, et l'aubergiste connait toutes les rumeurs du pays."},
	{"nom": "Forge de Maitre Aldric", "cell": Vector2(4, 1), "recette": MAISON_PIERRE,
		"clic": true, "desc": "Le martele du forgeron resonne jour et nuit. Armes et armures sur commande."},
	{"nom": "Echoppe du Marche", "cell": Vector2(5, 4), "recette": MAISON_PIERRE,
		"clic": true, "desc": "Potions, parchemins et babioles venues des quatre coins du royaume."},
	{"nom": "Maison", "cell": Vector2(0, 4), "recette": MAISON_BOIS, "clic": false, "desc": ""},
	{"nom": "Tour de Guet", "cell": Vector2(5, 0), "recette": TOUR,
		"clic": true, "desc": "Du haut de la tour, les sentinelles surveillent les routes brumeuses."},
	{"nom": "Porte du village", "cell": Vector2(2, 5), "recette": PORTE, "clic": false, "desc": ""},
]

# Decor isometrique : piece, cellule.
const DECOR := [
	{"piece": "sacksCrate_E", "cell": Vector2(2, 2)},
	{"piece": "hayBales_E", "cell": Vector2(3, 3)},
	{"piece": "chestClosed_E", "cell": Vector2(1, 2)},
	{"piece": "sack_E", "cell": Vector2(4, 3)},
	{"piece": "stoneColumn_E", "cell": Vector2(0, 1)},
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
	for c in range(6):
		for r in range(6):
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
	_garde.position = iso(Vector2(2.5, 3.5))
	_garde.z_index = 50
	$IsoVillage.add_child(_garde)


func _creer_hotspot(idx: int, cell: Vector2) -> void:
	var p := iso(cell)
	var b := Button.new()
	b.flat = true
	b.focus_mode = Control.FOCUS_NONE
	b.size = Vector2(130, 180)
	b.position = p + Vector2(-65, -150)
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
