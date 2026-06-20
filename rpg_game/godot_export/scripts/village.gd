extends Node2D

var etape     = 0
var or_joueur = 50
var hp        = 10
var hp_max    = 10
var nom       = "Meredius"

@onready var texte   = $CanvasLayer/Panneau/Texte
@onready var bouton1 = $CanvasLayer/Bouton1
@onready var bouton2 = $CanvasLayer/Bouton2
@onready var label1  = $CanvasLayer/Bouton1/Label
@onready var label2  = $CanvasLayer/Bouton2/Label
@onready var hud     = $CanvasLayer/HUD

# Audio
@onready var snd_livre   = $AudioLivre
@onready var snd_click   = $AudioClick
@onready var snd_couteau = $AudioCouteau
@onready var snd_pieces  = $AudioPieces
@onready var snd_porte   = $AudioPorte

func _ready():
	nom       = GameState.character.get("name",    "Meredius")
	hp        = GameState.character.get("hp",       10)
	hp_max    = GameState.character.get("max_hp",   10)
	or_joueur = GameState.character.get("gold",     50)

	# Chargement sons
	if snd_livre:   snd_livre.stream   = load("res://assets/audio/bookOpen.ogg")
	if snd_click:   snd_click.stream   = load("res://assets/audio/click1.ogg")
	if snd_couteau: snd_couteau.stream = load("res://assets/audio/drawKnife1.ogg")
	if snd_pieces:  snd_pieces.stream  = load("res://assets/audio/handleCoins.ogg")
	if snd_porte:   snd_porte.stream   = load("res://assets/audio/doorClose_1.ogg")

	_maj_hud()
	_afficher_etape(0)

func _maj_hud():
	if hud:
		hud.text = "%s  |  PV: %d/%d  |  Or: %d 💰" % [nom, hp, hp_max, or_joueur]

func _jouer_son(snd):
	if snd:
		snd.play()

func _afficher_etape(e):
	etape = e
	match e:
		0:
			_jouer_son(snd_porte)
			texte.text = "Vous entrez dans le village de Piedval.\nL'air sent la fumée et le pain chaud.\n\nLa taverne 'L'Écu Rouillé' se dresse devant vous,\nses volets de bois peints en rouge délavé."
			label1.text = "🍺  Entrer dans la taverne"
			label2.text = "🚪  Quitter le village"
		1:
			_jouer_son(snd_livre)
			texte.text = "L'aubergiste, un homme corpulent aux yeux fatigués,\nessuie ses verres sans vous regarder.\n\n« On n'est plus tranquilles depuis des semaines...\nLes gens disparaissent la nuit. Les vieux disent\nque c'est la Liche de la Forêt de Brume qui se réveille.\nMoi j'dis rien... mais j'barricade ma porte le soir. »"
			label1.text = "🔍  En savoir plus"
			label2.text = "🙏  Remercier et partir"
		2:
			_jouer_son(snd_livre)
			texte.text = "« En savoir plus ? » Il baisse la voix.\n\n« Y'a des rituels anciens la nuit dans la forêt.\nDes lumières bleues. Un sceau brisé selon\nle vieux druide... Faites attention à vous. »\n\n⚡ Soudain — une main agile plonge dans votre bourse.\nUn gamin détale vers la ruelle !"
			label1.text = "🏃  Poursuivre le voleur !"
			label2.text = "😔  Laisser faire..."
		3:
			_jouer_son(snd_couteau)
			texte.text = "Vous rattrapez le gamin dans une ruelle sombre.\nIl se retourne, un couteau à la main, tremblant.\n\n« Laissez-moi partir ou je crie ! »\n\n💰 Vous avez perdu %d pièces d'or." % or_joueur
			or_joueur = 0
			_sauvegarder_stats()
			_maj_hud()
			label1.text = "⚔️  Attaquer (Combat)"
			label2.text = "🗣️  Persuader (Charisme)"
		4: # Combat — voleur fuit
			_jouer_son(snd_couteau)
			texte.text = "Vous dégainez votre arme.\nLe gamin, pris de panique, lâche la bourse\net s'enfuit en courant dans l'ombre.\n\n✅ Vous récupérez vos 50 pièces d'or !"
			or_joueur = 50
			_sauvegarder_stats()
			_maj_hud()
			label1.text = "🛒  Visiter le marchand"
			label2.text = "🗺️  Retourner à la carte"
		5: # Persuasion
			_jouer_son(snd_pieces)
			texte.text = "« Écoute... je sais que tu as faim.\nGarde 10 pièces et rends-moi le reste. »\n\nLe gamin hésite... puis tend la bourse.\n« Vous êtes pas comme les autres... »\nIl disparaît dans l'ombre.\n\n✅ Vous récupérez 40 pièces d'or."
			or_joueur = 40
			_sauvegarder_stats()
			_maj_hud()
			label1.text = "🛒  Visiter le marchand"
			label2.text = "🗺️  Retourner à la carte"
		6: # Laisser faire
			texte.text = "Vous regardez le gamin disparaître\navec votre bourse dans les ruelles sombres.\n\n« C'est la vie... » soupirez-vous.\n\n❌ Vous avez perdu 50 pièces d'or."
			or_joueur = 0
			_sauvegarder_stats()
			_maj_hud()
			label1.text = "🗺️  Retourner à la carte"
			label2.text = ""
		7: # Marchand
			_jouer_son(snd_pieces)
			texte.text = "🛒 MARCHAND DE PIEDVAL\n\nVotre or : %d 💰\n\n[1] Potion de soin (+5 PV) ............. 10 or\n[2] Antidote (annule poison) .......... 15 or\n[3] Torche (éclaire les donjons) ....... 5 or" % or_joueur
			label1.text = "🧪  Potion de soin (10 or)"
			label2.text = "🚪  Quitter la boutique"
		8: # Achat potion
			if or_joueur >= 10:
				_jouer_son(snd_pieces)
				or_joueur -= 10
				hp = min(hp + 5, hp_max)
				_sauvegarder_stats()
				_maj_hud()
				texte.text = "✅ Vous achetez une potion de soin.\n\nPV restaurés : %d/%d\nOr restant : %d 💰\n\nLe marchand sourit.\n« Revenez quand vous voulez, aventurier ! »" % [hp, hp_max, or_joueur]
			else:
				texte.text = "❌ Pas assez d'or !\nIl vous faut 10 pièces.\n\nVotre or : %d 💰" % or_joueur
			label1.text = "🔙  Retour boutique"
			label2.text = "🗺️  Retourner à la carte"

	bouton2.visible = label2.text != ""
	if snd_click and e != 3:
		snd_click.play()

func _on_bouton1_pressed():
	match etape:
		0: _afficher_etape(1)
		1: _afficher_etape(2)
		2: _afficher_etape(3)
		3: _afficher_etape(4)
		4: _afficher_etape(7)
		5: _afficher_etape(7)
		6: _retour_carte()
		7: _afficher_etape(8)
		8: _afficher_etape(7)

func _on_bouton2_pressed():
	match etape:
		0: _retour_carte()
		1: _retour_carte()
		2: _afficher_etape(6)
		3: _afficher_etape(5)
		4: _retour_carte()
		5: _retour_carte()
		7: _retour_carte()
		8: _retour_carte()

func _retour_carte():
	_sauvegarder_stats()
	if snd_porte:
		snd_porte.play()
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://WorldMap.tscn")

func _sauvegarder_stats():
	GameState.character["hp"]   = hp
	GameState.character["max_hp"] = hp_max
	GameState.character["gold"] = or_joueur
	GameState.save()

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			_retour_carte()
