extends Control

func _ready():
	$Button.pressed.connect(_nouvelle_partie)
	$Button2.pressed.connect(_quitter)

func _nouvelle_partie():
	get_tree().change_scene_to_file("res://WorldMap.tscn")

func _quitter():
	get_tree().quit()
