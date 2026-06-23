extends Node
## Donnees du personnage joueur + progression (autoload).
## Inclut le systeme de quetes et la sauvegarde.

const CHEMIN_SAUVEGARDE := "user://sauvegarde_foret.json"

var nom: String = "Heros"
var race_index: int = 0
var classe_index: int = 0
var race_nom: String = "Humain"
var classe_nom: String = "Guerrier"
var portrait_index: int = 1
var chevalier_index: int = 0

# Destination choisie sur la carte (nom du village a visiter)
var destination: String = "Village"

# Rencontre aleatoire en cours : cles du bestiaire (transitoire, non sauvegardee).
var rencontre: Array = []

# Bourse, inventaire, equipement
var gold: int = 80
var inventaire: Array = [         # objets : {nom, icone, slot, atk, def}
	{"nom": "Hache rouillee", "icone": "res://assets/equip/rusty-axe.png", "slot": "Arme", "atk": 2, "def": 0},
	{"nom": "Armure matelassee", "icone": "res://assets/equip/padded-armor.png", "slot": "Armure", "atk": 0, "def": 2},
	{"nom": "Tome de Soin", "icone": "res://assets/items/12.png", "slot": "", "atk": 0, "def": 0},
]
var equipement: Dictionary = {"Arme": null, "Armure": null, "Casque": null, "Accessoire": null}

# Caracteristiques D&D : FOR, DEX, CON, INT, SAG, CHA
var stats: Dictionary = {
	"Force": 8, "Dexterite": 8, "Constitution": 8,
	"Intelligence": 8, "Sagesse": 8, "Charisme": 8,
}

# Progression / journal
var points_attributs: int = 0
var niveau: int = 1
var xp: int = 0
var xp_suivant: int = 50
var region_courante: String = "Vallee de l'Aube"
var artefacts: Array = []          # noms des artefacts obtenus
var lieux_visites: Array = []
var quetes_reussies: Array = []     # identifiants des quetes terminees
var hauts_faits: Array = []         # {"nom", "desc"}
var quetes_actives: Array = []      # copies du catalogue avec objectifs mutables
var monstres_vus: Array = []        # noms des monstres rencontres
var monstres_vaincus: Dictionary = {}   # nom -> nombre vaincus

# --- Catalogue de quetes (region 1) ----------------------------------------
const CATALOGUE_QUETES := {
	"gobelins": {
		"nom": "La menace gobeline",
		"desc": "Reduis la horde de gobelins de la Caverne d'Ombre (tuer 3 gobelins).",
		"donneur": "auberge",
		"objectifs": [{"type": "tuer", "cible": "Gobelin", "requis": 3}],
		"recompense": {"xp": 45, "or": 35, "objet": null},
	},
	"exploration": {
		"nom": "Reconnaissance",
		"desc": "Explore la Caverne d'Ombre pour le compte du village.",
		"donneur": "auberge",
		"objectifs": [{"type": "visiter", "cible": "Caverne d'Ombre", "requis": 1}],
		"recompense": {"xp": 30, "or": 25, "objet": null},
	},
	"preuves": {
		"nom": "Faire ses preuves",
		"desc": "Deviens un aventurier aguerri : atteins le niveau 5.",
		"donneur": "auberge",
		"objectifs": [{"type": "niveau", "cible": "", "requis": 5}],
		"recompense": {"xp": 0, "or": 60,
			"objet": {"nom": "Cape royale", "icone": "res://assets/equip/royal-cape.png", "slot": "Accessoire", "atk": 1, "def": 2}},
	},
}


func pv_max() -> int:
	return 26 + int(stats.get("Constitution", 10)) * 2


func mana_max() -> int:
	return 6 + int(stats.get("Intelligence", 10))


func gagner_xp(n: int) -> int:
	xp += n
	var gagnes := 0
	while xp >= xp_suivant:
		xp -= xp_suivant
		niveau += 1
		points_attributs += 2
		xp_suivant = int(xp_suivant * 1.4)
		gagnes += 1
	return gagnes


func visiter(lieu: String) -> void:
	if not lieux_visites.has(lieu):
		lieux_visites.append(lieu)
	progresser("visiter", lieu, 1)


func monstre_rencontre(nom_m: String) -> void:
	if not monstres_vus.has(nom_m):
		monstres_vus.append(nom_m)


func monstre_vaincu(nom_m: String) -> void:
	if not monstres_vus.has(nom_m):
		monstres_vus.append(nom_m)
	monstres_vaincus[nom_m] = int(monstres_vaincus.get(nom_m, 0)) + 1


func debloquer_haut_fait(nom_hf: String, desc: String) -> bool:
	for h in hauts_faits:
		if h["nom"] == nom_hf:
			return false
	hauts_faits.append({"nom": nom_hf, "desc": desc})
	return true


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


# --- Quetes ----------------------------------------------------------------

func a_quete_active(id: String) -> bool:
	for q in quetes_actives:
		if q["id"] == id:
			return true
	return false


func accepter_quete(id: String) -> void:
	if a_quete_active(id) or quetes_reussies.has(id) or not CATALOGUE_QUETES.has(id):
		return
	var q: Dictionary = (CATALOGUE_QUETES[id] as Dictionary).duplicate(true)
	q["id"] = id
	for o in q["objectifs"]:
		o["actuel"] = 0
	quetes_actives.append(q)
	sauvegarder()


func progresser(type_obj: String, cible: String, n := 1) -> void:
	var change := false
	for q in quetes_actives:
		for o in q["objectifs"]:
			var c: String = o.get("cible", "")
			if o["type"] == type_obj and (c == "" or c == cible) and int(o.get("actuel", 0)) < int(o["requis"]):
				o["actuel"] = mini(int(o["requis"]), int(o.get("actuel", 0)) + n)
				change = true
	if change:
		sauvegarder()


func _objectif_ok(o: Dictionary) -> bool:
	if o["type"] == "niveau":
		return niveau >= int(o["requis"])
	return int(o.get("actuel", 0)) >= int(o["requis"])


func quete_prete(q: Dictionary) -> bool:
	for o in q["objectifs"]:
		if not _objectif_ok(o):
			return false
	return true


func terminer_quete(id: String) -> bool:
	for i in quetes_actives.size():
		var q: Dictionary = quetes_actives[i]
		if q["id"] == id and quete_prete(q):
			var r: Dictionary = q["recompense"]
			if int(r.get("xp", 0)) > 0:
				gagner_xp(int(r["xp"]))
			gold += int(r.get("or", 0))
			if r.get("objet", null) != null:
				ajouter_objet((r["objet"] as Dictionary).duplicate(true))
			quetes_reussies.append(id)
			quetes_actives.remove_at(i)
			sauvegarder()
			return true
	return false


func quetes_disponibles(donneur: String) -> Array:
	var liste := []
	for id in CATALOGUE_QUETES:
		if not a_quete_active(id) and not quetes_reussies.has(id) and CATALOGUE_QUETES[id]["donneur"] == donneur:
			liste.append(id)
	return liste


func progression_objectif(o: Dictionary) -> String:
	if o["type"] == "niveau":
		return "Niveau %d / %d" % [niveau, int(o["requis"])]
	return "%s : %d / %d" % [_lib_objectif(o), int(o.get("actuel", 0)), int(o["requis"])]


func _lib_objectif(o: Dictionary) -> String:
	match o["type"]:
		"tuer": return "Vaincre %s" % o.get("cible", "ennemis")
		"visiter": return "Explorer %s" % o.get("cible", "")
		"parler": return "Parler a %s" % o.get("cible", "")
	return o["type"]


# --- Sauvegarde ------------------------------------------------------------

func sauvegarder() -> void:
	var d := {
		"nom": nom, "race_index": race_index, "classe_index": classe_index,
		"race_nom": race_nom, "classe_nom": classe_nom,
		"portrait_index": portrait_index, "chevalier_index": chevalier_index,
		"gold": gold, "inventaire": inventaire, "equipement": equipement, "stats": stats,
		"points_attributs": points_attributs, "niveau": niveau, "xp": xp, "xp_suivant": xp_suivant,
		"region": region_courante, "artefacts": artefacts, "lieux_visites": lieux_visites,
		"quetes_reussies": quetes_reussies, "hauts_faits": hauts_faits, "quetes_actives": quetes_actives,
		"monstres_vus": monstres_vus, "monstres_vaincus": monstres_vaincus,
	}
	var f := FileAccess.open(CHEMIN_SAUVEGARDE, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(d))
		f.close()


func a_sauvegarde() -> bool:
	return FileAccess.file_exists(CHEMIN_SAUVEGARDE)


func _norm_objet(o) -> void:
	if typeof(o) != TYPE_DICTIONARY:
		return
	for cle in ["atk", "def", "soin"]:
		if o.has(cle):
			o[cle] = int(o[cle])


func charger() -> bool:
	if not a_sauvegarde():
		return false
	var f := FileAccess.open(CHEMIN_SAUVEGARDE, FileAccess.READ)
	if f == null:
		return false
	var txt := f.get_as_text()
	f.close()
	var d = JSON.parse_string(txt)
	if typeof(d) != TYPE_DICTIONARY:
		return false

	nom = str(d.get("nom", nom))
	race_index = int(d.get("race_index", race_index))
	classe_index = int(d.get("classe_index", classe_index))
	race_nom = str(d.get("race_nom", race_nom))
	classe_nom = str(d.get("classe_nom", classe_nom))
	portrait_index = int(d.get("portrait_index", portrait_index))
	chevalier_index = int(d.get("chevalier_index", chevalier_index))
	gold = int(d.get("gold", gold))
	points_attributs = int(d.get("points_attributs", points_attributs))
	niveau = int(d.get("niveau", niveau))
	xp = int(d.get("xp", xp))
	xp_suivant = int(d.get("xp_suivant", xp_suivant))
	region_courante = str(d.get("region", region_courante))
	artefacts = d.get("artefacts", [])
	lieux_visites = d.get("lieux_visites", [])
	quetes_reussies = d.get("quetes_reussies", [])
	hauts_faits = d.get("hauts_faits", [])

	var st = d.get("stats", {})
	for k in stats.keys():
		if st.has(k):
			stats[k] = int(st[k])

	inventaire = d.get("inventaire", [])
	for o in inventaire:
		_norm_objet(o)
	equipement = d.get("equipement", {"Arme": null, "Armure": null, "Casque": null, "Accessoire": null})
	for slot in equipement:
		_norm_objet(equipement[slot])

	quetes_actives = d.get("quetes_actives", [])
	for q in quetes_actives:
		for o in q.get("objectifs", []):
			o["actuel"] = int(o.get("actuel", 0))
			o["requis"] = int(o["requis"])

	monstres_vus = d.get("monstres_vus", [])
	monstres_vaincus = d.get("monstres_vaincus", {})
	for cle in monstres_vaincus.keys():
		monstres_vaincus[cle] = int(monstres_vaincus[cle])
	return true


func reinitialiser() -> void:
	nom = "Heros"
	race_index = 0
	classe_index = 0
	portrait_index = 1
	chevalier_index = 0
	for cle in stats:
		stats[cle] = 8


func resume() -> String:
	return "%s - niveau %d, region %s" % [nom, niveau, region_courante]
