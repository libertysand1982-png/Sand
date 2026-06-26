# Main.gd — orchestrateur : crée player + donjon, connecte tout.
extends Node2D

const SPAWN_Y := TLHDungeon.GROUND_Y - 42

var _player: TLHPlayer = null
var _dungeon: TLHDungeon = null
var _hud: TLHHud
var _intro_mode := false

func _ready() -> void:
	_hud = TLHHud.new()
	_hud.layer = 10
	add_child(_hud)
	_hud.build()

	# HUD signals → actions
	_hud.start_pressed.connect(_on_start)
	_hud.continue_pressed.connect(_on_continue)
	_hud.retry_pressed.connect(_on_retry)
	_hud.quit_pressed.connect(get_tree().quit)
	_hud.menu_principal_pressed.connect(_on_menu_principal)

	# Game events
	GameManager.run_started.connect(_build_run)
	GameManager.player_died.connect(_show_death)
	GameManager.game_won.connect(_show_victory)
	GameManager.game_over.connect(_show_gameover)

	# Timer → HUD
	GlobalTimer.time_updated.connect(_hud.update_timer)
	GlobalTimer.threshold_reached.connect(_on_threshold)
	GlobalTimer.expired.connect(func(): _hud.show_alert("TON FILS EST MORT."))

	if GameManager.auto_start:
		GameManager.auto_start = false
		_intro_mode = true
		_hud.show_hud(false)
		_hud.hide_overlays()
		_build_run()
	else:
		_hud.show_menu()
		_hud.show_hud(false)

# ── Button callbacks ──────────────────────────────────────────────────────────

func _on_start() -> void:
	GameManager.new_game()

func _on_continue() -> void:
	GameManager.continue_after_death()

func _on_retry() -> void:
	GameManager.new_game()

func _on_menu_principal() -> void:
	_teardown()
	GlobalTimer.pause()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _on_revelation() -> void:
	_hud.show_revelation()

# ── Run lifecycle ─────────────────────────────────────────────────────────────

func _build_run() -> void:
	_teardown()
	AudioManager.play_music("dungeon")

	# Player
	_player = TLHPlayer.new()
	_player.collision_layer = 1
	_player.collision_mask  = 4
	_player.global_position = Vector2(100, SPAWN_Y)
	_player.died.connect(_on_player_died)
	add_child(_player)

	# Dungeon
	_dungeon = TLHDungeon.new()
	add_child(_dungeon)  # add before build so children have a scene tree
	_dungeon.build(_player)
	_dungeon.boss_defeated.connect(_on_boss_defeated)
	_dungeon.boss_hp_changed.connect(_hud.update_boss_hp)
	_dungeon.boss_phase.connect(_hud.show_boss_phase)
	_dungeon.revelation_started.connect(_on_revelation)
	_dungeon.boss_name_changed.connect(_hud.update_boss_name)

	# Camera limits
	var total_w := int(TLHDungeon.BOSS_X) + 1700
	_player.cam.limit_left   = -50
	_player.cam.limit_right  = total_w
	_player.cam.limit_top    = -350
	_player.cam.limit_bottom = TLHDungeon.GROUND_Y + 120

	_hud.show_hud(true)
	_hud.hide_overlays()
	_hud.update_boss_hp(-1.0)

	if _intro_mode:
		_intro_mode = false
		_play_intro_descent()

func _play_intro_descent() -> void:
	_player.lock_controls()
	_player.cam.zoom   = Vector2(0.45, 0.45)
	_player.cam.offset = Vector2(0.0, -220.0)
	_hud.show_hud(false)

	# Fullscreen black overlay on its own CanvasLayer (unaffected by world zoom)
	var cl := CanvasLayer.new()
	cl.layer = 50
	add_child(cl)
	var fade := ColorRect.new()
	fade.color    = Color(0, 0, 0, 1.0)
	fade.position = Vector2.ZERO
	fade.size     = Vector2(1280, 720)
	cl.add_child(fade)

	var t := create_tween()
	# Reveal world from black (0.9 s)
	t.tween_property(fade, "color:a", 0.0, 0.9)
	# Camera descends and zooms in (3.6 s)
	t.tween_property(_player.cam, "zoom",   Vector2(1.0, 1.0), 3.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	t.parallel().tween_property(_player.cam, "offset", Vector2.ZERO, 3.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	# Brief landing pause
	t.tween_interval(0.4)
	# Unlock controls, start 60-minute timer, show HUD
	t.tween_callback(func():
		_player.unlock_controls()
		_hud.show_hud(true)
		GlobalTimer.start()
		cl.queue_free()
	)

func _teardown() -> void:
	if is_instance_valid(_dungeon):
		_dungeon.queue_free()
		_dungeon = null
	if is_instance_valid(_player):
		_player.queue_free()
		_player = null

func _on_player_died() -> void:
	var kills := _player.kills if is_instance_valid(_player) else 0
	GameManager.on_player_died(kills)

func _on_boss_defeated() -> void:
	GameManager.on_boss_defeated()

# ── Screen transitions ────────────────────────────────────────────────────────

func _show_death() -> void:
	AudioManager.stop_music(0.8)
	_hud.show_death(GlobalTimer.get_fmt(), RunData.cells)

func _show_victory() -> void:
	AudioManager.play_music("victory", 1.0)
	_hud.show_victory(GlobalTimer.get_fmt())

func _show_gameover(_reason: String) -> void:
	AudioManager.stop_music(0.8)
	_hud.show_gameover()

func _on_threshold(key: String) -> void:
	var msgs := {
		"half":        "30 minutes... le Geôlier s'impatiente.",
		"quarter":     "15 MINUTES ! Alerte dans le donjon !",
		"critical":    "⚠  6 MINUTES ! ALERTE CRITIQUE !",
		"last_minute": "UNE MINUTE. MAINTENANT.",
	}
	if msgs.has(key):
		_hud.show_alert(msgs[key])

# ── Per-frame ─────────────────────────────────────────────────────────────────

func _process(_delta: float) -> void:
	if not is_instance_valid(_player) or not is_instance_valid(_dungeon):
		return
	_hud.update_hp(_player.hp, _player.max_hp)
	_hud.update_cells(RunData.cells)
	_hud.update_boss_hp(_dungeon.get_boss_hp_pct())
