extends Node
# GameState.gd — Équivalent de engine/game.py
# Singleton : ajouter dans Projet > Paramètres > AutoLoad sous le nom "GameState"

var character: Dictionary = {}
var current_node_id: String = "start"
var active_quests: Array = []
var completed_quests: Array = []
var kill_counts: Dictionary = {}
var visited_locations: Array = []
var artifact_fragments: Array = []
var artifact_forged = null
var tutorial_done: bool = false

# Story et données chargées depuis JSON
var story: Dictionary = {}
var locations: Dictionary = {}
var monsters: Dictionary = {}
var quests: Dictionary = {}
var npcs: Dictionary = {}

func _ready():
	_load_data()

func _load_data():
	story    = _load_json("res://data/story.json")
	locations = _load_json("res://data/locations.json")
	monsters  = _load_json("res://data/monsters.json")
	quests    = _load_json("res://data/quests.json")
	npcs      = _load_json("res://data/npcs.json")

func _load_json(path: String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Cannot open: " + path)
		return {}
	var text = file.get_as_text()
	file.close()
	return JSON.parse_string(text)

func current_node() -> Dictionary:
	return story.get(current_node_id, {})

func go_to(node_id: String) -> Dictionary:
	current_node_id = node_id
	return current_node()

# ── Sauvegarde ──────────────────────────────────────
func save():
	var data = {
		"character": character,
		"current_node_id": current_node_id,
		"active_quests": active_quests,
		"completed_quests": completed_quests,
		"kill_counts": kill_counts,
		"visited_locations": visited_locations,
		"artifact_fragments": artifact_fragments,
		"artifact_forged": artifact_forged,
		"tutorial_done": tutorial_done,
	}
	var file = FileAccess.open("user://savegame.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()

func load_save() -> bool:
	if not FileAccess.file_exists("user://savegame.json"):
		return false
	var file = FileAccess.open("user://savegame.json", FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if data == null:
		return false
	character         = data.get("character", {})
	current_node_id   = data.get("current_node_id", "start")
	active_quests     = data.get("active_quests", [])
	completed_quests  = data.get("completed_quests", [])
	kill_counts       = data.get("kill_counts", {})
	visited_locations = data.get("visited_locations", [])
	artifact_fragments = data.get("artifact_fragments", [])
	artifact_forged   = data.get("artifact_forged", null)
	tutorial_done     = data.get("tutorial_done", false)
	return true
