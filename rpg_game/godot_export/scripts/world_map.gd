extends Node2D

@onready var hero    = $Meredius
@onready var sprite  = $Meredius/Sprite2D
@onready var hud     = $CanvasLayer/HUD
@onready var village = $Village_Piedval

# Audio
@onready var snd_pas     = $AudioPas
@onready var snd_porte   = $AudioPorte

var base_scale      = 0.04
var bob_time        = 0.0
var is_moving       = false
var pres_du_village = false
var pas_timer       = 0.0

func _ready():
	if GameState.character.size() > 0:
		pass
	hero.position = Vector2(576, 324)
	_maj_hud()

	# Sons
	if snd_pas:
		snd_pas.stream = load("res://assets/audio/footstep02.ogg")
	if snd_porte:
		snd_porte.stream = load("res://assets/audio/doorOpen_1.ogg")

func _maj_hud():
	var nom    = GameState.character.get("name",   "Meredius")
	var hp     = GameState.character.get("hp",     10)
	var hp_max = GameState.character.get("max_hp", 10)
	var or_    = GameState.character.get("gold",   50)
	hud.text = "%s  |  PV: %d/%d  |  Or: %d 💰" % [nom, hp, hp_max, or_]

func _process(delta):
	var speed = 200
	var dir   = Vector2.ZERO
	if Input.is_action_pressed("ui_left"):  dir.x -= 1
	if Input.is_action_pressed("ui_right"): dir.x += 1
	if Input.is_action_pressed("ui_up"):    dir.y -= 1
	if Input.is_action_pressed("ui_down"):  dir.y += 1

	is_moving = dir != Vector2.ZERO
	hero.position += dir.normalized() * speed * delta

	# Son de pas rythmé
	if is_moving and snd_pas:
		pas_timer += delta
		if pas_timer >= 0.4:
			pas_timer = 0.0
			snd_pas.play()

	if not is_moving:
		pas_timer = 0.0

	# Orientation
	if dir.x < 0:
		sprite.flip_h = true
	elif dir.x > 0:
		sprite.flip_h = false

	# Animation rebond
	if is_moving:
		bob_time += delta * 12.0
		var bob = abs(sin(bob_time)) * 0.01
		sprite.scale      = Vector2(base_scale, base_scale + bob)
		sprite.position.y = -sin(bob_time) * 4.0
	else:
		bob_time = 0.0
		sprite.scale      = Vector2(base_scale, base_scale)
		sprite.position.y = 0

	# Détection village
	var dist = int(hero.position.distance_to(village.position))
	if dist < 800:
		if not pres_du_village:
			pres_du_village = true
			hud.text = "🏘️ Village de Piedval — [E] pour entrer"
	else:
		if pres_du_village:
			pres_du_village = false
			_maj_hud()

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			GameState.save()
			get_tree().change_scene_to_file("res://MainMenu.tscn")
		if event.keycode == KEY_E and pres_du_village:
			if snd_porte:
				snd_porte.play()
			await get_tree().create_timer(0.3).timeout
			get_tree().change_scene_to_file("res://Village.tscn")
