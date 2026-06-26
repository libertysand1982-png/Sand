extends Control
## Ecran de fin de partie : s'affiche quand le heros tombe au combat.
## Propose de reprendre a la derniere sauvegarde automatique ou de quitter.

func _ready() -> void:
	var fond := ColorRect.new()
	fond.anchor_right = 1.0
	fond.anchor_bottom = 1.0
	fond.color = Color(0.06, 0.02, 0.03, 1)
	add_child(fond)

	var font := load("res://assets/fonts/lilita_one_regular.ttf")

	var col := VBoxContainer.new()
	col.anchor_left = 0.5
	col.anchor_top = 0.5
	col.anchor_right = 0.5
	col.anchor_bottom = 0.5
	col.offset_left = -260.0
	col.offset_top = -190.0
	col.offset_right = 260.0
	col.offset_bottom = 190.0
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", 16)
	add_child(col)

	var titre := Label.new()
	titre.text = "VOUS ETES MORT"
	titre.add_theme_font_override("font", font)
	titre.add_theme_font_size_override("font_size", 56)
	titre.add_theme_color_override("font_color", Color(0.82, 0.16, 0.12))
	titre.add_theme_color_override("font_outline_color", Color(0.1, 0.02, 0.02))
	titre.add_theme_constant_override("outline_size", 8)
	titre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(titre)

	var sous := Label.new()
	sous.text = "Fin de partie"
	sous.add_theme_font_size_override("font_size", 24)
	sous.add_theme_color_override("font_color", Color(0.85, 0.8, 0.7))
	sous.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(sous)

	var info := Label.new()
	info.text = "%s, %s %s\nNiveau %d  -  %s" % [
		CharacterData.nom, CharacterData.race_nom, CharacterData.classe_nom,
		CharacterData.niveau, CharacterData.region_courante]
	info.add_theme_font_size_override("font_size", 18)
	info.add_theme_color_override("font_color", Color(0.7, 0.66, 0.6))
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(info)

	var espace := Control.new()
	espace.custom_minimum_size = Vector2(0, 20)
	col.add_child(espace)

	if CharacterData.a_sauvegarde():
		_bouton(col, font, "Reprendre (derniere sauvegarde)", _charger)
	_bouton(col, font, "Menu principal", _menu)


func _bouton(parent: Control, font: Variant, texte: String, cible: Callable) -> void:
	var b := Button.new()
	b.text = texte
	b.custom_minimum_size = Vector2(380, 48)
	b.add_theme_font_override("font", font)
	b.add_theme_font_size_override("font_size", 20)
	b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	b.pressed.connect(cible)
	b.mouse_entered.connect(Audio.play_hover)
	parent.add_child(b)


func _charger() -> void:
	Audio.play_click()
	if CharacterData.charger():
		get_tree().change_scene_to_file("res://scenes/WorldMap.tscn")


func _menu() -> void:
	Audio.play_click()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
