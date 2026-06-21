#!/usr/bin/env python3
"""
generer_foret_de_brume_v2.py
Génère tous les fichiers .gd et .tscn du jeu RPG "La Forêt de Brume" (version 2).
Version enrichie avec quêtes, inventaire, boutique, portraits et monstres supplémentaires.
"""

import os

# Créer les dossiers nécessaires
os.makedirs("scripts", exist_ok=True)
os.makedirs("assets/characters", exist_ok=True)
os.makedirs("assets/map", exist_ok=True)
os.makedirs("assets/portraits", exist_ok=True)


def ecrire(chemin, contenu):
    """Écrit un fichier avec le contenu donné."""
    with open(chemin, "w", encoding="utf-8") as f:
        f.write(contenu)
    print("  -> " + chemin + " cree")


# ============================================================
# project.godot
# ============================================================

PROJECT_GODOT = r"""[gd_resource type="ProjectSettings" format=3]

[application]

config/name="La Foret de Brume"
run/main_scene="res://MainMenu.tscn"
config/features=PackedStringArray("4.3", "Forward Plus")

[autoload]

GameState="*res://scripts/GameState.gd"

[display]

window/size/viewport_width=1152
window/size/viewport_height=648
"""


# ============================================================
# GameState.gd
# ============================================================

GAMESTATE_GD = r"""extends Node

# ---- Stats du joueur ----
var joueur_nom: String = "Heros"
var joueur_hp: int = 30
var joueur_hp_max: int = 30
var joueur_or: int = 50
var joueur_xp: int = 0
var joueur_niveau: int = 1
var joueur_atk: int = 5
var joueur_ca: int = 10

# ---- Inventaire ----
var inventaire: Array = []
# Format: {"nom": "Potion", "qte": 2, "type": "consommable", "valeur": 10}

# ---- Quetes ----
var quetes_actives: Array = []
var quetes_completees: Array = []
var kill_counts: Dictionary = {}

# Définition des quêtes
var quetes_def: Dictionary = {
	"rats_caverne": {
		"titre": "Rats dans la cave",
		"desc": "L aubergiste a un probleme de rats dans sa cave. Eliminez 3 rats.",
		"xp": 50,
		"or": 20,
		"monstre": "rat",
		"nb": 3
	},
	"patrouille": {
		"titre": "Patrouille de route",
		"desc": "Escorter un marchand jusqu au fort. Eliminez les bandits.",
		"xp": 100,
		"or": 50,
		"monstre": "bandit",
		"nb": 2
	},
	"liche": {
		"titre": "La Liche de Brume",
		"desc": "Detruire la liche cachee dans la foret de brume.",
		"xp": 500,
		"or": 200,
		"monstre": "liche",
		"nb": 1
	}
}

# ---- Monstres ----
var monstres_def: Dictionary = {
	"rat": {
		"nom": "Rat des Caves",
		"hp": 3,
		"hp_max": 3,
		"ac": 8,
		"damage_min": 1,
		"damage_max": 2,
		"xp": 10,
		"or": 0,
		"portrait": "res://assets/portraits/portrait_gobelin.png"
	},
	"araignee": {
		"nom": "Araignee Geante",
		"hp": 8,
		"hp_max": 8,
		"ac": 10,
		"damage_min": 1,
		"damage_max": 4,
		"xp": 30,
		"or": 5,
		"portrait": "res://assets/portraits/portrait_gobelin.png"
	},
	"gobelin": {
		"nom": "Gobelin",
		"hp": 8,
		"hp_max": 8,
		"ac": 11,
		"damage_min": 1,
		"damage_max": 6,
		"xp": 50,
		"or": 10,
		"portrait": "res://assets/portraits/portrait_gobelin.png"
	},
	"loup": {
		"nom": "Loup Sauvage",
		"hp": 12,
		"hp_max": 12,
		"ac": 12,
		"damage_min": 2,
		"damage_max": 8,
		"xp": 75,
		"or": 0,
		"portrait": "res://assets/portraits/portrait_gobelin.png"
	},
	"bandit": {
		"nom": "Bandit de Grand Chemin",
		"hp": 15,
		"hp_max": 15,
		"ac": 12,
		"damage_min": 1,
		"damage_max": 8,
		"xp": 100,
		"or": 25,
		"portrait": "res://assets/portraits/portrait_gobelin.png"
	},
	"squelette": {
		"nom": "Squelette Guerrier",
		"hp": 10,
		"hp_max": 10,
		"ac": 13,
		"damage_min": 1,
		"damage_max": 7,
		"xp": 80,
		"or": 5,
		"portrait": "res://assets/portraits/portrait_gobelin.png"
	},
	"ogre": {
		"nom": "Ogre Des Marais",
		"hp": 30,
		"hp_max": 30,
		"ac": 11,
		"damage_min": 2,
		"damage_max": 18,
		"xp": 200,
		"or": 40,
		"portrait": "res://assets/portraits/portrait_gobelin.png"
	},
	"liche": {
		"nom": "La Liche de Brume",
		"hp": 50,
		"hp_max": 50,
		"ac": 17,
		"damage_min": 3,
		"damage_max": 21,
		"xp": 500,
		"or": 200,
		"portrait": "res://assets/portraits/portrait_gobelin.png"
	}
}

# ---- Combat en cours ----
var monstre_actuel: String = "gobelin"
var lieu_actuel: String = "Inconnue"

# ---- Boutique items ----
var boutique_items: Array = [
	{"nom": "Potion", "prix": 10, "effet": "soin", "valeur": 5},
	{"nom": "Grande Potion", "prix": 25, "effet": "soin", "valeur": 15},
	{"nom": "Antidote", "prix": 15, "effet": "antidote", "valeur": 0},
	{"nom": "Torche", "prix": 5, "effet": "torche", "valeur": 0},
	{"nom": "Epee", "prix": 50, "effet": "atk", "valeur": 2},
	{"nom": "Bouclier", "prix": 40, "effet": "ca", "valeur": 2}
]


func _ready():
	ajouter_item("Potion", 2)


func ajouter_item(nom: String, qte: int = 1):
	for item in inventaire:
		if item["nom"] == nom:
			item["qte"] += qte
			return
	inventaire.append({"nom": nom, "qte": qte})


func retirer_item(nom: String, qte: int = 1) -> bool:
	for item in inventaire:
		if item["nom"] == nom:
			if item["qte"] >= qte:
				item["qte"] -= qte
				if item["qte"] <= 0:
					inventaire.erase(item)
				return true
			return false
	return false


func avoir_item(nom: String) -> int:
	for item in inventaire:
		if item["nom"] == nom:
			return item["qte"]
	return 0


func accepter_quete(id: String):
	if id in quetes_def and id not in quetes_actives and id not in quetes_completees:
		quetes_actives.append(id)
		print("Quete acceptee: " + quetes_def[id]["titre"])


func completer_quete(id: String):
	if id in quetes_actives:
		quetes_actives.erase(id)
		quetes_completees.append(id)
		var q = quetes_def[id]
		joueur_xp += q["xp"]
		joueur_or += q["or"]
		print("Quete completee: " + q["titre"] + " (+"+str(q["xp"])+"XP, +"+str(q["or"])+"or)")
		verifier_niveau()


func verifier_quetes():
	var a_completer: Array = []
	for id in quetes_actives:
		var q = quetes_def[id]
		if "monstre" in q and "nb" in q:
			var type_m = q["monstre"]
			var nb_requis = q["nb"]
			var kills = kill_counts.get(type_m, 0)
			if kills >= nb_requis:
				a_completer.append(id)
	for id in a_completer:
		completer_quete(id)


func enregistrer_kill(type_monstre: String):
	if type_monstre not in kill_counts:
		kill_counts[type_monstre] = 0
	kill_counts[type_monstre] += 1
	verifier_quetes()


func verifier_niveau():
	var xp_requis = joueur_niveau * 100
	if joueur_xp >= xp_requis:
		joueur_niveau += 1
		joueur_hp_max += 5
		joueur_hp = joueur_hp_max
		joueur_atk += 1
		print("Niveau " + str(joueur_niveau) + " atteint !")


func lancer_combat(type_monstre: String):
	monstre_actuel = type_monstre


func get_stats_texte() -> String:
	return ("PV: " + str(joueur_hp) + "/" + str(joueur_hp_max)
		+ "  OR: " + str(joueur_or)
		+ "  XP: " + str(joueur_xp)
		+ "  Niv: " + str(joueur_niveau))


func utiliser_potion() -> bool:
	if avoir_item("Potion") > 0:
		retirer_item("Potion")
		joueur_hp = min(joueur_hp + 5, joueur_hp_max)
		return true
	if avoir_item("Grande Potion") > 0:
		retirer_item("Grande Potion")
		joueur_hp = min(joueur_hp + 15, joueur_hp_max)
		return true
	return false
"""


# ============================================================
# MainMenu.tscn
# ============================================================

MAINMENU_TSCN = r"""[gd_scene load_steps=2 format=3 uid="uid://mainmenu"]

[ext_resource type="Script" path="res://scripts/main_menu.gd" id="1_mainmenu"]

[node name="MainMenu" type="Node2D"]
script = ExtResource("1_mainmenu")

[node name="Fond" type="ColorRect" parent="."]
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
color = Color(0.08, 0.06, 0.12, 1)

[node name="CanvasLayer" type="CanvasLayer" parent="."]

[node name="Titre" type="Label" parent="CanvasLayer"]
offset_left = 200.0
offset_top = 80.0
offset_right = 952.0
offset_bottom = 160.0
theme_override_font_sizes/font_size = 52
horizontal_alignment = 1
text = "La Foret de Brume"
modulate = Color(0.9, 0.8, 0.3, 1)

[node name="Sous_titre" type="Label" parent="CanvasLayer"]
offset_left = 300.0
offset_top = 160.0
offset_right = 852.0
offset_bottom = 210.0
theme_override_font_sizes/font_size = 22
horizontal_alignment = 1
text = "Un RPG de donjon et de quetes"
modulate = Color(0.7, 0.7, 0.8, 1)

[node name="Separateur" type="ColorRect" parent="CanvasLayer"]
offset_left = 300.0
offset_top = 220.0
offset_right = 852.0
offset_bottom = 224.0
color = Color(0.6, 0.5, 0.2, 1)

[node name="BtnCommencer" type="Button" parent="CanvasLayer"]
offset_left = 376.0
offset_top = 260.0
offset_right = 776.0
offset_bottom = 320.0
theme_override_font_sizes/font_size = 24
text = "Commencer l Aventure"

[node name="BtnQuitter" type="Button" parent="CanvasLayer"]
offset_left = 426.0
offset_top = 340.0
offset_right = 726.0
offset_bottom = 390.0
theme_override_font_sizes/font_size = 20
text = "Quitter"

[node name="LabelVersion" type="Label" parent="CanvasLayer"]
offset_left = 10.0
offset_top = 610.0
offset_right = 400.0
offset_bottom = 640.0
theme_override_font_sizes/font_size = 14
text = "v2.0 - La Foret de Brume"
modulate = Color(0.5, 0.5, 0.5, 1)
"""


# ============================================================
# main_menu.gd
# ============================================================

MAIN_MENU_GD = r"""extends Node2D

func _ready():
	$CanvasLayer/BtnCommencer.pressed.connect(_on_commencer)
	$CanvasLayer/BtnQuitter.pressed.connect(_on_quitter)


func _on_commencer():
	get_tree().change_scene_to_file("res://WorldMap.tscn")


func _on_quitter():
	get_tree().quit()
"""


# ============================================================
# WorldMap.tscn
# ============================================================

WORLDMAP_TSCN = r"""[gd_scene load_steps=3 format=3 uid="uid://worldmap"]

[ext_resource type="Script" path="res://scripts/world_map.gd" id="1_wmap"]
[ext_resource type="Texture2D" path="res://assets/map/world_map.png" id="2_wmap"]

[node name="WorldMap" type="Node2D"]
script = ExtResource("1_wmap")

[node name="CarteSprite" type="Sprite2D" parent="."]
position = Vector2(576, 324)
texture = ExtResource("2_wmap")
scale = Vector2(0.5625, 0.5625)

[node name="CanvasLayer" type="CanvasLayer" parent="."]

[node name="HUD" type="Label" parent="CanvasLayer"]
offset_left = 10.0
offset_top = 8.0
offset_right = 700.0
offset_bottom = 36.0
theme_override_font_sizes/font_size = 16
text = "PV: 30/30  OR: 50  XP: 0  Niv: 1"
modulate = Color(1, 1, 0.7, 1)

[node name="LabelLieu" type="Label" parent="CanvasLayer"]
offset_left = 350.0
offset_top = 600.0
offset_right = 800.0
offset_bottom = 640.0
theme_override_font_sizes/font_size = 18
horizontal_alignment = 1
text = ""
modulate = Color(1, 0.9, 0.5, 1)

[node name="LabelInfo" type="Label" parent="CanvasLayer"]
offset_left = 10.0
offset_top = 615.0
offset_right = 350.0
offset_bottom = 645.0
theme_override_font_sizes/font_size = 14
text = "Appuyez sur E pour entrer"
modulate = Color(0.7, 0.7, 0.7, 1)

[node name="BtnMenu" type="Button" parent="CanvasLayer"]
offset_left = 1020.0
offset_top = 8.0
offset_right = 1142.0
offset_bottom = 40.0
theme_override_font_sizes/font_size = 14
text = "Menu"
"""


# ============================================================
# world_map.gd
# ============================================================

WORLD_MAP_GD = r"""extends Node2D

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
"""


# ============================================================
# Village.tscn
# ============================================================

VILLAGE_TSCN = r"""[gd_scene load_steps=6 format=3 uid="uid://village"]

[ext_resource type="Script" path="res://scripts/village.gd" id="1_village"]
[ext_resource type="Texture2D" path="res://assets/characters/aubergiste.png" id="2_aub"]
[ext_resource type="Texture2D" path="res://assets/characters/marchand.png" id="3_marc"]
[ext_resource type="Texture2D" path="res://assets/characters/donneur_quete.png" id="4_donneur"]

[node name="Village" type="Node2D"]
script = ExtResource("1_village")

[node name="Fond" type="ColorRect" parent="."]
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
color = Color(0.35, 0.22, 0.10, 1)

[node name="CanvasLayer" type="CanvasLayer" parent="."]

[node name="TitreVillage" type="Label" parent="CanvasLayer"]
offset_left = 100.0
offset_top = 10.0
offset_right = 1052.0
offset_bottom = 55.0
theme_override_font_sizes/font_size = 36
horizontal_alignment = 1
text = "Village de Piedval"
modulate = Color(1.0, 0.85, 0.3, 1)

[node name="HUD" type="Label" parent="CanvasLayer"]
offset_left = 10.0
offset_top = 60.0
offset_right = 700.0
offset_bottom = 85.0
theme_override_font_sizes/font_size = 16
text = "PV: 30/30  OR: 50  XP: 0"
modulate = Color(1, 1, 0.7, 1)

[node name="ZonePersonnages" type="HBoxContainer" parent="CanvasLayer"]
offset_left = 50.0
offset_top = 100.0
offset_right = 1100.0
offset_bottom = 350.0
alignment = 1

[node name="ColAubergiste" type="VBoxContainer" parent="CanvasLayer/ZonePersonnages"]
custom_minimum_size = Vector2(200, 240)

[node name="BtnAubergiste" type="TextureButton" parent="CanvasLayer/ZonePersonnages/ColAubergiste"]
custom_minimum_size = Vector2(160, 160)
texture_normal = ExtResource("2_aub")
stretch_mode = 1

[node name="LabelAubergiste" type="Label" parent="CanvasLayer/ZonePersonnages/ColAubergiste"]
custom_minimum_size = Vector2(160, 30)
theme_override_font_sizes/font_size = 16
horizontal_alignment = 1
text = "Aubergiste"
modulate = Color(1, 0.9, 0.6, 1)

[node name="ColMarchand" type="VBoxContainer" parent="CanvasLayer/ZonePersonnages"]
custom_minimum_size = Vector2(200, 240)

[node name="BtnMarchand" type="TextureButton" parent="CanvasLayer/ZonePersonnages/ColMarchand"]
custom_minimum_size = Vector2(160, 160)
texture_normal = ExtResource("3_marc")
stretch_mode = 1

[node name="LabelMarchand" type="Label" parent="CanvasLayer/ZonePersonnages/ColMarchand"]
custom_minimum_size = Vector2(160, 30)
theme_override_font_sizes/font_size = 16
horizontal_alignment = 1
text = "Marchand"
modulate = Color(1, 0.9, 0.6, 1)

[node name="ColDonneur" type="VBoxContainer" parent="CanvasLayer/ZonePersonnages"]
custom_minimum_size = Vector2(200, 240)

[node name="BtnDonneur" type="TextureButton" parent="CanvasLayer/ZonePersonnages/ColDonneur"]
custom_minimum_size = Vector2(160, 160)
texture_normal = ExtResource("4_donneur")
stretch_mode = 1

[node name="LabelDonneur" type="Label" parent="CanvasLayer/ZonePersonnages/ColDonneur"]
custom_minimum_size = Vector2(160, 30)
theme_override_font_sizes/font_size = 16
horizontal_alignment = 1
text = "Donneur de Quete"
modulate = Color(1, 0.9, 0.6, 1)

[node name="PanneauDialogue" type="NinePatchRect" parent="CanvasLayer"]
offset_left = 30.0
offset_top = 360.0
offset_right = 1122.0
offset_bottom = 550.0
texture = ExtResource("2_aub")
patch_margin_left = 6
patch_margin_top = 6
patch_margin_right = 6
patch_margin_bottom = 6
modulate = Color(0.15, 0.10, 0.05, 0.95)

[node name="TexteDialogue" type="Label" parent="CanvasLayer/PanneauDialogue"]
offset_left = 20.0
offset_top = 10.0
offset_right = 1072.0
offset_bottom = 160.0
theme_override_font_sizes/font_size = 18
autowrap_mode = 3
text = "Bienvenue a Piedval, aventurier ! Parlez aux habitants pour obtenir des quetes et du materiel."

[node name="BtnContinuer" type="Button" parent="CanvasLayer"]
offset_left = 700.0
offset_top = 560.0
offset_right = 900.0
offset_bottom = 600.0
theme_override_font_sizes/font_size = 16
text = "Continuer"
modulate = Color(0.3, 0.6, 1.0, 1)

[node name="BtnAccepterQuete" type="Button" parent="CanvasLayer"]
offset_left = 450.0
offset_top = 560.0
offset_right = 700.0
offset_bottom = 600.0
theme_override_font_sizes/font_size = 16
text = "Accepter la quete"
visible = false
modulate = Color(0.3, 1.0, 0.4, 1)

[node name="BtnAcheter" type="Button" parent="CanvasLayer"]
offset_left = 450.0
offset_top = 560.0
offset_right = 700.0
offset_bottom = 600.0
theme_override_font_sizes/font_size = 16
text = "Acheter"
visible = false
modulate = Color(1.0, 0.8, 0.2, 1)

[node name="BtnRetour" type="Button" parent="CanvasLayer"]
offset_left = 30.0
offset_top = 560.0
offset_right = 200.0
offset_bottom = 600.0
theme_override_font_sizes/font_size = 16
text = "Retour"
modulate = Color(0.7, 0.7, 0.7, 1)

[node name="BtnCarteMoniale" type="Button" parent="CanvasLayer"]
offset_left = 900.0
offset_top = 560.0
offset_right = 1120.0
offset_bottom = 600.0
theme_override_font_sizes/font_size = 16
text = "Carte du Monde"
modulate = Color(0.8, 0.6, 1.0, 1)
"""


# ============================================================
# village.gd
# ============================================================

VILLAGE_GD = r"""extends Node2D

@onready var hud = $CanvasLayer/HUD
@onready var titre = $CanvasLayer/TitreVillage
@onready var texte_dialogue = $CanvasLayer/PanneauDialogue/TexteDialogue
@onready var btn_continuer = $CanvasLayer/BtnContinuer
@onready var btn_accepter = $CanvasLayer/BtnAccepterQuete
@onready var btn_acheter = $CanvasLayer/BtnAcheter
@onready var btn_retour = $CanvasLayer/BtnRetour
@onready var btn_carte = $CanvasLayer/BtnCarteMoniale

var interlocuteur: String = ""
var dialogue_etape: int = 0
var boutique_index: int = 0
var quete_en_cours: String = ""

# Dialogues par interlocuteur
var dialogues_aubergiste = [
	"Bienvenue a l Ecu Rouille ! Je suis Aldric, l aubergiste. \nPV restaures pour 10 or. Ou puis-je vous aider ?",
	"Ah, j ai justement un probleme... Des rats infestent ma cave ! \nSi vous pouviez en eliminer 3, je vous recompenserais bien.",
	"Merci d avance, aventurier ! Revenez me voir quand ce sera fait."
]

var dialogues_marchand = [
	"Bonjour voyageur ! Je suis Torban, marchand itinerant. \nJ ai de belles marchandises pour vous.",
	"Voici mon inventaire :\n- Potion (10 or, +5PV)\n- Grande Potion (25 or, +15PV)\n- Antidote (15 or)\n- Torche (5 or)\n- Epee (50 or, +2 Atk)\n- Bouclier (40 or, +2 CA)\nQue souhaitez-vous acheter ?",
	"Bonne chance dans vos aventures ! Revenez quand vous avez besoin."
]

var dialogues_donneur = [
	"Ah, un aventurier ! Je suis le Sage Ermith. \nJ ai plusieurs missions urgentes pour quelqu un de courageux.",
	"Quetes disponibles :\n1. Rats dans la cave (50 XP, 20 or)\n2. Patrouille de route (100 XP, 50 or)\n3. La Liche de Brume (500 XP, 200 or)\n\nLaquelle vous interesse ?",
	"Choisissez une quete et revenez me voir apres l avoir accomplie. Que les dieux vous protegent !"
]

var quetes_proposees = ["rats_caverne", "patrouille", "liche"]


func _ready():
	titre.text = "Village de " + GameState.lieu_actuel if GameState.lieu_actuel != "" else "Village de Piedval"
	_maj_hud()
	_afficher_accueil()

	$CanvasLayer/ZonePersonnages/ColAubergiste/BtnAubergiste.pressed.connect(_parler_aubergiste)
	$CanvasLayer/ZonePersonnages/ColMarchand/BtnMarchand.pressed.connect(_parler_marchand)
	$CanvasLayer/ZonePersonnages/ColDonneur/BtnDonneur.pressed.connect(_parler_donneur)
	btn_continuer.pressed.connect(_continuer_dialogue)
	btn_accepter.pressed.connect(_accepter_quete)
	btn_acheter.pressed.connect(_acheter_item)
	btn_retour.pressed.connect(_retour_accueil)
	btn_carte.pressed.connect(_aller_carte)


func _maj_hud():
	hud.text = GameState.get_stats_texte()


func _afficher_accueil():
	interlocuteur = ""
	dialogue_etape = 0
	texte_dialogue.text = "Bienvenue a " + titre.text + " !\nParlez aux habitants pour obtenir des quetes et du materiel."
	btn_accepter.visible = false
	btn_acheter.visible = false
	btn_continuer.visible = false


func _parler_aubergiste():
	interlocuteur = "aubergiste"
	dialogue_etape = 0
	_afficher_dialogue()


func _parler_marchand():
	interlocuteur = "marchand"
	dialogue_etape = 0
	_afficher_dialogue()


func _parler_donneur():
	interlocuteur = "donneur"
	dialogue_etape = 0
	_afficher_dialogue()


func _afficher_dialogue():
	btn_accepter.visible = false
	btn_acheter.visible = false
	btn_continuer.visible = true

	match interlocuteur:
		"aubergiste":
			var textes = dialogues_aubergiste
			if dialogue_etape < textes.size():
				texte_dialogue.text = textes[dialogue_etape]
			if dialogue_etape == 1:
				quete_en_cours = "rats_caverne"
				if "rats_caverne" not in GameState.quetes_actives and "rats_caverne" not in GameState.quetes_completees:
					btn_accepter.visible = true
					btn_continuer.visible = false
		"marchand":
			var textes = dialogues_marchand
			if dialogue_etape < textes.size():
				texte_dialogue.text = textes[dialogue_etape]
			if dialogue_etape == 1:
				btn_acheter.visible = true
				boutique_index = 0
		"donneur":
			var textes = dialogues_donneur
			if dialogue_etape < textes.size():
				texte_dialogue.text = textes[dialogue_etape]
			if dialogue_etape == 1:
				btn_accepter.visible = true
				btn_continuer.visible = false
				quete_en_cours = "liche"
				for qid in quetes_proposees:
					if qid not in GameState.quetes_actives and qid not in GameState.quetes_completees:
						quete_en_cours = qid
						break


func _continuer_dialogue():
	dialogue_etape += 1
	match interlocuteur:
		"aubergiste":
			if dialogue_etape >= dialogues_aubergiste.size():
				_afficher_accueil()
				return
		"marchand":
			if dialogue_etape >= dialogues_marchand.size():
				_afficher_accueil()
				return
		"donneur":
			if dialogue_etape >= dialogues_donneur.size():
				_afficher_accueil()
				return
	_afficher_dialogue()


func _accepter_quete():
	if quete_en_cours != "":
		GameState.accepter_quete(quete_en_cours)
		var q = GameState.quetes_def[quete_en_cours]
		texte_dialogue.text = "Quete acceptee : " + q["titre"] + "\n" + q["desc"]
		btn_accepter.visible = false
		btn_continuer.visible = true
		# Lancer le combat si la quete implique un monstre
		if "monstre" in q:
			GameState.lancer_combat(q["monstre"])
			await get_tree().create_timer(2.0).timeout
			get_tree().change_scene_to_file("res://Combat.tscn")


func _acheter_item():
	if GameState.boutique_items.is_empty():
		return
	var item = GameState.boutique_items[boutique_index % GameState.boutique_items.size()]
	if GameState.joueur_or >= item["prix"]:
		GameState.joueur_or -= item["prix"]
		GameState.ajouter_item(item["nom"])
		# Appliquer l effet immediatement si équipement
		match item["effet"]:
			"atk":
				GameState.joueur_atk += item["valeur"]
			"ca":
				GameState.joueur_ca += item["valeur"]
		texte_dialogue.text = item["nom"] + " achete pour " + str(item["prix"]) + " or !\nVous avez maintenant " + str(GameState.joueur_or) + " or."
		boutique_index += 1
	else:
		texte_dialogue.text = "Pas assez d or ! Il vous faut " + str(item["prix"]) + " or.\nVous avez " + str(GameState.joueur_or) + " or."
	_maj_hud()


func _retour_accueil():
	_afficher_accueil()


func _aller_carte():
	get_tree().change_scene_to_file("res://WorldMap.tscn")
"""


# ============================================================
# Combat.tscn
# ============================================================

COMBAT_TSCN = r"""[gd_scene load_steps=4 format=3 uid="uid://combat"]

[ext_resource type="Script" path="res://scripts/combat.gd" id="1_combat"]
[ext_resource type="Texture2D" path="res://assets/portraits/portrait_hero.png" id="2_hero_portrait"]
[ext_resource type="Texture2D" path="res://assets/portraits/portrait_gobelin.png" id="3_monstre_portrait"]

[node name="Combat" type="Node2D"]
script = ExtResource("1_combat")

[node name="Fond" type="ColorRect" parent="."]
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
color = Color(0.05, 0.03, 0.08, 1)

[node name="CanvasLayer" type="CanvasLayer" parent="."]

[node name="LabelLieu" type="Label" parent="CanvasLayer"]
offset_left = 300.0
offset_top = 8.0
offset_right = 852.0
offset_bottom = 36.0
theme_override_font_sizes/font_size = 20
horizontal_alignment = 1
text = "Combat - Foret de Brume"
modulate = Color(0.8, 0.6, 1.0, 1)

[node name="PortraitHeros" type="TextureRect" parent="CanvasLayer"]
offset_left = 30.0
offset_top = 60.0
offset_right = 190.0
offset_bottom = 220.0
texture = ExtResource("2_hero_portrait")
expand_mode = 1
stretch_mode = 6

[node name="LabelHeros" type="Label" parent="CanvasLayer"]
offset_left = 30.0
offset_top = 220.0
offset_right = 190.0
offset_bottom = 260.0
theme_override_font_sizes/font_size = 14
horizontal_alignment = 1
text = "Heros"
modulate = Color(0.5, 0.8, 1.0, 1)

[node name="PortraitMonstre" type="TextureRect" parent="CanvasLayer"]
offset_left = 962.0
offset_top = 60.0
offset_right = 1122.0
offset_bottom = 220.0
texture = ExtResource("3_monstre_portrait")
expand_mode = 1
stretch_mode = 6

[node name="LabelMonstre" type="Label" parent="CanvasLayer"]
offset_left = 962.0
offset_top = 220.0
offset_right = 1122.0
offset_bottom = 260.0
theme_override_font_sizes/font_size = 14
horizontal_alignment = 1
text = "Monstre"
modulate = Color(1.0, 0.4, 0.4, 1)

[node name="StatHeros" type="Label" parent="CanvasLayer"]
offset_left = 30.0
offset_top = 265.0
offset_right = 300.0
offset_bottom = 340.0
theme_override_font_sizes/font_size = 16
text = "PV: 30/30\nATK: 5  CA: 10"
modulate = Color(0.7, 1.0, 0.7, 1)

[node name="StatMonstre" type="Label" parent="CanvasLayer"]
offset_left = 860.0
offset_top = 265.0
offset_right = 1122.0
offset_bottom = 340.0
theme_override_font_sizes/font_size = 16
horizontal_alignment = 2
text = "PV: 8/8\nAC: 11"
modulate = Color(1.0, 0.6, 0.6, 1)

[node name="JournalCombat" type="RichTextLabel" parent="CanvasLayer"]
offset_left = 200.0
offset_top = 60.0
offset_right = 952.0
offset_bottom = 380.0
theme_override_font_sizes/font_size = 16
bbcode_enabled = true
text = "[i]Le combat commence...[/i]"

[node name="BtnAttaquer" type="Button" parent="CanvasLayer"]
offset_left = 200.0
offset_top = 400.0
offset_right = 420.0
offset_bottom = 445.0
theme_override_font_sizes/font_size = 18
text = "Attaquer"
modulate = Color(1.0, 0.3, 0.3, 1)

[node name="BtnPotion" type="Button" parent="CanvasLayer"]
offset_left = 440.0
offset_top = 400.0
offset_right = 660.0
offset_bottom = 445.0
theme_override_font_sizes/font_size = 18
text = "Potion"
modulate = Color(0.3, 1.0, 0.5, 1)

[node name="BtnFuir" type="Button" parent="CanvasLayer"]
offset_left = 680.0
offset_top = 400.0
offset_right = 900.0
offset_bottom = 445.0
theme_override_font_sizes/font_size = 18
text = "Fuir"
modulate = Color(0.7, 0.7, 0.7, 1)

[node name="BtnContinuer" type="Button" parent="CanvasLayer"]
offset_left = 426.0
offset_top = 460.0
offset_right = 726.0
offset_bottom = 505.0
theme_override_font_sizes/font_size = 18
text = "Continuer"
visible = false
modulate = Color(0.5, 0.8, 1.0, 1)

[node name="BtnRecommencer" type="Button" parent="CanvasLayer"]
offset_left = 426.0
offset_top = 515.0
offset_right = 726.0
offset_bottom = 555.0
theme_override_font_sizes/font_size = 18
text = "Retour au Menu"
visible = false
modulate = Color(0.8, 0.5, 0.5, 1)
"""


# ============================================================
# combat.gd
# ============================================================

COMBAT_GD = r"""extends Node2D

@onready var label_lieu = $CanvasLayer/LabelLieu
@onready var stat_heros = $CanvasLayer/StatHeros
@onready var stat_monstre = $CanvasLayer/StatMonstre
@onready var journal = $CanvasLayer/JournalCombat
@onready var label_monstre = $CanvasLayer/LabelMonstre
@onready var btn_attaquer = $CanvasLayer/BtnAttaquer
@onready var btn_potion = $CanvasLayer/BtnPotion
@onready var btn_fuir = $CanvasLayer/BtnFuir
@onready var btn_continuer = $CanvasLayer/BtnContinuer
@onready var btn_recommencer = $CanvasLayer/BtnRecommencer

var monstre: Dictionary = {}
var monstre_hp_actuel: int = 0
var combat_termine: bool = false
var texte_journal: String = ""


func _ready():
	var type = GameState.monstre_actuel
	if type in GameState.monstres_def:
		monstre = GameState.monstres_def[type].duplicate(true)
	else:
		monstre = GameState.monstres_def["gobelin"].duplicate(true)

	monstre_hp_actuel = monstre["hp_max"]
	label_lieu.text = "Combat - " + GameState.lieu_actuel
	label_monstre.text = monstre["nom"]

	_ajouter_journal("[color=#ffaa44]Un " + monstre["nom"] + " apparait ![/color]")
	_maj_stats()

	btn_attaquer.pressed.connect(_attaquer)
	btn_potion.pressed.connect(_utiliser_potion)
	btn_fuir.pressed.connect(_fuir)
	btn_continuer.pressed.connect(_apres_victoire)
	btn_recommencer.pressed.connect(_retour_menu)


func _attaquer():
	if combat_termine:
		return

	# Tour du joueur : jet d attaque
	var jet = randi_range(1, 20) + GameState.joueur_atk
	if jet >= monstre["ac"]:
		var degats = randi_range(1, 8) + max(0, GameState.joueur_atk - 5)
		monstre_hp_actuel -= degats
		_ajouter_journal("[color=#88ff88]Vous attaquez : " + str(degats) + " degats ![/color]")
	else:
		_ajouter_journal("[color=#aaaaaa]Votre attaque rate ! (jet:" + str(jet) + " vs CA:" + str(monstre["ac"]) + ")[/color]")

	if monstre_hp_actuel <= 0:
		_victoire()
		return

	# Tour du monstre
	var jet_m = randi_range(1, 20)
	if jet_m >= GameState.joueur_ca:
		var degats_m = randi_range(monstre["damage_min"], monstre["damage_max"])
		GameState.joueur_hp -= degats_m
		_ajouter_journal("[color=#ff6666]" + monstre["nom"] + " vous attaque : " + str(degats_m) + " degats ![/color]")
	else:
		_ajouter_journal("[color=#aaaaaa]" + monstre["nom"] + " rate ! (jet:" + str(jet_m) + " vs CA:" + str(GameState.joueur_ca) + ")[/color]")

	if GameState.joueur_hp <= 0:
		GameState.joueur_hp = 0
		_defaite()
		return

	_maj_stats()


func _utiliser_potion():
	if combat_termine:
		return
	if GameState.utiliser_potion():
		_ajouter_journal("[color=#44ff88]Vous utilisez une potion ! PV restaures.[/color]")
		_maj_stats()
	else:
		_ajouter_journal("[color=#ffaa44]Aucune potion disponible ![/color]")


func _fuir():
	if combat_termine:
		return
	var jet = randi_range(1, 20)
	if jet >= 10:
		_ajouter_journal("[color=#aaffff]Vous fuyez le combat ![/color]")
		await get_tree().create_timer(1.5).timeout
		get_tree().change_scene_to_file("res://WorldMap.tscn")
	else:
		_ajouter_journal("[color=#ff8844]Fuite impossible ! Le monstre vous bloque.[/color]")
		# Tour du monstre
		var degats_m = randi_range(monstre["damage_min"], monstre["damage_max"])
		GameState.joueur_hp -= degats_m
		_ajouter_journal("[color=#ff6666]" + monstre["nom"] + " vous frappe pendant la fuite : " + str(degats_m) + " degats ![/color]")
		if GameState.joueur_hp <= 0:
			GameState.joueur_hp = 0
			_defaite()
		_maj_stats()


func _victoire():
	combat_termine = true
	var xp = monstre["xp"]
	var or_m = monstre["or"]
	GameState.joueur_xp += xp
	GameState.joueur_or += or_m
	GameState.enregistrer_kill(GameState.monstre_actuel)
	GameState.verifier_niveau()

	_ajouter_journal("")
	_ajouter_journal("[color=#ffdd00]VICTOIRE ! " + monstre["nom"] + " vaincu ![/color]")
	_ajouter_journal("[color=#ffaa44]+" + str(xp) + " XP, +" + str(or_m) + " or[/color]")

	# Verifier si des quetes ont ete completees
	var quetes_faites = []
	for qid in GameState.quetes_actives:
		var q = GameState.quetes_def[qid]
		if "monstre" in q and q["monstre"] == GameState.monstre_actuel:
			var kills = GameState.kill_counts.get(GameState.monstre_actuel, 0)
			if kills >= q["nb"]:
				quetes_faites.append(qid)
	for qid in quetes_faites:
		var q = GameState.quetes_def[qid]
		_ajouter_journal("[color=#44ffaa]Quete completee : " + q["titre"] + " (+" + str(q["xp"]) + "XP, +" + str(q["or"]) + "or)[/color]")
		GameState.completer_quete(qid)

	btn_attaquer.visible = false
	btn_potion.visible = false
	btn_fuir.visible = false
	btn_continuer.visible = true
	_maj_stats()


func _defaite():
	combat_termine = true
	_ajouter_journal("")
	_ajouter_journal("[color=#ff3333]DEFAITE ! Vous avez ete vaincu...[/color]")
	_ajouter_journal("[color=#ffaa44]Vous vous relevez avec 1 PV.[/color]")
	GameState.joueur_hp = 1

	btn_attaquer.visible = false
	btn_potion.visible = false
	btn_fuir.visible = false
	btn_recommencer.visible = true
	_maj_stats()


func _apres_victoire():
	get_tree().change_scene_to_file("res://WorldMap.tscn")


func _retour_menu():
	get_tree().change_scene_to_file("res://WorldMap.tscn")


func _maj_stats():
	stat_heros.text = ("PV: " + str(GameState.joueur_hp) + "/" + str(GameState.joueur_hp_max)
		+ "\nATK: " + str(GameState.joueur_atk) + "  CA: " + str(GameState.joueur_ca))
	var hp_m = max(0, monstre_hp_actuel)
	stat_monstre.text = ("PV: " + str(hp_m) + "/" + str(monstre["hp_max"])
		+ "\nAC: " + str(monstre["ac"]))


func _ajouter_journal(ligne: String):
	texte_journal += ligne + "\n"
	journal.text = texte_journal
"""


# ============================================================
# ÉCRITURE DES FICHIERS
# ============================================================

def main():
    print("=== Generation des fichiers Godot 4 - La Foret de Brume v2 ===\n")

    print("Fichiers de configuration :")
    ecrire("project.godot", PROJECT_GODOT)

    print("\nScripts GDScript :")
    ecrire("scripts/GameState.gd", GAMESTATE_GD)
    ecrire("scripts/main_menu.gd", MAIN_MENU_GD)
    ecrire("scripts/world_map.gd", WORLD_MAP_GD)
    ecrire("scripts/village.gd", VILLAGE_GD)
    ecrire("scripts/combat.gd", COMBAT_GD)

    print("\nScenes .tscn :")
    ecrire("MainMenu.tscn", MAINMENU_TSCN)
    ecrire("WorldMap.tscn", WORLDMAP_TSCN)
    ecrire("Village.tscn", VILLAGE_TSCN)
    ecrire("Combat.tscn", COMBAT_TSCN)

    print()
    print("=== Generation terminee avec succes ! ===")
    print()
    print("Fichiers crees :")
    print("  project.godot")
    print("  scripts/GameState.gd    - Etat du jeu, inventaire, quetes, monstres")
    print("  scripts/main_menu.gd    - Menu principal")
    print("  scripts/world_map.gd    - Carte du monde interactive")
    print("  scripts/village.gd      - Village avec boutique et quetes")
    print("  scripts/combat.gd       - Systeme de combat D&D")
    print("  MainMenu.tscn")
    print("  WorldMap.tscn           - Carte 2048x1152")
    print("  Village.tscn            - Village avec 3 PNJ")
    print("  Combat.tscn             - Combat avec portraits")
    print()
    print("Monstres disponibles :")
    print("  rat, araignee, gobelin, loup, bandit, squelette, ogre, liche")
    print()
    print("Quetes disponibles :")
    print("  rats_caverne, patrouille, liche")
    print()
    print("Pour lancer le jeu : ouvrez le projet dans Godot 4 et appuyez sur F5")


if __name__ == "__main__":
    main()
