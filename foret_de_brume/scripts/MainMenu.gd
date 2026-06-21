extends Control
## Menu principal de "La Foret de Brume".
## Branche les sons (survol / clic) et les actions des boutons.

@onready var _panneau: Control = $Panneau
@onready var _bouton_commencer: Button = $Panneau/Marges/Colonne/BtnCommencer
@onready var _bouton_options: Button = $Panneau/Marges/Colonne/BtnOptions
@onready var _bouton_quitter: Button = $Panneau/Marges/Colonne/BtnQuitter


func _ready() -> void:
	# Son d'ouverture du menu.
	Audio.play_open()

	for bouton in [_bouton_commencer, _bouton_options, _bouton_quitter]:
		bouton.mouse_entered.connect(Audio.play_hover)
		bouton.focus_entered.connect(Audio.play_hover)

	_bouton_commencer.pressed.connect(_on_commencer)
	_bouton_options.pressed.connect(_on_options)
	_bouton_quitter.pressed.connect(_on_quitter)

	_bouton_commencer.grab_focus()

	# Petite apparition en fondu du panneau.
	_panneau.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(_panneau, "modulate:a", 1.0, 0.5)


func _on_commencer() -> void:
	Audio.play_click()
	# La carte du monde sera ajoutee a la prochaine etape.
	# get_tree().change_scene_to_file("res://scenes/WorldMap.tscn")
	print("Commencer l'aventure")


func _on_options() -> void:
	Audio.play_click()
	print("Options")


func _on_quitter() -> void:
	Audio.play_click()
	await get_tree().create_timer(0.12).timeout
	get_tree().quit()
