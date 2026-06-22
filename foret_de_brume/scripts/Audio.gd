extends Node
## Gestionnaire audio global (autoload).
## Centralise les effets sonores du jeu a partir des assets .ogg embarques.

var _sons := {}


func _ready() -> void:
	_sons["hover"] = _make_player("res://assets/audio/rollover1.ogg", -6.0)
	_sons["click"] = _make_player("res://assets/audio/click1.ogg", -2.0)
	_sons["open"] = _make_player("res://assets/audio/bookOpen.ogg", -4.0)
	_sons["hit"] = _make_player("res://assets/audio/hit.ogg", -3.0)
	_sons["hurt"] = _make_player("res://assets/audio/hurt.ogg", -3.0)
	_sons["death"] = _make_player("res://assets/audio/death.ogg", -2.0)
	_sons["coins"] = _make_player("res://assets/audio/coins.ogg", -3.0)
	_sons["swing"] = _make_player("res://assets/audio/swing.ogg", -5.0)
	_sons["magic"] = _make_player("res://assets/audio/magic.ogg", -4.0)
	_sons["step"] = _make_player("res://assets/audio/step.ogg", -16.0)


func _make_player(path: String, volume_db: float) -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.stream = load(path)
	p.volume_db = volume_db
	p.bus = "Master"
	add_child(p)
	return p


func jouer(nom: String) -> void:
	if _sons.has(nom):
		_sons[nom].play()


func play_hover() -> void:
	jouer("hover")


func play_click() -> void:
	jouer("click")


func play_open() -> void:
	jouer("open")
