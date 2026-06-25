# GlobalTimer — 60 minutes réels pour sauver le fils. Persiste entre les runs.
extends Node

signal time_updated(remaining: float)
signal threshold_reached(key: String)
signal expired()

const TOTAL := 3600.0

var remaining: float = TOTAL
var running := false
var _hit: Dictionary = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	if not running:
		return
	remaining = maxf(0.0, remaining - delta)
	emit_signal("time_updated", remaining)
	_check_thresholds()
	if remaining <= 0.0:
		running = false
		emit_signal("expired")

func start() -> void:
	running = true

func pause() -> void:
	running = false

func reset_all() -> void:
	remaining = TOTAL
	running = false
	_hit.clear()

func get_fmt() -> String:
	var m := int(remaining) / 60
	var s := int(remaining) % 60
	return "%02d:%02d" % [m, s]

# 0.0 = fresh, 1.0 = expired — used to scale difficulty
func urgency() -> float:
	return 1.0 - (remaining / TOTAL)

func _check_thresholds() -> void:
	var t := {
		"half": TOTAL * 0.5,
		"quarter": TOTAL * 0.25,
		"critical": TOTAL * 0.1,
		"last_minute": 60.0,
	}
	for k in t:
		if not _hit.get(k, false) and remaining <= t[k]:
			_hit[k] = true
			emit_signal("threshold_reached", k)
