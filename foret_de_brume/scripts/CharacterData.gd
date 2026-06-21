extends Node
## Donnees du personnage joueur (autoload).
## Conserve le heros cree a l'ecran de creation pour la suite du jeu.

var nom: String = "Heros"
var race_index: int = 0
var classe_index: int = 0
var portrait_index: int = 1
var chevalier_index: int = 0

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
