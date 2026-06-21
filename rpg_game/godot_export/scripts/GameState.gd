extends Node

# ---- Stats du joueur ----
var joueur_nom: String = "Heros"
var joueur_hp: int = 30
var joueur_hp_max: int = 30
var joueur_or: int = 50
var joueur_xp: int = 0
var joueur_niveau: int = 1
var joueur_atk: int = 5
var joueur_ca: int = 10

# ---- Inventaire ----
var inventaire: Array = []
# Format: {"nom": "Potion", "qte": 2, "type": "consommable", "valeur": 10}

# ---- Quetes ----
var quetes_actives: Array = []
var quetes_completees: Array = []
var kill_counts: Dictionary = {}

# Définition des quêtes
var quetes_def: Dictionary = {
	"rats_caverne": {
		"titre": "Rats dans la cave",
		"desc": "L aubergiste a un probleme de rats dans sa cave. Eliminez 3 rats.",
		"xp": 50,
		"or": 20,
		"monstre": "rat",
		"nb": 3
	},
	"patrouille": {
		"titre": "Patrouille de route",
		"desc": "Escorter un marchand jusqu au fort. Eliminez les bandits.",
		"xp": 100,
		"or": 50,
		"monstre": "bandit",
		"nb": 2
	},
	"liche": {
		"titre": "La Liche de Brume",
		"desc": "Detruire la liche cachee dans la foret de brume.",
		"xp": 500,
		"or": 200,
		"monstre": "liche",
		"nb": 1
	}
}

# ---- Monstres ----
var monstres_def: Dictionary = {
	"rat": {
		"nom": "Rat des Caves",
		"hp": 3,
		"hp_max": 3,
		"ac": 8,
		"damage_min": 1,
		"damage_max": 2,
		"xp": 10,
		"or": 0,
		"portrait": "res://assets/portraits/portrait_gobelin.png"
	},
	"araignee": {
		"nom": "Araignee Geante",
		"hp": 8,
		"hp_max": 8,
		"ac": 10,
		"damage_min": 1,
		"damage_max": 4,
		"xp": 30,
		"or": 5,
		"portrait": "res://assets/portraits/portrait_gobelin.png"
	},
	"gobelin": {
		"nom": "Gobelin",
		"hp": 8,
		"hp_max": 8,
		"ac": 11,
		"damage_min": 1,
		"damage_max": 6,
		"xp": 50,
		"or": 10,
		"portrait": "res://assets/portraits/portrait_gobelin.png"
	},
	"loup": {
		"nom": "Loup Sauvage",
		"hp": 12,
		"hp_max": 12,
		"ac": 12,
		"damage_min": 2,
		"damage_max": 8,
		"xp": 75,
		"or": 0,
		"portrait": "res://assets/portraits/portrait_gobelin.png"
	},
	"bandit": {
		"nom": "Bandit de Grand Chemin",
		"hp": 15,
		"hp_max": 15,
		"ac": 12,
		"damage_min": 1,
		"damage_max": 8,
		"xp": 100,
		"or": 25,
		"portrait": "res://assets/portraits/portrait_gobelin.png"
	},
	"squelette": {
		"nom": "Squelette Guerrier",
		"hp": 10,
		"hp_max": 10,
		"ac": 13,
		"damage_min": 1,
		"damage_max": 7,
		"xp": 80,
		"or": 5,
		"portrait": "res://assets/portraits/portrait_gobelin.png"
	},
	"ogre": {
		"nom": "Ogre Des Marais",
		"hp": 30,
		"hp_max": 30,
		"ac": 11,
		"damage_min": 2,
		"damage_max": 18,
		"xp": 200,
		"or": 40,
		"portrait": "res://assets/portraits/portrait_gobelin.png"
	},
	"liche": {
		"nom": "La Liche de Brume",
		"hp": 50,
		"hp_max": 50,
		"ac": 17,
		"damage_min": 3,
		"damage_max": 21,
		"xp": 500,
		"or": 200,
		"portrait": "res://assets/portraits/portrait_gobelin.png"
	}
}

# ---- Combat en cours ----
var monstre_actuel: String = "gobelin"
var lieu_actuel: String = "Inconnue"

# ---- Boutique items ----
var boutique_items: Array = [
	{"nom": "Potion", "prix": 10, "effet": "soin", "valeur": 5},
	{"nom": "Grande Potion", "prix": 25, "effet": "soin", "valeur": 15},
	{"nom": "Antidote", "prix": 15, "effet": "antidote", "valeur": 0},
	{"nom": "Torche", "prix": 5, "effet": "torche", "valeur": 0},
	{"nom": "Epee", "prix": 50, "effet": "atk", "valeur": 2},
	{"nom": "Bouclier", "prix": 40, "effet": "ca", "valeur": 2}
]


func _ready():
	ajouter_item("Potion", 2)


func ajouter_item(nom: String, qte: int = 1):
	for item in inventaire:
		if item["nom"] == nom:
			item["qte"] += qte
			return
	inventaire.append({"nom": nom, "qte": qte})


func retirer_item(nom: String, qte: int = 1) -> bool:
	for item in inventaire:
		if item["nom"] == nom:
			if item["qte"] >= qte:
				item["qte"] -= qte
				if item["qte"] <= 0:
					inventaire.erase(item)
				return true
			return false
	return false


func avoir_item(nom: String) -> int:
	for item in inventaire:
		if item["nom"] == nom:
			return item["qte"]
	return 0


func accepter_quete(id: String):
	if id in quetes_def and id not in quetes_actives and id not in quetes_completees:
		quetes_actives.append(id)
		print("Quete acceptee: " + quetes_def[id]["titre"])


func completer_quete(id: String):
	if id in quetes_actives:
		quetes_actives.erase(id)
		quetes_completees.append(id)
		var q = quetes_def[id]
		joueur_xp += q["xp"]
		joueur_or += q["or"]
		print("Quete completee: " + q["titre"] + " (+"+str(q["xp"])+"XP, +"+str(q["or"])+"or)")
		verifier_niveau()


func verifier_quetes():
	var a_completer: Array = []
	for id in quetes_actives:
		var q = quetes_def[id]
		if "monstre" in q and "nb" in q:
			var type_m = q["monstre"]
			var nb_requis = q["nb"]
			var kills = kill_counts.get(type_m, 0)
			if kills >= nb_requis:
				a_completer.append(id)
	for id in a_completer:
		completer_quete(id)


func enregistrer_kill(type_monstre: String):
	if type_monstre not in kill_counts:
		kill_counts[type_monstre] = 0
	kill_counts[type_monstre] += 1
	verifier_quetes()


func verifier_niveau():
	var xp_requis = joueur_niveau * 100
	if joueur_xp >= xp_requis:
		joueur_niveau += 1
		joueur_hp_max += 5
		joueur_hp = joueur_hp_max
		joueur_atk += 1
		print("Niveau " + str(joueur_niveau) + " atteint !")


func lancer_combat(type_monstre: String):
	monstre_actuel = type_monstre


func get_stats_texte() -> String:
	return ("PV: " + str(joueur_hp) + "/" + str(joueur_hp_max)
		+ "  OR: " + str(joueur_or)
		+ "  XP: " + str(joueur_xp)
		+ "  Niv: " + str(joueur_niveau))


func utiliser_potion() -> bool:
	if avoir_item("Potion") > 0:
		retirer_item("Potion")
		joueur_hp = min(joueur_hp + 5, joueur_hp_max)
		return true
	if avoir_item("Grande Potion") > 0:
		retirer_item("Grande Potion")
		joueur_hp = min(joueur_hp + 15, joueur_hp_max)
		return true
	return false
