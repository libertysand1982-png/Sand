extends Control
## Combat d'action 2D temps reel : on controle le heros au clavier/manette,
## avec deplacement, saut, esquive (dash invulnerable) et attaque.
## Cinematique manuelle (pas de moteur physique) pour rester simple et robuste.

# --- Reglages ---------------------------------------------------------------
const SOL_Y := 486.0          # ligne de sol (pieds) dans 1152x648
const X_MIN := 48.0
const X_MAX := 1104.0
const GRAVITE := 1700.0
const COURSE := 330.0
const SAUT := -640.0
const DASH_V := 720.0
const DASH_DUREE := 0.20
const DASH_CD := 0.55
const ATK_CD := 0.40
const ATK_PORTEE := 130.0
const PORTEE_Y := 80.0
const HAUTEUR_PERSO := 150.0
const PORTEE_ENNEMI := 78.0
const VITESSE_ENNEMI := 120.0
const ENNEMI_ATK_CD := 1.3

const FPS := {"idle": 8.0, "run": 12.0, "jump": 8.0, "dash": 18.0, "attack": 14.0, "hurt": 10.0, "dead": 9.0}
const ONESHOT := ["attack", "hurt", "dead"]
const VKEY := {"idle": "idle", "run": "walk", "jump": "idle", "dash": "walk", "attack": "attack", "hurt": "hurt", "dead": "dead"}

const POS_ENNEMIS := [820.0, 960.0, 1060.0, 700.0]

# --- Bestiaire (partage avec l'ancien combat) -------------------------------
const BESTIAIRE := {
	"orc_warrior": {"nom": "Orc Guerrier", "base": "Orc_Warrior", "pv": 30, "force": 8},
	"orc_berserk": {"nom": "Orc Berserker", "base": "Orc_Berserk", "pv": 40, "force": 11},
	"orc_shaman": {"nom": "Chaman Orc", "base": "Orc_Shaman", "pv": 24, "force": 9},
	"skeleton": {"nom": "Squelette", "base": "Skeleton", "pv": 22, "force": 7},
	"goblin": {"nom": "Gobelin", "base": "Goblin", "pv": 18, "force": 6},
	"mushroom": {"nom": "Champignon Geant", "base": "Mushroom", "pv": 26, "force": 8},
}
const RENCONTRES := {
	"Caverne d'Ombre": ["goblin", "goblin", "skeleton"],
	"Pyramide Engloutie": ["orc_warrior", "orc_shaman", "skeleton"],
	"Cimetiere du Dragon": ["orc_berserk", "skeleton", "mushroom"],
}
const BUTIN := [
	{"nom": "Cimeterre", "icone": "res://assets/equip/scimitar.png", "slot": "Arme", "atk": 6, "def": 0},
	{"nom": "Armure de cuir", "icone": "res://assets/equip/leather-armor.png", "slot": "Armure", "atk": 0, "def": 3},
	{"nom": "Heaume de fer", "icone": "res://assets/equip/iron-helmet.png", "slot": "Casque", "atk": 0, "def": 2},
	{"nom": "Brassards runiques", "icone": "res://assets/equip/runed-bracers.png", "slot": "Accessoire", "atk": 2, "def": 1},
]

# --- Etat -------------------------------------------------------------------
var _h := {}                  # heros (entite)
var _enemis := []             # entites ennemies
var _fini := false

# entrees (mises a jour chaque frame)
var _in_x := 0.0
var _saut := false
var _dash := false
var _atk := false
var _p_saut := false
var _p_dash := false
var _p_atk := false


func _ready() -> void:
	_lancer_musique()
	_creer_heros()
	_creer_enemis()
	$UI/Message.text = "A l'attaque !"
	await get_tree().create_timer(1.0).timeout
	if is_instance_valid(self):
		$UI/Message.text = ""


func _lancer_musique() -> void:
	var mus := AudioStreamPlayer.new()
	var flux := load("res://assets/audio/battle.mp3")
	if flux is AudioStreamMP3:
		flux.loop = true
	mus.stream = flux
	mus.volume_db = -16.0
	add_child(mus)
	mus.play()


# --- Creation ---------------------------------------------------------------

func _frames(tex: Texture2D) -> int:
	return maxi(1, int(round(float(tex.get_width()) / float(tex.get_height()))))


func _creer_entite(texs: Dictionary, pos: Vector2, hauteur: float) -> Dictionary:
	var node := Node2D.new()
	node.position = pos
	$Arene.add_child(node)

	var idle: Texture2D = texs["idle"]
	var spr := Sprite2D.new()
	spr.texture = idle
	spr.hframes = _frames(idle)
	var ech: float = hauteur / float(idle.get_height())
	spr.scale = Vector2(ech, ech)
	spr.position = Vector2(0, -hauteur * 0.5)
	node.add_child(spr)

	var frames := {}
	for k in texs:
		frames[k] = _frames(texs[k])

	# Barre de vie au-dessus de la tete.
	var fond := ColorRect.new()
	fond.color = Color(0.1, 0.05, 0.05, 0.9)
	fond.size = Vector2(90, 9)
	fond.position = Vector2(-45, -hauteur - 18)
	node.add_child(fond)
	var fill := ColorRect.new()
	fill.color = Color(0.8, 0.2, 0.2)
	fill.size = Vector2(90, 9)
	fill.position = Vector2(-45, -hauteur - 18)
	node.add_child(fill)

	return {
		"node": node, "spr": spr, "texs": texs, "frames": frames,
		"pos": pos, "vel": Vector2.ZERO, "face": 1, "sol": true,
		"visual": "idle", "frame_i": 0.0, "etat": "libre", "etat_t": 0.0,
		"fill": fill, "barre_l": 90.0, "mort": false, "hit_done": false,
	}


func _creer_heros() -> void:
	var n := CharacterData.chevalier_index + 1
	var texs := {
		"idle": load("res://assets/knights/knight%d_idle.png" % n),
		"walk": load("res://assets/knights/knight%d_walk.png" % n),
		"attack": load("res://assets/knights/knight%d_attack.png" % n),
		"hurt": load("res://assets/knights/knight%d_hurt.png" % n),
	}
	_h = _creer_entite(texs, Vector2(220, SOL_Y), HAUTEUR_PERSO)
	_h["pv_max"] = CharacterData.pv_max()
	_h["pv"] = _h["pv_max"]
	_h["fill"].color = Color(0.3, 0.8, 0.3)
	_h["dash_cd"] = 0.0
	_h["atk_cd"] = 0.0
	_h["iframe"] = 0.0
	_h["atk_total"] = float(_h["frames"]["attack"]) / FPS["attack"]


func _creer_enemis() -> void:
	var liste: Array
	if not CharacterData.rencontre.is_empty():
		liste = CharacterData.rencontre
		CharacterData.rencontre = []
	else:
		liste = RENCONTRES.get(CharacterData.destination, ["orc_warrior", "skeleton"])
	# Difficulte : leger bonus de PV selon le niveau du heros.
	var bonus_pv: int = int(CharacterData.niveau) * 2
	for i in mini(liste.size(), POS_ENNEMIS.size()):
		var d: Dictionary = BESTIAIRE[liste[i]]
		var b: String = d["base"]
		var texs := {
			"idle": load("res://assets/enemies/%s_idle.png" % b),
			"attack": load("res://assets/enemies/%s_attack.png" % b),
			"hurt": load("res://assets/enemies/%s_hurt.png" % b),
			"dead": load("res://assets/enemies/%s_dead.png" % b),
		}
		var e := _creer_entite(texs, Vector2(POS_ENNEMIS[i], SOL_Y), HAUTEUR_PERSO)
		e["nom"] = d["nom"]
		e["pv_max"] = int(d["pv"]) + bonus_pv
		e["pv"] = e["pv_max"]
		e["force"] = int(d["force"])
		e["atk_cd"] = 0.6 + 0.3 * float(i)
		e["atk_total"] = float(e["frames"]["attack"]) / FPS["attack"]
		_enemis.append(e)
		CharacterData.monstre_rencontre(d["nom"])


# --- Boucle -----------------------------------------------------------------

func _process(delta: float) -> void:
	if _fini:
		return
	_lire_entrees()
	_maj_heros(delta)
	_maj_enemis(delta)
	_avancer_anim(_h, delta)
	for e in _enemis:
		_avancer_anim(e, delta)
	_check_fin()


func _lire_entrees() -> void:
	var x := 0.0
	if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
		x += 1.0
	if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
		x -= 1.0
	var ax := Input.get_joy_axis(0, JOY_AXIS_LEFT_X)
	if absf(ax) > 0.3:
		x += ax
	_in_x = clampf(x, -1.0, 1.0)

	var saut := Input.is_physical_key_pressed(KEY_SPACE) or Input.is_physical_key_pressed(KEY_W) \
		or Input.is_physical_key_pressed(KEY_UP) or Input.is_joy_button_pressed(0, JOY_BUTTON_A)
	var dash := Input.is_physical_key_pressed(KEY_SHIFT) or Input.is_joy_button_pressed(0, JOY_BUTTON_B)
	var atk := Input.is_physical_key_pressed(KEY_J) or Input.is_physical_key_pressed(KEY_K) \
		or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_joy_button_pressed(0, JOY_BUTTON_X)

	_saut = saut and not _p_saut
	_dash = dash and not _p_dash
	_atk = atk and not _p_atk
	_p_saut = saut
	_p_dash = dash
	_p_atk = atk


func _maj_heros(delta: float) -> void:
	_h["atk_cd"] = maxf(0.0, _h["atk_cd"] - delta)
	_h["dash_cd"] = maxf(0.0, _h["dash_cd"] - delta)
	_h["iframe"] = maxf(0.0, _h["iframe"] - delta)
	var vel: Vector2 = _h["vel"]
	var pos: Vector2 = _h["pos"]
	var sol: bool = _h["sol"]
	vel.y += GRAVITE * delta

	match _h["etat"]:
		"attack":
			_h["etat_t"] -= delta
			if not _h["hit_done"] and _h["etat_t"] <= _h["atk_total"] * 0.5:
				_h["hit_done"] = true
				_frapper()
			vel.x = move_toward(vel.x, 0.0, 2400.0 * delta)
			if _h["etat_t"] <= 0.0:
				_h["etat"] = "libre"
		"hurt":
			_h["etat_t"] -= delta
			vel.x = move_toward(vel.x, 0.0, 1600.0 * delta)
			if _h["etat_t"] <= 0.0:
				_h["etat"] = "libre"
		"dash":
			_h["etat_t"] -= delta
			vel.x = float(_h["face"]) * DASH_V
			vel.y = 0.0
			if _h["etat_t"] <= 0.0:
				_h["etat"] = "libre"
		_:
			vel.x = _in_x * COURSE
			if _in_x > 0.05:
				_h["face"] = 1
			elif _in_x < -0.05:
				_h["face"] = -1
			if _saut and sol:
				vel.y = SAUT
				sol = false
			if _dash and _h["dash_cd"] <= 0.0:
				_h["etat"] = "dash"
				_h["etat_t"] = DASH_DUREE
				_h["dash_cd"] = DASH_CD
				_h["iframe"] = DASH_DUREE + 0.05
				Audio.jouer("swing")
			elif _atk and _h["atk_cd"] <= 0.0:
				_h["etat"] = "attack"
				_h["etat_t"] = _h["atk_total"]
				_h["atk_cd"] = ATK_CD
				_h["hit_done"] = false
				_h["frame_i"] = 0.0
				Audio.jouer("swing")

	pos += vel * delta
	if pos.y >= SOL_Y:
		pos.y = SOL_Y
		vel.y = 0.0
		sol = true
	else:
		sol = false
	pos.x = clampf(pos.x, X_MIN, X_MAX)
	_h["vel"] = vel
	_h["pos"] = pos
	_h["sol"] = sol
	_h["node"].position = pos

	# Visuel
	var vis: String = _h["etat"]
	if vis == "libre":
		if not sol:
			vis = "jump"
		elif absf(vel.x) > 12.0:
			vis = "run"
		else:
			vis = "idle"
	_set_visual(_h, vis)
	_h["spr"].flip_h = _h["face"] < 0
	_h["spr"].modulate.a = 0.5 if _h["iframe"] > 0.0 else 1.0
	_maj_barre(_h)


func _frapper() -> void:
	var touche := false
	for e in _enemis:
		if e["mort"]:
			continue
		var dx: float = e["pos"].x - _h["pos"].x
		if signf(dx) == float(_h["face"]) and absf(dx) < ATK_PORTEE and absf(e["pos"].y - _h["pos"].y) < PORTEE_Y:
			touche = true
			var deg: int = _degats_heros()
			e["pv"] = maxi(0, e["pv"] - deg)
			var ev: Vector2 = e["vel"]
			ev.x = float(_h["face"]) * 260.0
			e["vel"] = ev
			_degats_flottants(e["node"].position, deg, Color(1, 0.85, 0.3))
			_maj_barre(e)
			if e["pv"] <= 0:
				_tuer(e)
			else:
				e["etat"] = "hurt"
				e["etat_t"] = 0.3
	Audio.jouer("hit" if touche else "swing")


func _degats_heros() -> int:
	var force: int = int(CharacterData.stats.get("Force", 10))
	return force + CharacterData.bonus_atk() + 2 + (randi() % 5)


func _tuer(e: Dictionary) -> void:
	e["mort"] = true
	e["etat"] = "dead"
	e["frame_i"] = 0.0
	e["vel"] = Vector2.ZERO
	CharacterData.progresser("tuer", e["nom"], 1)
	CharacterData.monstre_vaincu(e["nom"])
	Audio.jouer("death")


func _maj_enemis(delta: float) -> void:
	for e in _enemis:
		if e["mort"]:
			e["fill"].visible = false
			_set_visual(e, "dead")
			continue
		e["atk_cd"] = maxf(0.0, e["atk_cd"] - delta)
		var vel: Vector2 = e["vel"]
		var pos: Vector2 = e["pos"]
		vel.y += GRAVITE * delta
		var dx: float = _h["pos"].x - pos.x
		e["face"] = 1 if dx >= 0.0 else -1

		match e["etat"]:
			"attack":
				e["etat_t"] -= delta
				vel.x = move_toward(vel.x, 0.0, 1600.0 * delta)
				if not e["hit_done"] and e["etat_t"] <= e["atk_total"] * 0.45:
					e["hit_done"] = true
					if absf(_h["pos"].x - pos.x) < PORTEE_ENNEMI + 20.0 and absf(_h["pos"].y - pos.y) < PORTEE_Y:
						_heros_subit(e["force"])
				if e["etat_t"] <= 0.0:
					e["etat"] = "libre"
			"hurt":
				e["etat_t"] -= delta
				vel.x = move_toward(vel.x, 0.0, 1400.0 * delta)
				if e["etat_t"] <= 0.0:
					e["etat"] = "libre"
			_:
				if absf(dx) > PORTEE_ENNEMI:
					vel.x = signf(dx) * VITESSE_ENNEMI
				else:
					vel.x = 0.0
					if e["atk_cd"] <= 0.0:
						e["etat"] = "attack"
						e["etat_t"] = e["atk_total"]
						e["hit_done"] = false
						e["atk_cd"] = ENNEMI_ATK_CD
						e["frame_i"] = 0.0

		pos += vel * delta
		if pos.y >= SOL_Y:
			pos.y = SOL_Y
			vel.y = 0.0
		pos.x = clampf(pos.x, X_MIN, X_MAX)
		e["vel"] = vel
		e["pos"] = pos
		e["node"].position = pos

		var vis: String = e["etat"]
		if vis == "libre":
			vis = "run" if absf(vel.x) > 12.0 else "idle"
		_set_visual(e, vis)
		e["spr"].flip_h = e["face"] < 0


func _heros_subit(degats: int) -> void:
	if _h["iframe"] > 0.0 or _fini:
		return
	var deg: int = maxi(1, degats - CharacterData.bonus_def() + (randi() % 3))
	_h["pv"] = maxi(0, _h["pv"] - deg)
	_h["iframe"] = 0.6
	_h["etat"] = "hurt"
	_h["etat_t"] = 0.3
	_h["frame_i"] = 0.0
	var v: Vector2 = _h["vel"]
	v.x = float(-_h["face"]) * 260.0
	v.y = -200.0
	_h["vel"] = v
	_h["sol"] = false
	_degats_flottants(_h["node"].position, deg, Color(1, 0.4, 0.3))
	Audio.jouer("hurt")
	_maj_barre(_h)


# --- Animation --------------------------------------------------------------

func _set_visual(ent: Dictionary, vis: String) -> void:
	if ent["visual"] == vis:
		return
	ent["visual"] = vis
	var cle: String = VKEY.get(vis, "idle")
	if not ent["texs"].has(cle):
		cle = "idle"
	ent["spr"].texture = ent["texs"][cle]
	ent["spr"].hframes = ent["frames"][cle]
	ent["frame_i"] = 0.0


func _avancer_anim(ent: Dictionary, delta: float) -> void:
	var vis: String = ent["visual"]
	var cle: String = VKEY.get(vis, "idle")
	if not ent["texs"].has(cle):
		cle = "idle"
	var n: int = ent["frames"][cle]
	ent["frame_i"] += FPS.get(vis, 8.0) * delta
	if vis in ONESHOT:
		ent["spr"].frame = mini(n - 1, int(ent["frame_i"]))
	else:
		ent["spr"].frame = int(ent["frame_i"]) % n


func _maj_barre(ent: Dictionary) -> void:
	ent["fill"].size.x = ent["barre_l"] * (float(ent["pv"]) / float(ent["pv_max"]))


func _degats_flottants(pos: Vector2, degats: int, couleur: Color) -> void:
	var l := Label.new()
	l.text = "-%d" % degats
	l.add_theme_font_size_override("font_size", 28)
	l.add_theme_color_override("font_color", couleur)
	l.add_theme_color_override("font_outline_color", Color(0.15, 0.05, 0))
	l.add_theme_constant_override("outline_size", 5)
	l.position = pos + Vector2(-16, -HAUTEUR_PERSO - 30)
	$Arene.add_child(l)
	var tw := create_tween()
	tw.tween_property(l, "position", l.position + Vector2(0, -50), 0.7)
	tw.parallel().tween_property(l, "modulate:a", 0.0, 0.7)
	tw.tween_callback(l.queue_free)


# --- Fin ---------------------------------------------------------------------

func _check_fin() -> void:
	if _fini:
		return
	if _h["pv"] <= 0:
		_terminer(false)
		return
	for e in _enemis:
		if not e["mort"]:
			return
	_terminer(true)


func _terminer(victoire: bool) -> void:
	_fini = true
	if victoire:
		CharacterData.debloquer_haut_fait("Premier sang", "Remporter un premier combat")
		var xp_gagnee := 25 + _enemis.size() * 10
		var niv := CharacterData.gagner_xp(xp_gagnee)
		var or_gagne := 30 + randi() % 26
		CharacterData.gold += or_gagne
		var msg := "Victoire ! Butin : %d or  (+%d XP)" % [or_gagne, xp_gagnee]
		if niv > 0:
			msg += "   Niveau %d !" % CharacterData.niveau
		if randf() < 0.6:
			var objet: Dictionary = BUTIN[randi() % BUTIN.size()].duplicate()
			CharacterData.ajouter_objet(objet)
			msg += " + %s" % objet["nom"]
		Audio.jouer("coins")
		$UI/Message.text = msg
		CharacterData.sauvegarder()
		_changer_apres(2.4, "res://scenes/WorldMap.tscn")
	else:
		$UI/Message.text = "Tu es tombe au combat..."
		_changer_apres(2.0, "res://scenes/GameOver.tscn")


func _changer_apres(sec: float, scene_path: String) -> void:
	var t := get_tree().create_timer(sec)
	t.timeout.connect(func(): get_tree().change_scene_to_file(scene_path))
