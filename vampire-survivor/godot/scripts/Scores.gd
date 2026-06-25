# Scores.gd — tableau des scores persistant (user://) + dernier nom joué.
class_name VSScores
extends RefCounted

const PATH := "user://scores.json"
const NAME_PATH := "user://lastname.txt"
const MAX := 15

static func load_all() -> Array:
	if not FileAccess.file_exists(PATH):
		return []
	var f := FileAccess.open(PATH, FileAccess.READ)
	if f == null:
		return []
	var data = JSON.parse_string(f.get_as_text())
	return data if typeof(data) == TYPE_ARRAY else []

static func save_all(a: Array) -> void:
	var f := FileAccess.open(PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(a))

# Ajoute une entrée, trie par score décroissant, garde le top MAX. Renvoie le rang (0-based).
static func add(entry: Dictionary) -> int:
	var a := load_all()
	a.append(entry)
	a.sort_custom(func(x, y): return int(x.get("score", 0)) > int(y.get("score", 0)))
	if a.size() > MAX:
		a.resize(MAX)
	save_all(a)
	return a.find(entry)

static func last_name() -> String:
	if not FileAccess.file_exists(NAME_PATH):
		return "Héros"
	var f := FileAccess.open(NAME_PATH, FileAccess.READ)
	if f == null:
		return "Héros"
	var n := f.get_as_text().strip_edges()
	return n if n != "" else "Héros"

static func save_name(n: String) -> void:
	var f := FileAccess.open(NAME_PATH, FileAccess.WRITE)
	if f:
		f.store_string(n)
