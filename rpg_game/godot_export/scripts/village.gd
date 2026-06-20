extends Node2D

var etape     = 0
var or_joueur = 50
var nom       = "Meredius"
var hp        = 10
var hp_max    = 10

@onready var texte   = $CanvasLayer/Texte
@onready var bouton1 = $CanvasLayer/Bouton1
@onready var bouton2 = $CanvasLayer/Bouton2
@onready var label1  = $CanvasLayer/Bouton1/Label
@onready var label2  = $CanvasLayer/Bouton2/Label

func _ready():
	# Récupère les stats depuis GameState
	if GameState.character.size() > 0:
		nom       = GameState.character.get("name",  "Meredius")
		hp        = GameState.character.get("hp",    10)
		hp_max    = GameState.character.get("max_hp", 10)
		or_joueur = GameState.character.get("gold",  50)
	_afficher_etape(0)

func _afficher_etape(e):
	etape = e
	match e:
		0:
			texte.text = "Vous entrez dans le village de Piedval.\nL'air sent la fumée et le pain chaud.\n\nLa taverne 'L'Écu Rouillé' se dresse devant vous."
			label1.text = "Entrer dans la taverne"
			label2.text = "Quitter le village"
		1:
			texte.text = "L'aubergiste, un homme corpulent aux yeux fatigués, essuie ses verres sans vous regarder.\n\n'On n'est plus tranquilles depuis des semaines... Les gens disparaissent la nuit. Les vieux disent que c'est la Liche de la Forêt de Brume qui se réveille.\nMoi j'dis rien... mais j'barricade ma porte le soir.'"
			label1.text = "En savoir plus"
			label2.text = "Remercier et partir"
		2:
			texte.text = "'En savoir plus?' Il baisse la voix.\n\n'Y'a des rituels anciens qui se font la nuit dans la forêt. Des lumières bleues. Un sceau brisé selon le vieux druide... Faites attention à vous.'\n\nSoudain — une main agile plonge dans votre bourse.\nUn gamin détale vers la ruelle!"
			label1.text = "Poursuivre le voleur !"
			label2.text = "Laisser faire..."
		3:
			texte.text = "Vous rattrapez le gamin dans une ruelle sombre.\nIl se retourne, un couteau à la main, tremblant.\n\n'Laissez-moi partir ou je crie !'\n\n💰 Vous avez perdu %d pièces d'or." % or_joueur
			or_joueur = 0
			label1.text = "⚔️  Attaquer (Combat)"
			label2.text = "🗣️  Persuader (Charisme)"
		4:
			texte.text = "Vous dégainez votre arme.\nLe gamin, pris de panique, lâche la bourse et s'enfuit en courant.\n\n✅ Vous récupérez vos 50 pièces d'or !"
			or_joueur = 50
			label1.text = "Retourner à la carte"
			label2.text = ""
		5:
			texte.text = "'Écoute... je sais que tu as faim.\nGarde 10 pièces et rends-moi le reste.'\n\nLe gamin hésite... puis tend la bourse.\n'Vous êtes pas comme les autres...'\nIl disparaît dans l'ombre.\n\n✅ Vous récupérez 40 pièces d'or."
			or_joueur = 40
			label1.text = "Retourner à la carte"
			label2.text = ""
		6:
			texte.text = "Vous regardez le gamin disparaître avec votre bourse.\n\n'C'est la vie...' soupirez-vous.\n\n❌ Vous avez perdu 50 pièces d'or."
			or_joueur = 0
			label1.text = "Retourner à la carte"
			label2.text = ""
		7: # Boutique
			texte.text = "🛒 MARCHAND DE PIEDVAL\n\nVotre or : %d 💰\n\n[1] Potion de soin (+5 PV) — 10 or\n[2] Épée courte (+2 att) — 25 or\n[3] Bouclier (+1 CA) — 15 or" % or_joueur
			label1.text = "Acheter potion (10 or)"
			label2.text = "Quitter la boutique"
		8:
			if or_joueur >= 10:
				or_joueur -= 10
				hp = min(hp + 5, hp_max)
				texte.text = "✅ Vous achetez une potion de soin.\nPV restaurés : %d/%d\nOr restant : %d 💰" % [hp, hp_max, or_joueur]
			else:
				texte.text = "❌ Vous n'avez pas assez d'or !\nIl vous faut 10 pièces."
			label1.text = "Retourner à la boutique"
			label2.text = "Quitter"

	bouton2.visible = label2.text != ""
	_sauvegarder_stats()

func _on_bouton1_pressed():
	match etape:
		0: _afficher_etape(1)
		1: _afficher_etape(2)
		2: _afficher_etape(3)
		3: _afficher_etape(4)  # Combat — voleur fuit
		4: _retour_carte()
		5: _retour_carte()
		6: _retour_carte()
		7: _afficher_etape(8)  # Acheter potion
		8: _afficher_etape(7)  # Retour boutique

func _on_bouton2_pressed():
	match etape:
		0: _retour_carte()
		1: _retour_carte()
		2: _afficher_etape(6)  # Laisser faire
		3: _afficher_etape(5)  # Persuader
		7: _retour_carte()
		8: _retour_carte()

func _retour_carte():
	_sauvegarder_stats()
	get_tree().change_scene_to_file("res://WorldMap.tscn")

func _sauvegarder_stats():
	GameState.character["name"]   = nom
	GameState.character["hp"]     = hp
	GameState.character["max_hp"] = hp_max
	GameState.character["gold"]   = or_joueur

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			_retour_carte()
