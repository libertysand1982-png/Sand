extends Node2D
## Carte du monde parcourable : le heros (chevalier) se balade au clavier,
## la camera le suit, et la touche E pres d'un village permet d'y entrer.

const WORLD := Vector2(2000, 1300)
const VITESSE := 240.0
const RAYON := 130.0

const TREES := ["Tree1", "Tree2", "Tree3", "Fruit_tree1", "Flower_tree1", "Moss_tree1", "Autumn_tree1"]
const ROCKS := ["Rock1_grass_shadow1", "Rock2_grass_shadow1", "Rock4_grass_shadow2",
	"Rock5_grass_shadow1", "Rock6_grass_shadow3"]
const CHAMPI := ["Black_mushrooms1_grass_shadow", "Orange_mushrooms1_grass_shadow"]

# Lieux : nom, fichier, position monde, echelle, village, description.
const LIEUX := [
	{"nom": "Bourg de Boisclair", "f": "Yurt1_grass_shadow", "p": Vector2(660, 540), "e": 1.5, "village": true,
		"desc": "Le plus grand village de la contree. Marche, taverne et forge t'y attendent."},
	{"nom": "Hameau de Valombre", "f": "Yurt2_grass_shadow", "p": Vector2(1320, 860), "e": 1.2, "village": true,
		"desc": "Un paisible hameau, repute pour ses pecheurs et ses conteurs."},
	{"nom": "Camp des Errants", "f": "Yurt1_grass_shadow", "p": Vector2(1620, 360), "e": 1.1, "village": true,
		"desc": "Un campement de nomades dresse a l'oree de la foret. On y troque de tout."},
	{"nom": "Caverne d'Ombre", "f": "Cave_entrance1_grass_shadow", "p": Vector2(1500, 230), "e": 1.3, "village": false,
		"desc": "Une bouche sombre creusee dans la roche. Un donjon dont nul n'est ressorti indemne."},
	{"nom": "Pyramide Engloutie", "f": "Stone_pyramid1_grass_shadow", "p": Vector2(1040, 300), "e": 3.0, "village": false,
		"desc": "Un monument ancien aux glyphes oublies, garde par d'antiques sortileges."},
	{"nom": "Sanctuaire de Pierre", "f": "Rock_statue_mother_grass_shadow", "p": Vector2(360, 920), "e": 0.85, "village": false,
		"desc": "Une statue maternelle erodee par les ages. On dit qu'elle exauce les voeux sinceres."},
	{"nom": "Cimetiere du Dragon", "f": "Dragon_bones_full_grass_shadow", "p": Vector2(1240, 580), "e": 0.95, "village": false,
		"desc": "Les ossements colossaux d'un dragon dechu. Un tresor doit sommeiller sous ses cotes."},
]

var _proche := -1
var _tex_idle: Texture2D
var _tex_walk: Texture2D
var _marche := false
var _frame_t := 0.0
var _facing := 1

@onready var _hero: Node2D = $Monde/Hero
@onready var _sprite: Sprite2D = $Monde/Hero/Sprite
@onready var _invite: Label = $UI/Invite
@onready var _info: NinePatchRect = $UI/PanneauInfo


func _ready() -> void:
	var n := CharacterData.chevalier_index + 1
	_tex_idle = load("res://assets/knights/knight%d_idle.png" % n)
	_tex_walk = load("res://assets/knights/knight%d_walk.png" % n)
	_sprite.texture = _tex_idle
	_sprite.hframes = 4

	$Monde/Hero/Camera2D.make_current()
	_remplir_panneau_heros()
	_construire_decor()
	_construire_lieux()
	_lancer_musique()
	$UI/BtnRetour.pressed.connect(_on_menu)


func _remplir_panneau_heros() -> void:
	($UI/PanneauHeros/CadrePortrait/Portrait as TextureRect).texture = \
		load("res://assets/portraits/%d.png" % CharacterData.portrait_index)
	$UI/PanneauHeros/Nom.text = CharacterData.nom
	$UI/PanneauHeros/Classe.text = "%s %s" % [CharacterData.race_nom, CharacterData.classe_nom]


func _lancer_musique() -> void:
	var flux := load("res://assets/terrain/music/heros_passing.mp3")
	if flux is AudioStreamMP3:
		flux.loop = true
	$Musique.stream = flux
	$Musique.volume_db = -12.0
	$Musique.play()


# --- Construction du monde -------------------------------------------------

func _ajouter(chemin: String, pos: Vector2, echelle := 1.0) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = load(chemin)
	s.position = pos
	s.scale = Vector2(echelle, echelle)
	$Monde.add_child(s)
	return s


func _trop_pres(pos: Vector2) -> bool:
	if pos.distance_to(_hero.position) < 180.0:
		return true
	if Rect2(1440, 900, 600, 400).has_point(pos):  # le lac
		return true
	for l in LIEUX:
		if pos.distance_to(l["p"]) < 150.0:
			return true
	return false


func _construire_decor() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 20260622
	for i in 70:
		var pos := Vector2(rng.randf_range(40, WORLD.x - 40), rng.randf_range(110, WORLD.y - 40))
		if _trop_pres(pos):
			continue
		_ajouter("res://assets/terrain/trees/%s.png" % TREES[rng.randi() % TREES.size()],
			pos, rng.randf_range(0.85, 1.25))
	for i in 22:
		var pos := Vector2(rng.randf_range(40, WORLD.x - 40), rng.randf_range(110, WORLD.y - 40))
		if _trop_pres(pos):
			continue
		_ajouter("res://assets/terrain/rocks/%s.png" % ROCKS[rng.randi() % ROCKS.size()],
			pos, rng.randf_range(0.8, 1.2))
	for i in 14:
		var pos := Vector2(rng.randf_range(40, WORLD.x - 40), rng.randf_range(110, WORLD.y - 40))
		if _trop_pres(pos):
			continue
		_ajouter("res://assets/terrain/objects/%s.png" % CHAMPI[rng.randi() % CHAMPI.size()], pos)


func _construire_lieux() -> void:
	for l in LIEUX:
		_ajouter("res://assets/terrain/objects/%s.png" % l["f"], l["p"], l["e"])


# --- Boucle de jeu ---------------------------------------------------------

func _process(delta: float) -> void:
	var dir := _direction()
	if dir != Vector2.ZERO:
		_hero.position += dir * VITESSE * delta
		_hero.position.x = clampf(_hero.position.x, 40, WORLD.x - 40)
		_hero.position.y = clampf(_hero.position.y, 70, WORLD.y - 40)
		if not _marche:
			_changer_anim(true)
		if dir.x < -0.1:
			_facing = -1
		elif dir.x > 0.1:
			_facing = 1
	elif _marche:
		_changer_anim(false)

	_frame_t += delta
	var periode := 0.085 if _marche else 0.18
	if _frame_t >= periode:
		_frame_t = 0.0
		_sprite.frame = (_sprite.frame + 1) % _sprite.hframes
	_sprite.flip_h = _facing < 0

	_maj_proximite()


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
	for i in LIEUX.size():
		var d: float = _hero.position.distance_to(LIEUX[i]["p"])
		if d < dmin:
			dmin = d
			meilleur = i
	if meilleur == _proche:
		return
	_proche = meilleur
	if _proche < 0:
		_invite.visible = false
		_info.visible = false
	else:
		var l: Dictionary = LIEUX[_proche]
		_invite.text = "[E] Entrer dans %s" % l["nom"] if l["village"] else "[E] Examiner %s" % l["nom"]
		_invite.visible = true
		_info.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E:
		_interagir()


func _interagir() -> void:
	if _proche < 0:
		return
	Audio.play_click()
	var l: Dictionary = LIEUX[_proche]
	if l["village"]:
		$Musique.stop()
		CharacterData.destination = l["nom"]
		get_tree().change_scene_to_file("res://scenes/Village.tscn")
	else:
		$UI/PanneauInfo/NomLieu.text = l["nom"]
		$UI/PanneauInfo/Desc.text = l["desc"]
		_invite.visible = false
		_info.visible = true


func _on_menu() -> void:
	Audio.play_click()
	$Musique.stop()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
