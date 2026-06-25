# GameManager — machine à états globale, transitions entre runs.
extends Node

signal run_started()
signal player_died()
signal game_won()
signal game_over(reason: String)

enum State { MENU, PLAYING, PAUSED, DEATH, VICTORY, GAMEOVER }

var state: State = State.MENU
var run_count := 0
var total_kills := 0

func _ready() -> void:
	GlobalTimer.expired.connect(_on_expired)

func new_game() -> void:
	GlobalTimer.reset_all()
	RunData.reset_persistent()
	run_count = 0
	total_kills = 0
	_begin_run()
	GlobalTimer.start()

func continue_after_death() -> void:
	_begin_run()
	GlobalTimer.start()

func _begin_run() -> void:
	run_count += 1
	RunData.new_run()
	state = State.PLAYING
	emit_signal("run_started")

func on_player_died(kills_this_run: int) -> void:
	total_kills += kills_this_run
	state = State.DEATH
	GlobalTimer.pause()
	emit_signal("player_died")

func on_boss_defeated() -> void:
	state = State.VICTORY
	GlobalTimer.pause()
	emit_signal("game_won")

func toggle_pause() -> void:
	if state == State.PLAYING:
		state = State.PAUSED
		GlobalTimer.pause()
		get_tree().paused = true
	elif state == State.PAUSED:
		state = State.PLAYING
		GlobalTimer.start()
		get_tree().paused = false

func _on_expired() -> void:
	if state == State.PLAYING:
		state = State.GAMEOVER
		emit_signal("game_over", "time")
