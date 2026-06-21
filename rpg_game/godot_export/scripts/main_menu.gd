extends Node2D

func _ready():
	$CanvasLayer/BtnCommencer.pressed.connect(_on_commencer)
	$CanvasLayer/BtnQuitter.pressed.connect(_on_quitter)


func _on_commencer():
	get_tree().change_scene_to_file("res://WorldMap.tscn")


func _on_quitter():
	get_tree().quit()
