extends Node
## Gestionnaire audio global (autoload).
## Centralise les effets sonores du jeu. Chaque effet peut avoir plusieurs
## variantes : on en joue une au hasard pour eviter la repetition en combat.

var _sons := {}   # nom -> Array[AudioStreamPlayer]


func _ready() -> void:
	_groupe("hover", ["rollover1.ogg"], -6.0)
	_groupe("click", ["click1.ogg"], -2.0)
	_groupe("open", ["bookOpen.ogg"], -4.0)
	# Combat : sons percutants et varies.
	_groupe("swing", ["knifeSlice.ogg", "knifeSlice2.ogg"], -4.0)        # coup d'arme (sifflement)
	_groupe("hit", ["chop.ogg", "impactMetal_heavy.ogg"], -3.0)          # l'arme touche l'ennemi
	_groupe("hurt", ["punch.wav", "blood1.wav", "blood2.wav"], -5.0)     # le heros encaisse
	_groupe("death", ["impactSoft_heavy.ogg"], -2.0)                     # chute d'un ennemi
	_groupe("magic", ["magic.ogg"], -4.0)
	_groupe("coins", ["handleCoins.ogg"], -3.0)
	_groupe("step", ["step.ogg"], -16.0)


func _groupe(nom: String, fichiers: Array, volume_db: float) -> void:
	var liste: Array = []
	for f in fichiers:
		liste.append(_make_player("res://assets/audio/%s" % f, volume_db))
	_sons[nom] = liste


func _make_player(path: String, volume_db: float) -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.stream = load(path)
	p.volume_db = volume_db
	p.bus = "Master"
	add_child(p)
	return p


func jouer(nom: String) -> void:
	if not _sons.has(nom):
		return
	var liste: Array = _sons[nom]
	if liste.is_empty():
		return
	liste[randi() % liste.size()].play()


func play_hover() -> void:
	jouer("hover")


func play_click() -> void:
	jouer("click")


func play_open() -> void:
	jouer("open")
