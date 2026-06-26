# Sfx.gd — sons (pool de voix) + musique de fond + réglages de volume.
class_name VSSfx
extends Node

var sfx_streams: Dictionary = {}
var players: Array[AudioStreamPlayer] = []
var idx: int = 0
var muted: bool = false
var sfx_volume: float = 0.85
var music_volume: float = 0.55
var music: AudioStreamPlayer

const FILES := {
	"slice":  "res://assets/audio/knifeSlice.ogg",
	"slice2": "res://assets/audio/knifeSlice2.ogg",
	"magic":  "res://assets/audio/magic.ogg",
	"hit":    "res://assets/audio/hit.ogg",
	"coins":  "res://assets/audio/coins.ogg",
	"death":  "res://assets/audio/death.ogg",
	"step":   "res://assets/audio/footstep00.ogg",
	"click":  "res://assets/audio/click1.ogg",
	"hurt":   "res://assets/audio/drawKnife1.ogg",
}

func _ready() -> void:
	for key in FILES:
		var s = load(FILES[key])
		if s == null:
			continue
		if s is AudioStreamOggVorbis:
			s.loop = false
		sfx_streams[key] = s
	for i in 18:
		var p := AudioStreamPlayer.new()
		add_child(p)
		players.append(p)
	music = AudioStreamPlayer.new()
	add_child(music)
	var m = load("res://assets/audio/battle.mp3")
	if m is AudioStreamMP3:
		m.loop = true
	music.stream = m
	_apply_music_volume()

func play(name: String, volume: float = 1.0) -> void:
	if muted:
		return
	if not sfx_streams.has(name):
		return
	var p := players[idx]
	idx = (idx + 1) % players.size()
	p.stream = sfx_streams[name]
	p.volume_db = linear_to_db(clampf(volume * sfx_volume, 0.0001, 1.0))
	p.play()

func start_music() -> void:
	if music and music.stream and not music.playing:
		music.play()

func stop_music() -> void:
	if music:
		music.stop()

func _apply_music_volume() -> void:
	if music:
		var v := 0.0001 if muted else music_volume
		music.volume_db = linear_to_db(clampf(v, 0.0001, 1.0))

func set_music_volume(v: float) -> void:
	music_volume = v
	_apply_music_volume()

func set_sfx_volume(v: float) -> void:
	sfx_volume = v

func set_muted(m: bool) -> void:
	muted = m
	_apply_music_volume()
