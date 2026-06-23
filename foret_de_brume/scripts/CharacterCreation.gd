extends Control
## Ecran de creation de personnage facon D&D.
## Portrait, race, classe, caracteristiques (achat par points), apercu chevalier.

const TEX_MOINS := preload("res://assets/ui/arrowBeige_left.png")
const TEX_PLUS := preload("res://assets/ui/arrowBeige_right.png")

const NB_PORTRAITS := 50
const KNIGHTS := [
	"res://assets/knights/knight1_idle.png",
	"res://assets/knights/knight2_idle.png",
	"res://assets/knights/knight3_idle.png",
]

# Achat par points facon D&D 5e.
const POINTS_MAX := 27
const COUT := {8: 0, 9: 1, 10: 2, 11: 3, 12: 4, 13: 5, 14: 7, 15: 9}

const STAT_ORDRE := ["Force", "Dexterite", "Constitution", "Intelligence", "Sagesse", "Charisme"]
const ABBR := {
	"Force": "FOR", "Dexterite": "DEX", "Constitution": "CON",
	"Intelligence": "INT", "Sagesse": "SAG", "Charisme": "CHA",
}

const RACES := [
	{"nom": "Humain", "bonus": {"Force": 1, "Dexterite": 1, "Constitution": 1, "Intelligence": 1, "Sagesse": 1, "Charisme": 1}},
	{"nom": "Elfe", "bonus": {"Dexterite": 2, "Intelligence": 1}},
	{"nom": "Nain", "bonus": {"Constitution": 2, "Force": 1}},
	{"nom": "Halfelin", "bonus": {"Dexterite": 2, "Charisme": 1}},
	{"nom": "Demi-Orc", "bonus": {"Force": 2, "Constitution": 1}},
	{"nom": "Tieffelin", "bonus": {"Charisme": 2, "Intelligence": 1}},
]

const CLASSES := [
	{"nom": "Guerrier", "desc": "Maitre des armes et des armures, robuste au combat rapproche."},
	{"nom": "Mage", "desc": "Manie la magie arcanique et des sortileges devastateurs."},
	{"nom": "Roublard", "desc": "Furtif et agile, expert en pieges, crochetage et attaques sournoises."},
	{"nom": "Clerc", "desc": "Servant divin qui soigne ses allies et chatie les impies."},
	{"nom": "Rodeur", "desc": "Chasseur des terres sauvages, archer et pisteur hors pair."},
	{"nom": "Paladin", "desc": "Chevalier sacre liant serments, magie et acier beni."},
	{"nom": "Barde", "desc": "Artiste charismatique melant magie, ruse et inspiration."},
	{"nom": "Barbare", "desc": "Guerrier farouche puisant sa force dans une rage primale."},
]

var _portrait_idx := 1
var _knight_idx := 0
var _race_idx := 0
var _classe_idx := 0
var _base := {}              # caracteristique -> valeur de base (8..15)
var _labels_valeur := {}     # caracteristique -> Label (total affiche)
var _labels_bonus := {}      # caracteristique -> Label (bonus racial)

var _anim_t := 0.0

@onready var _portrait: TextureRect = $PanneauGauche/CadrePortrait/Portrait
@onready var _label_portrait: Label = $PanneauGauche/LabelPortrait
@onready var _champ_nom: LineEdit = $PanneauGauche/ChampNom
@onready var _chevalier: Sprite2D = $PanneauGauche/Chevalier
@onready var _val_race: Label = $PanneauDroit/Marges/Colonne/LigneRace/Valeur
@onready var _val_classe: Label = $PanneauDroit/Marges/Colonne/LigneClasse/Valeur
@onready var _desc_classe: Label = $PanneauDroit/Marges/Colonne/DescriptionClasse
@onready var _label_points: Label = $PanneauDroit/Marges/Colonne/EnteteStats/Points
@onready var _liste_stats: VBoxContainer = $PanneauDroit/Marges/Colonne/ListeStats
@onready var _message: Label = $Message


func _ready() -> void:
	for s in STAT_ORDRE:
		_base[s] = 8

	_construire_lignes_stats()

	# Connexions des fleches portrait / chevalier.
	$PanneauGauche/FlechePortraitG.pressed.connect(func(): _changer_portrait(-1))
	$PanneauGauche/FlechePortraitD.pressed.connect(func(): _changer_portrait(1))
	$PanneauGauche/FlecheChevalierG.pressed.connect(func(): _changer_chevalier(-1))
	$PanneauGauche/FlecheChevalierD.pressed.connect(func(): _changer_chevalier(1))

	# Race / classe.
	$PanneauDroit/Marges/Colonne/LigneRace/FlecheG.pressed.connect(func(): _changer_race(-1))
	$PanneauDroit/Marges/Colonne/LigneRace/FlecheD.pressed.connect(func(): _changer_race(1))
	$PanneauDroit/Marges/Colonne/LigneClasse/FlecheG.pressed.connect(func(): _changer_classe(-1))
	$PanneauDroit/Marges/Colonne/LigneClasse/FlecheD.pressed.connect(func(): _changer_classe(1))

	# Boutons bas.
	$BtnRetour.pressed.connect(_on_retour)
	$BtnValider.pressed.connect(_on_valider)
	for b in [$BtnRetour, $BtnValider]:
		b.mouse_entered.connect(Audio.play_hover)

	_maj_portrait()
	_maj_chevalier()
	_maj_race()
	_maj_classe()
	_maj_stats()


func _process(delta: float) -> void:
	# Animation idle du chevalier (4 images).
	_anim_t += delta
	if _anim_t >= 0.18:
		_anim_t = 0.0
		_chevalier.frame = (_chevalier.frame + 1) % 4


# --- Construction des lignes de caracteristiques ---------------------------

func _construire_lignes_stats() -> void:
	for s in STAT_ORDRE:
		var ligne := HBoxContainer.new()
		ligne.add_theme_constant_override("separation", 8)

		var nom := Label.new()
		nom.text = ABBR[s]
		nom.custom_minimum_size = Vector2(130, 0)
		nom.add_theme_font_size_override("font_size", 18)
		nom.add_theme_color_override("font_color", Color(0.32, 0.22, 0.12))
		nom.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		ligne.add_child(nom)

		var moins := _fleche(TEX_MOINS)
		moins.pressed.connect(_modifier_stat.bind(s, -1))
		ligne.add_child(moins)

		var valeur := Label.new()
		valeur.custom_minimum_size = Vector2(44, 0)
		valeur.add_theme_font_size_override("font_size", 20)
		valeur.add_theme_color_override("font_color", Color(0.18, 0.11, 0.05))
		valeur.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		valeur.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		ligne.add_child(valeur)
		_labels_valeur[s] = valeur

		var plus := _fleche(TEX_PLUS)
		plus.pressed.connect(_modifier_stat.bind(s, 1))
		ligne.add_child(plus)

		var bonus := Label.new()
		bonus.custom_minimum_size = Vector2(70, 0)
		bonus.add_theme_font_size_override("font_size", 15)
		bonus.add_theme_color_override("font_color", Color(0.13, 0.42, 0.13))
		bonus.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		ligne.add_child(bonus)
		_labels_bonus[s] = bonus

		_liste_stats.add_child(ligne)


func _fleche(tex: Texture2D) -> TextureButton:
	var b := TextureButton.new()
	b.texture_normal = tex
	b.ignore_texture_size = true
	b.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	b.custom_minimum_size = Vector2(32, 32)
	b.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return b


# --- Logique des caracteristiques ------------------------------------------

func _modifier_stat(stat: String, sens: int) -> void:
	var v: int = _base[stat]
	if sens > 0:
		if v >= 15:
			return
		var cout: int = COUT[v + 1] - COUT[v]
		if _points_restants() < cout:
			return
		_base[stat] = v + 1
	else:
		if v <= 8:
			return
		_base[stat] = v - 1
	Audio.play_click()
	_maj_stats()


func _points_restants() -> int:
	var utilises := 0
	for s in STAT_ORDRE:
		utilises += COUT[_base[s]]
	return POINTS_MAX - utilises


func _bonus_race() -> Dictionary:
	return RACES[_race_idx]["bonus"]


func _maj_stats() -> void:
	var bonus := _bonus_race()
	for s in STAT_ORDRE:
		var b: int = bonus.get(s, 0)
		var total: int = _base[s] + b
		_labels_valeur[s].text = str(total)
		_labels_bonus[s].text = "(+%d)" % b if b > 0 else ""
	var reste := _points_restants()
	_label_points.text = "Points : %d" % reste
	_label_points.add_theme_color_override(
		"font_color", Color(0.13, 0.42, 0.13) if reste > 0 else Color(0.6, 0.4, 0.05))


# --- Portrait / chevalier / race / classe ----------------------------------

func _changer_portrait(sens: int) -> void:
	_portrait_idx = wrapi(_portrait_idx - 1 + sens, 0, NB_PORTRAITS) + 1
	Audio.play_hover()
	_maj_portrait()


func _maj_portrait() -> void:
	_portrait.texture = load("res://assets/portraits/%d.png" % _portrait_idx)
	_label_portrait.text = "Portrait %d / %d" % [_portrait_idx, NB_PORTRAITS]


func _changer_chevalier(sens: int) -> void:
	_knight_idx = wrapi(_knight_idx + sens, 0, KNIGHTS.size())
	Audio.play_hover()
	_maj_chevalier()


func _maj_chevalier() -> void:
	_chevalier.texture = load(KNIGHTS[_knight_idx])
	_chevalier.hframes = 4
	_chevalier.frame = 0


func _changer_race(sens: int) -> void:
	_race_idx = wrapi(_race_idx + sens, 0, RACES.size())
	Audio.play_click()
	_maj_race()
	_maj_stats()


func _maj_race() -> void:
	_val_race.text = RACES[_race_idx]["nom"]


func _changer_classe(sens: int) -> void:
	_classe_idx = wrapi(_classe_idx + sens, 0, CLASSES.size())
	Audio.play_click()
	_maj_classe()


func _maj_classe() -> void:
	_val_classe.text = CLASSES[_classe_idx]["nom"]
	_desc_classe.text = CLASSES[_classe_idx]["desc"]


# --- Validation / retour ---------------------------------------------------

func _on_retour() -> void:
	Audio.play_click()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")


func _on_valider() -> void:
	Audio.play_click()

	var nom := _champ_nom.text.strip_edges()
	CharacterData.nom = nom if nom != "" else "Heros sans nom"
	CharacterData.race_index = _race_idx
	CharacterData.classe_index = _classe_idx
	CharacterData.race_nom = RACES[_race_idx]["nom"]
	CharacterData.classe_nom = CLASSES[_classe_idx]["nom"]
	CharacterData.portrait_index = _portrait_idx
	CharacterData.chevalier_index = _knight_idx
	var bonus := _bonus_race()
	for s in STAT_ORDRE:
		CharacterData.stats[s] = _base[s] + bonus.get(s, 0)

	_message.text = "%s, %s %s, part a l'aventure !" % [
		CharacterData.nom, RACES[_race_idx]["nom"], CLASSES[_classe_idx]["nom"]]
	$BtnValider.disabled = true
	print("Personnage cree : ", CharacterData.resume(), " | stats=", CharacterData.stats)
	CharacterData.sauvegarder()
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/WorldMap.tscn")
