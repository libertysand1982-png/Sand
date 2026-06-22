extends Node
## Donnees du personnage joueur (autoload).
## Conserve le heros cree a l'ecran de creation pour la suite du jeu.

var nom: String = "Heros"
var race_index: int = 0
var classe_index: int = 0
var race_nom: String = "Humain"
var classe_nom: String = "Guerrier"
var portrait_index: int = 1
var chevalier_index: int = 0

# Destination choisie sur la carte (nom du village a visiter)
var destination: String = "Village"

# Bourse, inventaire, equipement, quetes
var gold: int = 80
var inventaire: Array = [         # objets : {nom, icone, slot, atk, def}
	{"nom": "Hache rouillee", "icone": "res://assets/equip/rusty-axe.png", "slot": "Arme", "atk": 2, "def": 0},
	{"nom": "Armure matelassee", "icone": "res://assets/equip/padded-armor.png", "slot": "Armure", "atk": 0, "def": 2},
	{"nom": "Tome de Soin", "icone": "res://assets/items/12.png", "slot": "", "atk": 0, "def": 0},
]
var equipement: Dictionary = {"Arme": null, "Armure": null, "Casque": null, "Accessoire": null}
var quetes: Array = []            # quetes acceptees : {"nom": String, "texte": String}


func ajouter_objet(obj: Dictionary) -> void:
	inventaire.append(obj)


func equiper(obj: Dictionary) -> void:
	var slot: String = obj.get("slot", "")
	if not equipement.has(slot):
		return
	var ancien = equipement[slot]
	inventaire.erase(obj)
	equipement[slot] = obj
	if ancien != null:
		inventaire.append(ancien)


func bonus_atk() -> int:
	var t := 0
	for slot in equipement:
		if equipement[slot] != null:
			t += int(equipement[slot].get("atk", 0))
	return t


func bonus_def() -> int:
	var t := 0
	for slot in equipement:
		if equipement[slot] != null:
			t += int(equipement[slot].get("def", 0))
	return t


func possede_quete(nom: String) -> bool:
	for q in quetes:
		if q["nom"] == nom:
			return true
	return false

# Caracteristiques D&D : FOR, DEX, CON, INT, SAG, CHA
var stats: Dictionary = {
	"Force": 8,
	"Dexterite": 8,
	"Constitution": 8,
	"Intelligence": 8,
	"Sagesse": 8,
	"Charisme": 8,
}


func reinitialiser() -> void:
	nom = "Heros"
	race_index = 0
	classe_index = 0
	portrait_index = 1
	chevalier_index = 0
	for cle in stats:
		stats[cle] = 8


func resume() -> String:
	return "%s — race #%d, classe #%d, portrait #%d" % [nom, race_index, classe_index, portrait_index]
