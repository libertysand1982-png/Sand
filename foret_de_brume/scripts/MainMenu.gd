extends Control
## Menu principal de "La Foret de Brume".
## Branche les sons (survol / clic) et les actions des boutons.

@onready var _panneau: Control = $Panneau
@onready var _bouton_commencer: Button = $Panneau/Marges/Colonne/BtnCommencer
@onready var _bouton_options: Button = $Panneau/Marges/Colonne/BtnOptions
@onready var _bouton_quitter: Button = $Panneau/Marges/Colonne/BtnQuitter
@onready var _banniere_gauche: Control = $Decor/BanniereGauche
@onready var _banniere_droite: Control = $Decor/BanniereDroite
@onready var _feu: Control = $Decor/FeuDeCamp


func _ready() -> void:
	# Son d'ouverture du menu.
	Audio.play_open()

	for bouton in [_bouton_commencer, _bouton_options, _bouton_quitter]:
		bouton.mouse_entered.connect(Audio.play_hover)
		bouton.focus_entered.connect(Audio.play_hover)

	_bouton_commencer.pressed.connect(_on_commencer)
	if CharacterData.a_sauvegarde():
		_bouton_options.text = "Continuer"
		_bouton_options.pressed.connect(_on_continuer)
		_bouton_commencer.text = "Nouvelle partie"
	else:
		_bouton_options.pressed.connect(_on_options)
	_bouton_quitter.pressed.connect(_on_quitter)

	_bouton_commencer.grab_focus()

	# Petite apparition en fondu du panneau.
	_panneau.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(_panneau, "modulate:a", 1.0, 0.5)

	_animer_decor()


func _animer_decor() -> void:
	# Banderoles qui ondulent doucement (en opposition de phase).
	_balancer_banniere(_banniere_gauche, 0.06, 2.3)
	_balancer_banniere(_banniere_droite, -0.06, 2.6)

	# Feu de camp qui vacille (echelle + teinte chaude).
	_feu.pivot_offset = Vector2(64, 110)
	var feu := create_tween().set_loops()
	feu.tween_property(_feu, "scale", Vector2(1.05, 1.08), 0.45) \
		.set_trans(Tween.TRANS_SINE)
	feu.parallel().tween_property(_feu, "modulate", Color(1.0, 0.92, 0.72, 1), 0.45)
	feu.tween_property(_feu, "scale", Vector2(0.97, 0.95), 0.55) \
		.set_trans(Tween.TRANS_SINE)
	feu.parallel().tween_property(_feu, "modulate", Color(1.0, 0.82, 0.55, 1), 0.55)


func _balancer_banniere(banniere: Control, amplitude: float, duree: float) -> void:
	banniere.rotation = -amplitude
	var t := create_tween().set_loops()
	t.tween_property(banniere, "rotation", amplitude, duree) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(banniere, "rotation", -amplitude, duree) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _on_commencer() -> void:
	Audio.play_click()
	await get_tree().create_timer(0.12).timeout
	get_tree().change_scene_to_file("res://scenes/CharacterCreation.tscn")


func _on_continuer() -> void:
	Audio.play_click()
	if CharacterData.charger():
		await get_tree().create_timer(0.12).timeout
		get_tree().change_scene_to_file("res://scenes/WorldMap.tscn")


func _on_options() -> void:
	Audio.play_click()
	print("Options")


func _on_quitter() -> void:
	Audio.play_click()
	await get_tree().create_timer(0.12).timeout
	get_tree().quit()
