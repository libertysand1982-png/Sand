extends Control

# In-game pause overlay. Pauses the scene tree while shown so building stops.

var builder

func setup(b):
	builder = b

func open():
	visible = true
	get_tree().paused = true

func close():
	get_tree().paused = false
	visible = false

func _unhandled_input(event):
	# Escape toggles the pause menu (handled here so it works while paused)
	if event.is_action_pressed("ui_cancel"):
		if visible:
			close()
		else:
			open()
		get_viewport().set_input_as_handled()

func _on_resume_pressed():
	Audio.play("sounds/ui/click.ogg", -10)
	close()

func _on_save_pressed():
	Audio.play("sounds/ui/coins.ogg", -12)
	if builder and builder.has_method("save_map"):
		builder.save_map()

func _on_menu_pressed():
	Audio.play("sounds/ui/click.ogg", -10)
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_quit_pressed():
	Audio.play("sounds/ui/click.ogg", -10)
	get_tree().quit()
