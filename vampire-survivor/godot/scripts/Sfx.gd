# Sfx.gd — petit gestionnaire de sons avec un pool de lecteurs (voix multiples).
class_name VSSfx
extends Node

var streams: Dictionary = {}
var players: Array[AudioStreamPlayer] = []
var idx: int = 0
var muted: bool = false

const FILES := {
	"slice":  "res://assets/audio/knifeSlice.ogg",
	"slice2": "res://assets/audio/knifeSlice2.ogg",
	"coins":  "res://assets/audio/handleCoins.ogg",
	"hit":    "res://assets/audio/metalClick.ogg",
	"step":   "res://assets/audio/footstep00.ogg",
	"click":  "res://assets/audio/click1.ogg",
	"hurt":   "res://assets/audio/drawKnife1.ogg",
}

func _ready() -> void:
	for key in FILES:
		var s = load(FILES[key])
		if s == null:
			continue   # fichier non importé : on ignore ce son sans planter
		# Les .ogg sont importés en boucle par défaut : on coupe ça pour les SFX.
		if s is AudioStreamOggVorbis:
			s.loop = false
		streams[key] = s
	for i in 16:
		var p := AudioStreamPlayer.new()
		add_child(p)
		players.append(p)

func play(name: String, volume: float = 1.0) -> void:
	if muted:
		return
	if not streams.has(name):
		return
	var p := players[idx]
	idx = (idx + 1) % players.size()
	p.stream = streams[name]
	p.volume_db = linear_to_db(clampf(volume, 0.0001, 1.0))
	p.play()
