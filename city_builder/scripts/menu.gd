extends Control

const GAME_SCENE := "res://scenes/main.tscn"

@export var continue_button: Button

func _ready():
	# Disable 'Continue' when there is no saved city to load.
	if continue_button:
		continue_button.disabled = not Global.has_save()

func _on_new_game_pressed():
	Audio.play("sounds/ui/click.ogg", -10)
	Global.load_save_on_start = false
	get_tree().change_scene_to_file("res://scenes/terrain_select.tscn")

func _on_continue_pressed():
	Audio.play("sounds/ui/click.ogg", -10)
	Global.load_save_on_start = true
	get_tree().change_scene_to_file(GAME_SCENE)

func _on_quit_pressed():
	Audio.play("sounds/ui/click.ogg", -10)
	get_tree().quit()
