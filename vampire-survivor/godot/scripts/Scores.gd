# Scores.gd — tableau des scores persistant (user://) + dernier nom joué
# + échelle des rangs Fantasy (18 paliers : Bronze/Argent/Or I..VI).
class_name VSScores
extends RefCounted

const PATH := "user://scores.json"
const NAME_PATH := "user://lastname.txt"
const MAX := 15

# Paliers de rang (score minimal, nom, fichier d'emblème)
const RANKS := [
	{"min": 0,     "name": "Bronze I",   "icon": "rank_01_bronze"},
	{"min": 400,   "name": "Bronze II",  "icon": "rank_02_bronze"},
	{"min": 900,   "name": "Bronze III", "icon": "rank_03_bronze"},
	{"min": 1500,  "name": "Bronze IV",  "icon": "rank_04_bronze"},
	{"min": 2200,  "name": "Bronze V",   "icon": "rank_05_bronze"},
	{"min": 3000,  "name": "Bronze VI",  "icon": "rank_06_bronze"},
	{"min": 4000,  "name": "Argent I",   "icon": "rank_01_silver"},
	{"min": 5200,  "name": "Argent II",  "icon": "rank_02_silver"},
	{"min": 6500,  "name": "Argent III", "icon": "rank_03_silver"},
	{"min": 8000,  "name": "Argent IV",  "icon": "rank_04_silver"},
	{"min": 9600,  "name": "Argent V",   "icon": "rank_05_silver"},
	{"min": 11500, "name": "Argent VI",  "icon": "rank_06_silver"},
	{"min": 14000, "name": "Or I",       "icon": "rank_01_gold"},
	{"min": 17000, "name": "Or II",      "icon": "rank_02_gold"},
	{"min": 20500, "name": "Or III",     "icon": "rank_03_gold"},
	{"min": 24500, "name": "Or IV",      "icon": "rank_04_gold"},
	{"min": 29000, "name": "Or V",       "icon": "rank_05_gold"},
	{"min": 34000, "name": "Or VI",      "icon": "rank_06_gold"},
]

# Index de rang (0..17) pour un score donné.
static func rank_for(score: int) -> int:
	var idx := 0
	for i in RANKS.size():
		if score >= int(RANKS[i]["min"]):
			idx = i
	return idx

static func rank_name(idx: int) -> String:
	return RANKS[clampi(idx, 0, RANKS.size() - 1)]["name"]

static func rank_icon(idx: int) -> Texture2D:
	return load("res://assets/ui/ranks/%s.png" % RANKS[clampi(idx, 0, RANKS.size() - 1)]["icon"])

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
	entry["rank"] = rank_for(int(entry.get("score", 0)))
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
