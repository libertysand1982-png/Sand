extends Node2D
## Carte du monde parcourable : le heros (chevalier) se balade au clavier,
## la camera le suit, et la touche E pres d'un village permet d'y entrer.

const WORLD := Vector2(1736, 2320)
const VITESSE := 240.0
const RAYON := 130.0

# Lieux : nom, fichier, position monde, echelle, village, description.
const LIEUX := [
	{"nom": "Bourg de Boisclair", "f": "Yurt1_grass_shadow", "p": Vector2(800, 1024), "e": 1.4, "village": true,
		"desc": "Le plus grand village de la contree. Marche, taverne et forge t'y attendent."},
	{"nom": "Hameau de Valombre", "f": "Yurt2_grass_shadow", "p": Vector2(400, 1360), "e": 1.2, "village": true,
		"desc": "Un paisible hameau de la cote ouest, repute pour ses pecheurs et ses conteurs."},
	{"nom": "Camp des Errants", "f": "Yurt1_grass_shadow", "p": Vector2(832, 576), "e": 1.1, "village": true,
		"desc": "Un campement de nomades dresse dans les vallees du nord. On y troque de tout."},
	{"nom": "Caverne d'Ombre", "f": "Cave_entrance1_grass_shadow", "p": Vector2(1088, 352), "e": 1.3, "village": false,
		"desc": "Une bouche sombre dans les montagnes enneigees. Un donjon dont nul n'est ressorti indemne."},
	{"nom": "Pyramide Engloutie", "f": "Stone_pyramid1_grass_shadow", "p": Vector2(1056, 1920), "e": 3.0, "village": false,
		"desc": "Un monument ancien des deserts du sud, garde par d'antiques sortileges."},
	{"nom": "Sanctuaire de Pierre", "f": "Rock_statue_mother_grass_shadow", "p": Vector2(368, 896), "e": 0.85, "village": false,
		"desc": "Une statue maternelle erodee par les ages, perdue dans les forets de l'ouest."},
	{"nom": "Cimetiere du Dragon", "f": "Dragon_bones_full_grass_shadow", "p": Vector2(1216, 896), "e": 0.95, "village": false,
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
