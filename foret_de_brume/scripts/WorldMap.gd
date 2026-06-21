extends Control
## Carte du monde "La Foret de Brume" en diorama isometrique medieval.
## Sol pave en losange + batiments Kenney empiles, dans une clairiere de foret.

# --- Parametres isometriques (ajustables) ---
const SCALE := 0.5
const ISO_W := 64.0           # demi-largeur du losange
const ISO_H := 32.0           # demi-hauteur du losange
const ORIGINE := Vector2(576, 250)
const ANCRE_Y := 40.0         # decalage vertical global

const TEINTE_SOL := Color(0.94, 0.92, 0.96)
const TEINTE_PIERRE := Color(0.96, 0.95, 1.0)

# Lieux interactifs : nom, cellule, recette (bas -> haut), description.
const LIEUX := [
	{"nom": "Chateau de l'Aube", "cell": Vector2(1, 0), "recette": ["stoneWallGateClosed_E"],
		"desc": "La citadelle royale, coeur du royaume et point de depart de ta quete."},
	{"nom": "Tour de Guet", "cell": Vector2(3, 0), "recette": ["stoneColumn_E"],
		"desc": "Une haute tour de pierre d'ou les sentinelles scrutent l'horizon brumeux."},
	{"nom": "Bourg de Boisclair", "cell": Vector2(0, 2), "recette": ["woodWall_E", "roofSingle_E"],
		"desc": "Un village prospere ou marchands et aubergistes accueillent les aventuriers."},
	{"nom": "Echoppe du Marchand", "cell": Vector2(2, 2), "recette": ["woodWallWindow_E", "roofSingle_E"],
		"desc": "On y troque armes, potions et babioles venues des quatre coins du monde."},
	{"nom": "Vieille Ferme", "cell": Vector2(3, 3), "recette": ["woodWallDoorClosed_E", "roof_E"],
		"desc": "Une ferme isolee tenue par un meunier bourru mais bon coeur."},
	{"nom": "Entrepot du Val", "cell": Vector2(1, 3), "recette": ["chestClosed_E"],
		"desc": "Un depot rempli de vivres et de coffres... dont certains bien gardes."},
]

# Decor isometrique non interactif : piece, cellule.
const DECOR := [
	{"piece": "stoneColumn_E", "cell": Vector2(0, 0)},
	{"piece": "stoneWallWindow_E", "cell": Vector2(2, 0)},
	{"piece": "stoneWall_E", "cell": Vector2(3, 1)},
	{"piece": "hayBales_E", "cell": Vector2(0, 3)},
	{"piece": "sack_E", "cell": Vector2(2, 3)},
]

var _lieu_courant := -1
var _sprites_lieu := {}


func _ready() -> void:
	_remplir_panneau_heros()
	_construire_sol()
	_construire_batiments()

	$BtnRetour.pressed.connect(_on_retour)
	$BtnRetour.mouse_entered.connect(Audio.play_hover)
	$PanneauInfo/BtnVoyager.pressed.connect(_on_voyager)
	$PanneauInfo/BtnVoyager.mouse_entered.connect(Audio.play_hover)


func iso(cell: Vector2) -> Vector2:
	return ORIGINE + Vector2((cell.x - cell.y) * ISO_W, (cell.x + cell.y) * ISO_H + ANCRE_Y)


# --- Panneau du heros ------------------------------------------------------

func _remplir_panneau_heros() -> void:
	var portrait := $PanneauHeros/CadrePortrait/Portrait as TextureRect
	portrait.texture = load("res://assets/portraits/%d.png" % CharacterData.portrait_index)
	$PanneauHeros/Nom.text = CharacterData.nom
	$PanneauHeros/Classe.text = "%s %s" % [CharacterData.race_nom, CharacterData.classe_nom]


# --- Construction de la scene ----------------------------------------------

func _piece(nom: String, cell: Vector2, teinte: Color) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = load("res://assets/iso/%s.png" % nom)
	s.scale = Vector2(SCALE, SCALE)
	s.position = iso(cell)
	s.modulate = teinte
	s.set_meta("base_y", s.position.y)
	$IsoMonde.add_child(s)
	return s


func _construire_sol() -> void:
	var tuiles := ["stone_E", "stoneTile_E", "dirt_E", "planks_E"]
	var cells := []
	for c in range(4):
		for r in range(4):
			cells.append(Vector2(c, r))
	cells.sort_custom(func(a, b): return (a.x + a.y) < (b.x + b.y))
	for cell in cells:
		var nom: String = tuiles[(int(cell.x) + int(cell.y)) % tuiles.size()]
		_piece(nom, cell, TEINTE_SOL)


func _construire_batiments() -> void:
	# Decor + batiments tries par profondeur (arriere -> avant).
	var entrees := []
	for d in DECOR:
		entrees.append({"depth": d["cell"].x + d["cell"].y, "kind": "decor", "data": d})
	for i in LIEUX.size():
		var l: Dictionary = LIEUX[i]
		entrees.append({"depth": l["cell"].x + l["cell"].y, "kind": "lieu", "idx": i, "data": l})
	entrees.sort_custom(func(a, b): return a["depth"] < b["depth"])

	for e in entrees:
		if e["kind"] == "decor":
			_piece(e["data"]["piece"], e["data"]["cell"], TEINTE_PIERRE)
		else:
			var l: Dictionary = e["data"]
			var sprites := []
			for p in l["recette"]:
				sprites.append(_piece(p, l["cell"], Color(1, 1, 1)))
			_sprites_lieu[e["idx"]] = sprites
			_creer_hotspot(e["idx"], l["cell"])


func _creer_hotspot(idx: int, cell: Vector2) -> void:
	var p := iso(cell)
	var b := Button.new()
	b.flat = true
	b.focus_mode = Control.FOCUS_NONE
	b.custom_minimum_size = Vector2(120, 170)
	b.size = Vector2(120, 170)
	b.position = p + Vector2(-60, -150)
	b.mouse_entered.connect(_survol.bind(idx, true))
	b.mouse_exited.connect(_survol.bind(idx, false))
	b.pressed.connect(_selectionner.bind(idx))
	$Hotspots.add_child(b)


# --- Interactions ----------------------------------------------------------

func _survol(idx: int, entre: bool) -> void:
	if entre:
		Audio.play_hover()
	var dy := -12.0 if entre else 0.0
	for s in _sprites_lieu[idx]:
		var base: float = s.get_meta("base_y")
		var tw := create_tween()
		tw.tween_property(s, "position:y", base + dy, 0.12).set_trans(Tween.TRANS_BACK)


func _selectionner(idx: int) -> void:
	Audio.play_click()
	_lieu_courant = idx
	$PanneauInfo/NomLieu.text = LIEUX[idx]["nom"]
	$PanneauInfo/Desc.text = LIEUX[idx]["desc"]
	$PanneauInfo.visible = true


func _on_voyager() -> void:
	Audio.play_click()
	if _lieu_courant >= 0:
		print("Voyage vers : ", LIEUX[_lieu_courant]["nom"])


func _on_retour() -> void:
	Audio.play_click()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
