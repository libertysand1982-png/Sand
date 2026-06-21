extends Node2D

# Lieux de la carte (positions adaptées à l'échelle 0.5625 sur 2048x1152)
# La carte est affichée à 1152x648 -> factor = 1152/2048 = 0.5625
const SCALE = 0.5625

var lieux = [
	{"nom": "Piedval",         "x": 400, "y": 580, "scene": "res://Village.tscn",  "monstre": ""},
	{"nom": "Fort Ardenne",    "x": 800, "y": 300, "scene": "res://Village.tscn",  "monstre": ""},
	{"nom": "Marecage Noir",   "x": 300, "y": 800, "scene": "res://Combat.tscn",   "monstre": "ogre"},
	{"nom": "Ruines d Edoran", "x": 1600,"y": 750, "scene": "res://Village.tscn",  "monstre": ""},
	{"nom": "Citadelle",       "x": 1200,"y": 200, "scene": "res://Village.tscn",  "monstre": ""},
]

var lieu_proche: Dictionary = {}
var hud: Label
var label_lieu: Label


func _ready():
	hud = $CanvasLayer/HUD
	label_lieu = $CanvasLayer/LabelLieu
	$CanvasLayer/BtnMenu.pressed.connect(_on_menu)
	_maj_hud()


func _process(_delta):
	_trouver_lieu_proche()
	_maj_hud()


func _trouver_lieu_proche():
	var souris = get_global_mouse_position()
	var dist_min = 999999.0
	lieu_proche = {}
	for lieu in lieux:
		var lx = lieu["x"] * SCALE
		var ly = lieu["y"] * SCALE
		var d = souris.distance_to(Vector2(lx, ly))
		if d < dist_min:
			dist_min = d
			lieu_proche = lieu
	if dist_min < 60:
		label_lieu.text = lieu_proche["nom"] + " (E pour entrer)"
	else:
		lieu_proche = {}
		label_lieu.text = "Carte du Monde"


func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_E and not lieu_proche.is_empty():
			_entrer_lieu(lieu_proche)


func _entrer_lieu(lieu: Dictionary):
	GameState.lieu_actuel = lieu["nom"]
	if lieu["monstre"] != "":
		GameState.lancer_combat(lieu["monstre"])
		get_tree().change_scene_to_file("res://Combat.tscn")
	else:
		get_tree().change_scene_to_file(lieu["scene"])


func _maj_hud():
	hud.text = GameState.get_stats_texte()


func _on_menu():
	get_tree().change_scene_to_file("res://MainMenu.tscn")


func _draw():
	# Dessiner les marqueurs de lieux
	for lieu in lieux:
		var lx = lieu["x"] * SCALE
		var ly = lieu["y"] * SCALE
		var col = Color(1, 0.8, 0.2, 0.9)
		if lieu == lieu_proche:
			col = Color(1, 1, 0, 1)
		draw_circle(Vector2(lx, ly), 10, col)
		draw_arc(Vector2(lx, ly), 12, 0, TAU, 32, Color(0.2, 0.2, 0.2, 0.8), 2)
