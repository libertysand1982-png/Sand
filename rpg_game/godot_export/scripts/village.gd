extends Node2D

@onready var hud = $CanvasLayer/HUD
@onready var titre = $CanvasLayer/TitreVillage
@onready var texte_dialogue = $CanvasLayer/PanneauDialogue/TexteDialogue
@onready var btn_continuer = $CanvasLayer/BtnContinuer
@onready var btn_accepter = $CanvasLayer/BtnAccepterQuete
@onready var btn_acheter = $CanvasLayer/BtnAcheter
@onready var btn_retour = $CanvasLayer/BtnRetour
@onready var btn_carte = $CanvasLayer/BtnCarteMoniale

var interlocuteur: String = ""
var dialogue_etape: int = 0
var boutique_index: int = 0
var quete_en_cours: String = ""

# Dialogues par interlocuteur
var dialogues_aubergiste = [
	"Bienvenue a l Ecu Rouille ! Je suis Aldric, l aubergiste. \nPV restaures pour 10 or. Ou puis-je vous aider ?",
	"Ah, j ai justement un probleme... Des rats infestent ma cave ! \nSi vous pouviez en eliminer 3, je vous recompenserais bien.",
	"Merci d avance, aventurier ! Revenez me voir quand ce sera fait."
]

var dialogues_marchand = [
	"Bonjour voyageur ! Je suis Torban, marchand itinerant. \nJ ai de belles marchandises pour vous.",
	"Voici mon inventaire :\n- Potion (10 or, +5PV)\n- Grande Potion (25 or, +15PV)\n- Antidote (15 or)\n- Torche (5 or)\n- Epee (50 or, +2 Atk)\n- Bouclier (40 or, +2 CA)\nQue souhaitez-vous acheter ?",
	"Bonne chance dans vos aventures ! Revenez quand vous avez besoin."
]

var dialogues_donneur = [
	"Ah, un aventurier ! Je suis le Sage Ermith. \nJ ai plusieurs missions urgentes pour quelqu un de courageux.",
	"Quetes disponibles :\n1. Rats dans la cave (50 XP, 20 or)\n2. Patrouille de route (100 XP, 50 or)\n3. La Liche de Brume (500 XP, 200 or)\n\nLaquelle vous interesse ?",
	"Choisissez une quete et revenez me voir apres l avoir accomplie. Que les dieux vous protegent !"
]

var quetes_proposees = ["rats_caverne", "patrouille", "liche"]


func _ready():
	titre.text = "Village de " + GameState.lieu_actuel if GameState.lieu_actuel != "" else "Village de Piedval"
	_maj_hud()
	_afficher_accueil()

	$CanvasLayer/ZonePersonnages/ColAubergiste/BtnAubergiste.pressed.connect(_parler_aubergiste)
	$CanvasLayer/ZonePersonnages/ColMarchand/BtnMarchand.pressed.connect(_parler_marchand)
	$CanvasLayer/ZonePersonnages/ColDonneur/BtnDonneur.pressed.connect(_parler_donneur)
	btn_continuer.pressed.connect(_continuer_dialogue)
	btn_accepter.pressed.connect(_accepter_quete)
	btn_acheter.pressed.connect(_acheter_item)
	btn_retour.pressed.connect(_retour_accueil)
	btn_carte.pressed.connect(_aller_carte)


func _maj_hud():
	hud.text = GameState.get_stats_texte()


func _afficher_accueil():
	interlocuteur = ""
	dialogue_etape = 0
	texte_dialogue.text = "Bienvenue a " + titre.text + " !\nParlez aux habitants pour obtenir des quetes et du materiel."
	btn_accepter.visible = false
	btn_acheter.visible = false
	btn_continuer.visible = false


func _parler_aubergiste():
	interlocuteur = "aubergiste"
	dialogue_etape = 0
	_afficher_dialogue()


func _parler_marchand():
	interlocuteur = "marchand"
	dialogue_etape = 0
	_afficher_dialogue()


func _parler_donneur():
	interlocuteur = "donneur"
	dialogue_etape = 0
	_afficher_dialogue()


func _afficher_dialogue():
	btn_accepter.visible = false
	btn_acheter.visible = false
	btn_continuer.visible = true

	match interlocuteur:
		"aubergiste":
			var textes = dialogues_aubergiste
			if dialogue_etape < textes.size():
				texte_dialogue.text = textes[dialogue_etape]
			if dialogue_etape == 1:
				quete_en_cours = "rats_caverne"
				if "rats_caverne" not in GameState.quetes_actives and "rats_caverne" not in GameState.quetes_completees:
					btn_accepter.visible = true
					btn_continuer.visible = false
		"marchand":
			var textes = dialogues_marchand
			if dialogue_etape < textes.size():
				texte_dialogue.text = textes[dialogue_etape]
			if dialogue_etape == 1:
				btn_acheter.visible = true
				boutique_index = 0
		"donneur":
			var textes = dialogues_donneur
			if dialogue_etape < textes.size():
				texte_dialogue.text = textes[dialogue_etape]
			if dialogue_etape == 1:
				btn_accepter.visible = true
				btn_continuer.visible = false
				quete_en_cours = "liche"
				for qid in quetes_proposees:
					if qid not in GameState.quetes_actives and qid not in GameState.quetes_completees:
						quete_en_cours = qid
						break


func _continuer_dialogue():
	dialogue_etape += 1
	match interlocuteur:
		"aubergiste":
			if dialogue_etape >= dialogues_aubergiste.size():
				_afficher_accueil()
				return
		"marchand":
			if dialogue_etape >= dialogues_marchand.size():
				_afficher_accueil()
				return
		"donneur":
			if dialogue_etape >= dialogues_donneur.size():
				_afficher_accueil()
				return
	_afficher_dialogue()


func _accepter_quete():
	if quete_en_cours != "":
		GameState.accepter_quete(quete_en_cours)
		var q = GameState.quetes_def[quete_en_cours]
		texte_dialogue.text = "Quete acceptee : " + q["titre"] + "\n" + q["desc"]
		btn_accepter.visible = false
		btn_continuer.visible = true
		# Lancer le combat si la quete implique un monstre
		if "monstre" in q:
			GameState.lancer_combat(q["monstre"])
			await get_tree().create_timer(2.0).timeout
			get_tree().change_scene_to_file("res://Combat.tscn")


func _acheter_item():
	if GameState.boutique_items.is_empty():
		return
	var item = GameState.boutique_items[boutique_index % GameState.boutique_items.size()]
	if GameState.joueur_or >= item["prix"]:
		GameState.joueur_or -= item["prix"]
		GameState.ajouter_item(item["nom"])
		# Appliquer l effet immediatement si équipement
		match item["effet"]:
			"atk":
				GameState.joueur_atk += item["valeur"]
			"ca":
				GameState.joueur_ca += item["valeur"]
		texte_dialogue.text = item["nom"] + " achete pour " + str(item["prix"]) + " or !\nVous avez maintenant " + str(GameState.joueur_or) + " or."
		boutique_index += 1
	else:
		texte_dialogue.text = "Pas assez d or ! Il vous faut " + str(item["prix"]) + " or.\nVous avez " + str(GameState.joueur_or) + " or."
	_maj_hud()


func _retour_accueil():
	_afficher_accueil()


func _aller_carte():
	get_tree().change_scene_to_file("res://WorldMap.tscn")
