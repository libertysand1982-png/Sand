extends Node
## Gestionnaire audio global (autoload).
## Centralise les effets sonores du jeu a partir des assets .ogg embarques.

var _hover: AudioStreamPlayer
var _click: AudioStreamPlayer
var _open: AudioStreamPlayer


func _ready() -> void:
	_hover = _make_player("res://assets/audio/rollover1.ogg", -6.0)
	_click = _make_player("res://assets/audio/click1.ogg", -2.0)
	_open = _make_player("res://assets/audio/bookOpen.ogg", -4.0)


func _make_player(path: String, volume_db: float) -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.stream = load(path)
	p.volume_db = volume_db
	p.bus = "Master"
	add_child(p)
	return p


func play_hover() -> void:
	_hover.play()


func play_click() -> void:
	_click.play()


func play_open() -> void:
	_open.play()
