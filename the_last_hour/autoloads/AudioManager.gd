# AudioManager.gd — gestionnaire audio centralisé.
# Musique avec fondu, pool de 8 canaux SFX simultanés.
# Chaque fichier est optionnel : silencieux si absent, aucun crash.
#
# Structure attendue :
#   assets/audio/music/  ← pistes .ogg (activer Loop dans l'import Godot)
#   assets/audio/sfx/    ← effets .ogg ou .wav
extends Node

# ── Chemins ─────────────────────────────────────────────────────────────────────

const MUSIC_PATHS: Dictionary = {
	"menu":    "res://assets/audio/music/menu.ogg",
	"dungeon": "res://assets/audio/music/dungeon.ogg",
	"boss":    "res://assets/audio/music/boss.ogg",
	"mother":  "res://assets/audio/music/mother.ogg",
	"victory": "res://assets/audio/music/victory.ogg",
}

const SFX_PATHS: Dictionary = {
	# Joueur
	"player_jump":    "res://assets/audio/sfx/player_jump.ogg",
	"player_dash":    "res://assets/audio/sfx/player_dash.ogg",
	"player_hurt":    "res://assets/audio/sfx/player_hurt.ogg",
	# Mêlée
	"sword_swing":    "res://assets/audio/sfx/sword_swing.ogg",
	"sword_finisher": "res://assets/audio/sfx/sword_finisher.ogg",
	"sword_hit":      "res://assets/audio/sfx/sword_hit.ogg",
	# Couteaux & flèches
	"knife_throw":    "res://assets/audio/sfx/knife_throw.ogg",
	"knife_hit":      "res://assets/audio/sfx/knife_hit.ogg",
	"arrow_shot":     "res://assets/audio/sfx/arrow_shot.ogg",
	# Ennemis
	"enemy_hurt":     "res://assets/audio/sfx/enemy_hurt.ogg",
	"enemy_death":    "res://assets/audio/sfx/enemy_death.ogg",
	# Boss – Le Geôlier
	"boss_roar":      "res://assets/audio/sfx/boss_roar.ogg",
	"boss_charge":    "res://assets/audio/sfx/boss_charge.ogg",
	"boss_slam":      "res://assets/audio/sfx/boss_slam.ogg",
	"boss_burst":     "res://assets/audio/sfx/boss_burst.ogg",
	# Boss – La Mère
	"mother_appear":  "res://assets/audio/sfx/mother_appear.ogg",
	"mother_drain":   "res://assets/audio/sfx/mother_drain.ogg",
	"mother_bats":    "res://assets/audio/sfx/mother_bats.ogg",
	"mother_shadow":  "res://assets/audio/sfx/mother_shadow.ogg",
	# Donjon & interface
	"scroll_pickup":  "res://assets/audio/sfx/scroll_pickup.ogg",
	"door_open":      "res://assets/audio/sfx/door_open.ogg",
	"alert":          "res://assets/audio/sfx/alert.ogg",
	"revelation":     "res://assets/audio/sfx/revelation.ogg",
	"menu_hover":     "res://assets/audio/sfx/menu_hover.ogg",
	"menu_click":     "res://assets/audio/sfx/menu_click.ogg",
}

const MUSIC_VOL_DB  := -8.0
const SFX_POOL_SIZE := 8

var _music: AudioStreamPlayer
var _sfx_pool: Array[AudioStreamPlayer] = []
var _sfx_idx  := 0
var _cur_music := ""
var _cache: Dictionary = {}

# ── Init ────────────────────────────────────────────────────────────────────────

func _ready() -> void:
	_music = _make_player(MUSIC_VOL_DB)
	for _i in SFX_POOL_SIZE:
		_sfx_pool.append(_make_player(0.0))

func _make_player(vol: float) -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.volume_db = vol
	add_child(p)
	return p

# ── Public API ──────────────────────────────────────────────────────────────────

## Démarre une musique avec fondu enchaîné. Ignoré si déjà la piste courante.
func play_music(track: String, fade_dur: float = 1.5) -> void:
	if track == _cur_music: return
	var path: String = MUSIC_PATHS.get(track, "")
	if path.is_empty() or not ResourceLoader.exists(path): return
	var stream := _load(path)
	if not stream: return
	_cur_music = track
	if not _music.playing:
		_music.stream = stream
		_music.volume_db = MUSIC_VOL_DB
		_music.play()
	else:
		# Fondu sortant puis entrant
		var t := create_tween()
		t.tween_property(_music, "volume_db", -80.0, fade_dur * 0.45)
		t.tween_callback(func():
			_music.stream = stream
			_music.volume_db = -80.0
			_music.play()
			var t2 := create_tween()
			t2.tween_property(_music, "volume_db", MUSIC_VOL_DB, fade_dur * 0.55)
		)

## Arrête la musique avec fondu.
func stop_music(fade_dur: float = 0.9) -> void:
	if not _music.playing: return
	_cur_music = ""
	var t := create_tween()
	t.tween_property(_music, "volume_db", -80.0, fade_dur)
	t.tween_callback(_music.stop)

## Joue un effet sonore. volume_db : offset en dB (0 = plein), pitch : hauteur de base (±3.5% aléatoire ajouté).
func play_sfx(key: String, volume_db: float = 0.0, pitch: float = 1.0) -> void:
	var path: String = SFX_PATHS.get(key, "")
	if path.is_empty() or not ResourceLoader.exists(path): return
	var stream := _load(path)
	if not stream: return
	var p: AudioStreamPlayer = _sfx_pool[_sfx_idx]
	_sfx_idx = (_sfx_idx + 1) % SFX_POOL_SIZE
	p.stream = stream
	p.volume_db = volume_db
	p.pitch_scale = pitch + randf_range(-0.035, 0.035)
	p.play()

## Réglage global volume musique (en dB).
func set_music_vol(db: float) -> void:
	_music.volume_db = db

# ── Cache interne ───────────────────────────────────────────────────────────────

func _load(path: String) -> AudioStream:
	if _cache.has(path): return _cache[path]
	var s := load(path) as AudioStream
	if s: _cache[path] = s
	return s
