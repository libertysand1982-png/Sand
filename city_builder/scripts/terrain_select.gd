extends Control

const GAME_SCENE := "res://scenes/main.tscn"

@export var card_container: HBoxContainer

func _ready():
	# Build one selectable card per biome defined in Global.TERRAINS
	for id in Global.TERRAINS.keys():
		var data: Dictionary = Global.TERRAINS[id]

		var card := VBoxContainer.new()
		card.custom_minimum_size = Vector2(180, 220)
		card.add_theme_constant_override("separation", 12)

		# Color swatch previewing the ground
		var swatch := ColorRect.new()
		swatch.color = data["ground"]
		swatch.custom_minimum_size = Vector2(180, 140)
		card.add_child(swatch)

		# Button labelled with the biome name
		var button := Button.new()
		button.text = data["name"]
		button.custom_minimum_size = Vector2(180, 56)
		button.pressed.connect(_on_terrain_chosen.bind(id))
		card.add_child(button)

		card_container.add_child(card)

func _on_terrain_chosen(id: String):
	Audio.play("sounds/ui/click.ogg", -10)
	Global.terrain_id = id
	Global.load_save_on_start = false
	get_tree().change_scene_to_file(GAME_SCENE)

func _on_back_pressed():
	Audio.play("sounds/ui/click.ogg", -10)
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
