#!/usr/bin/env python3
"""
Lancer ce script depuis le dossier racine de ton projet Godot 4.
Il crée tous les fichiers du jeu automatiquement.

    cd MonProjetGodot
    python generer_foret_de_brume.py
"""

import os, shutil

def ecrire(chemin, contenu):
    os.makedirs(os.path.dirname(chemin) if os.path.dirname(chemin) else ".", exist_ok=True)
    with open(chemin, "w", encoding="utf-8") as f:
        f.write(contenu)
    print(f"  ✅ {chemin}")

# ══════════════════════════════════════════════════════
#  SCRIPTS GD
# ══════════════════════════════════════════════════════

GAMESTATE = '''\
extends Node

var character: Dictionary = {
    "name": "Meredius", "hp": 10, "max_hp": 10,
    "armor_class": 10, "attack_bonus": 1,
    "gold": 50, "xp": 0, "level": 1, "inventory": []
}
var monstre_actuel: Dictionary = {}
var monsters: Dictionary = {}

func _ready():
    monsters = {
        "gobelin":  {"name":"Gobelin",  "hp":8,  "ac":11, "attack_bonus":2, "damage":"1d6",   "xp":50,  "loot":[]},
        "loup":     {"name":"Loup",     "hp":12, "ac":12, "attack_bonus":3, "damage":"2d4",   "xp":75,  "loot":[]},
        "bandit":   {"name":"Bandit",   "hp":15, "ac":12, "attack_bonus":3, "damage":"1d8",   "xp":100, "loot":[]},
        "squelette":{"name":"Squelette","hp":10, "ac":13, "attack_bonus":2, "damage":"1d6+1", "xp":80,  "loot":[]},
        "ogre":     {"name":"Ogre",     "hp":30, "ac":11, "attack_bonus":5, "damage":"2d8+2", "xp":200, "loot":[]},
        "liche":    {"name":"Liche",    "hp":50, "ac":17, "attack_bonus":8, "damage":"3d6+3", "xp":500, "loot":[]},
    }

func lancer_combat(nom: String):
    if monsters.has(nom):
        monstre_actuel = monsters[nom].duplicate(true)
    else:
        monstre_actuel = {"name":nom,"hp":10,"ac":12,"attack_bonus":1,"damage":"1d6","xp":50,"loot":[]}

func save():
    var f = FileAccess.open("user://save.json", FileAccess.WRITE)
    f.store_string(JSON.stringify({"character": character}))
    f.close()

func load_save() -> bool:
    if not FileAccess.file_exists("user://save.json"): return false
    var f = FileAccess.open("user://save.json", FileAccess.READ)
    var d = JSON.parse_string(f.get_as_text())
    f.close()
    if d == null: return false
    character = d.get("character", character)
    return true
'''

MAIN_MENU = '''\
extends Control

func _ready():
    $CanvasLayer/BtnNouveau.pressed.connect(_nouvelle_partie)
    $CanvasLayer/BtnQuitter.pressed.connect(get_tree().quit)

func _nouvelle_partie():
    get_tree().change_scene_to_file("res://WorldMap.tscn")
'''

WORLD_MAP = '''\
extends Node2D

@onready var hero    = $Meredius
@onready var sprite  = $Meredius/Sprite2D
@onready var hud     = $CanvasLayer/HUD
@onready var village = $Village_Piedval
@onready var snd_pas   = $AudioPas
@onready var snd_porte = $AudioPorte

var base_scale = 0.04
var bob_time = 0.0
var is_moving = false
var pres_du_village = false
var pas_timer = 0.0

func _ready():
    hero.position = Vector2(576, 324)
    _maj_hud()
    if snd_pas:   snd_pas.stream   = load("res://assets/audio/footstep02.ogg")
    if snd_porte: snd_porte.stream = load("res://assets/audio/doorOpen_1.ogg")

func _maj_hud():
    var nom = GameState.character.get("name","Meredius")
    var hp  = GameState.character.get("hp",10)
    var hpm = GameState.character.get("max_hp",10)
    var or_ = GameState.character.get("gold",50)
    hud.text = "%s  |  PV: %d/%d  |  Or: %d 💰" % [nom, hp, hpm, or_]

func _process(delta):
    var speed = 200
    var dir = Vector2.ZERO
    if Input.is_action_pressed("ui_left"):  dir.x -= 1
    if Input.is_action_pressed("ui_right"): dir.x += 1
    if Input.is_action_pressed("ui_up"):    dir.y -= 1
    if Input.is_action_pressed("ui_down"):  dir.y += 1
    is_moving = dir != Vector2.ZERO
    hero.position += dir.normalized() * speed * delta
    if is_moving and snd_pas:
        pas_timer += delta
        if pas_timer >= 0.4:
            pas_timer = 0.0
            snd_pas.play()
    if not is_moving: pas_timer = 0.0
    if dir.x < 0: sprite.flip_h = true
    elif dir.x > 0: sprite.flip_h = false
    if is_moving:
        bob_time += delta * 12.0
        sprite.scale = Vector2(base_scale, base_scale + abs(sin(bob_time)) * 0.01)
        sprite.position.y = -sin(bob_time) * 4.0
    else:
        bob_time = 0.0
        sprite.scale = Vector2(base_scale, base_scale)
        sprite.position.y = 0
    var dist = hero.position.distance_to(village.position)
    if dist < 800:
        if not pres_du_village:
            pres_du_village = true
            hud.text = "🏘️ Village de Piedval — [E] pour entrer"
    else:
        if pres_du_village:
            pres_du_village = false
            _maj_hud()

func _input(event):
    if event is InputEventKey and event.pressed:
        if event.keycode == KEY_ESCAPE:
            GameState.save()
            get_tree().change_scene_to_file("res://MainMenu.tscn")
        if event.keycode == KEY_E and pres_du_village:
            if snd_porte: snd_porte.play()
            await get_tree().create_timer(0.3).timeout
            get_tree().change_scene_to_file("res://Village.tscn")
'''

VILLAGE = '''\
extends Node2D

var etape = 0
var or_joueur = 50
var hp = 10
var hp_max = 10
var nom = "Meredius"

@onready var texte   = $CanvasLayer/Panneau/Texte
@onready var bouton1 = $CanvasLayer/Bouton1
@onready var bouton2 = $CanvasLayer/Bouton2
@onready var label1  = $CanvasLayer/Bouton1/Label
@onready var label2  = $CanvasLayer/Bouton2/Label
@onready var hud     = $CanvasLayer/HUD
@onready var snd_livre   = $CanvasLayer/AudioLivre
@onready var snd_click   = $CanvasLayer/AudioClick
@onready var snd_couteau = $CanvasLayer/AudioCouteau
@onready var snd_pieces  = $CanvasLayer/AudioPieces
@onready var snd_porte   = $CanvasLayer/AudioPorte

func _ready():
    nom       = GameState.character.get("name",   "Meredius")
    hp        = GameState.character.get("hp",       10)
    hp_max    = GameState.character.get("max_hp",   10)
    or_joueur = GameState.character.get("gold",     50)
    if snd_livre:   snd_livre.stream   = load("res://assets/audio/bookOpen.ogg")
    if snd_click:   snd_click.stream   = load("res://assets/audio/click1.ogg")
    if snd_couteau: snd_couteau.stream = load("res://assets/audio/drawKnife1.ogg")
    if snd_pieces:  snd_pieces.stream  = load("res://assets/audio/handleCoins.ogg")
    if snd_porte:   snd_porte.stream   = load("res://assets/audio/doorClose_1.ogg")
    bouton1.pressed.connect(_on_bouton1_pressed)
    bouton2.pressed.connect(_on_bouton2_pressed)
    _maj_hud()
    _afficher_etape(0)

func _maj_hud():
    if hud: hud.text = "%s  |  PV: %d/%d  |  Or: %d 💰" % [nom, hp, hp_max, or_joueur]

func _jouer(snd):
    if snd: snd.play()

func _afficher_etape(e):
    etape = e
    match e:
        0:
            _jouer(snd_porte)
            texte.text = "Vous entrez dans le village de Piedval.\\nL\'air sent la fumée et le pain chaud.\\n\\nLa taverne \\'L\\'Écu Rouillé\\' se dresse devant vous,\\nses volets de bois peints en rouge délavé."
            label1.text = "🍺  Entrer dans la taverne"
            label2.text = "🚪  Quitter le village"
        1:
            _jouer(snd_livre)
            texte.text = "L\'aubergiste essuie ses verres sans vous regarder.\\n\\n« On n\'est plus tranquilles depuis des semaines...\\nLes gens disparaissent la nuit. Les vieux disent\\nque c\'est la Liche de la Forêt de Brume qui se réveille. »"
            label1.text = "🔍  En savoir plus"
            label2.text = "🙏  Remercier et partir"
        2:
            _jouer(snd_livre)
            texte.text = "« Y\'a des rituels anciens la nuit dans la forêt.\\nDes lumières bleues. Un sceau brisé selon le vieux druide...\\n\\n⚡ Soudain — une main agile plonge dans votre bourse.\\nUn gamin détale vers la ruelle !"
            label1.text = "🏃  Poursuivre le voleur !"
            label2.text = "😔  Laisser faire..."
        3:
            _jouer(snd_couteau)
            texte.text = "Vous rattrapez le gamin dans une ruelle sombre.\\nIl se retourne, un couteau à la main, tremblant.\\n\\n💰 Vous avez perdu %d pièces d\'or." % or_joueur
            or_joueur = 0
            _sauvegarder()
            _maj_hud()
            label1.text = "⚔️  Attaquer (Combat)"
            label2.text = "🗣️  Persuader"
        4:
            _jouer(snd_couteau)
            texte.text = "Vous dégainez votre arme.\\nLe gamin lâche la bourse et s\'enfuit en courant.\\n\\n✅ Vous récupérez vos 50 pièces d\'or !"
            or_joueur = 50
            _sauvegarder()
            _maj_hud()
            label1.text = "🛒  Visiter le marchand"
            label2.text = "🗺️  Retourner à la carte"
        5:
            _jouer(snd_pieces)
            texte.text = "« Garde 10 pièces et rends-moi le reste. »\\nLe gamin hésite... puis tend la bourse.\\n\\n✅ Vous récupérez 40 pièces d\'or."
            or_joueur = 40
            _sauvegarder()
            _maj_hud()
            label1.text = "🛒  Visiter le marchand"
            label2.text = "🗺️  Retourner à la carte"
        6:
            texte.text = "Vous regardez le gamin disparaître avec votre bourse.\\n\\n❌ Vous avez perdu 50 pièces d\'or."
            or_joueur = 0
            _sauvegarder()
            _maj_hud()
            label1.text = "🗺️  Retourner à la carte"
            label2.text = ""
        7:
            _jouer(snd_pieces)
            texte.text = "🛒 MARCHAND DE PIEDVAL\\n\\nVotre or : %d 💰\\n\\n[1] Potion de soin (+5 PV) ............. 10 or\\n[2] Quitter la boutique" % or_joueur
            label1.text = "🧪  Potion de soin (10 or)"
            label2.text = "🚪  Quitter la boutique"
        8:
            if or_joueur >= 10:
                _jouer(snd_pieces)
                or_joueur -= 10
                hp = min(hp + 5, hp_max)
                _sauvegarder()
                _maj_hud()
                texte.text = "✅ Vous achetez une potion de soin.\\n\\nPV restaurés : %d/%d\\nOr restant : %d 💰" % [hp, hp_max, or_joueur]
            else:
                texte.text = "❌ Pas assez d\'or !\\nIl vous faut 10 pièces.\\nVotre or : %d 💰" % or_joueur
            label1.text = "🔙  Retour boutique"
            label2.text = "🗺️  Retourner à la carte"
    bouton2.visible = label2.text != ""
    if snd_click and e != 3: snd_click.play()

func _on_bouton1_pressed():
    match etape:
        0: _afficher_etape(1)
        1: _afficher_etape(2)
        2: _afficher_etape(3)
        3: _lancer_combat()
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

func _lancer_combat():
    GameState.lancer_combat("gobelin")
    get_tree().change_scene_to_file("res://Combat.tscn")

func _retour_carte():
    _sauvegarder()
    if snd_porte: snd_porte.play()
    await get_tree().create_timer(0.3).timeout
    get_tree().change_scene_to_file("res://WorldMap.tscn")

func _sauvegarder():
    GameState.character["hp"]     = hp
    GameState.character["max_hp"] = hp_max
    GameState.character["gold"]   = or_joueur
    GameState.save()

func _input(event):
    if event is InputEventKey and event.pressed:
        if event.keycode == KEY_ESCAPE:
            _retour_carte()
'''

COMBAT = '''\
extends Node2D

var personnage  = {}
var monstre     = {}
var tour        = 0
var combat_fini = false
var en_defense  = false

@onready var texte_combat = $CanvasLayer/TexteCombat
@onready var texte_log    = $CanvasLayer/Log
@onready var btn_attaquer = $CanvasLayer/BtnAttaquer
@onready var btn_defendre = $CanvasLayer/BtnDefendre
@onready var btn_fuir     = $CanvasLayer/BtnFuir
@onready var barre_pv     = $CanvasLayer/BarrePV
@onready var barre_mob    = $CanvasLayer/BarreMob
@onready var label_pv     = $CanvasLayer/LabelPV
@onready var label_mob    = $CanvasLayer/LabelMob
@onready var snd_attaque  = $CanvasLayer/AudioAttaque
@onready var snd_touche   = $CanvasLayer/AudioTouche
@onready var snd_rate     = $CanvasLayer/AudioRate
@onready var snd_mort     = $CanvasLayer/AudioMort
@onready var snd_victoire = $CanvasLayer/AudioVictoire
@onready var snd_fuite    = $CanvasLayer/AudioFuite
@onready var snd_defense  = $CanvasLayer/AudioDefense

var log_combat = []

func _ready():
    personnage = GameState.character.duplicate(true)
    monstre    = GameState.monstre_actuel.duplicate(true)
    monstre["pv_actuel"] = monstre.get("hp", 10)
    if snd_attaque:  snd_attaque.stream  = load("res://assets/audio/drawKnife2.ogg")
    if snd_touche:   snd_touche.stream   = load("res://assets/audio/knifeSlice.ogg")
    if snd_rate:     snd_rate.stream     = load("res://assets/audio/switch1.ogg")
    if snd_mort:     snd_mort.stream     = load("res://assets/audio/metalLatch.ogg")
    if snd_victoire: snd_victoire.stream = load("res://assets/audio/handleCoins2.ogg")
    if snd_fuite:    snd_fuite.stream    = load("res://assets/audio/footstep07.ogg")
    if snd_defense:  snd_defense.stream  = load("res://assets/audio/metalClick.ogg")
    btn_attaquer.pressed.connect(_attaquer)
    btn_defendre.pressed.connect(_defendre)
    btn_fuir.pressed.connect(_fuir)
    _maj_affichage()
    _ajouter_log("⚔️ Combat contre %s !" % monstre.get("name","?"))
    _ajouter_log("PV: %d | CA: %d | Dégâts: %s" % [monstre["pv_actuel"], monstre.get("ac",12), monstre.get("damage","1d6")])

func _maj_affichage():
    var pv = personnage.get("hp",10)
    var pvm = personnage.get("max_hp",10)
    var pm = monstre.get("pv_actuel",0)
    var pmm = monstre.get("hp",10)
    texte_combat.text = "Tour %d — %s vs %s" % [tour, personnage.get("name","Héros"), monstre.get("name","Monstre")]
    if label_pv:  label_pv.text  = "PV: %d/%d" % [pv, pvm]
    if label_mob: label_mob.text = "PV: %d/%d" % [pm, pmm]
    if barre_pv:  barre_pv.scale.x  = clamp(float(pv)/max(pvm,1), 0.0, 1.0)
    if barre_mob: barre_mob.scale.x = clamp(float(pm)/max(pmm,1), 0.0, 1.0)

func _ajouter_log(msg):
    log_combat.append(msg)
    if log_combat.size() > 7: log_combat.pop_front()
    texte_log.text = "\\n".join(log_combat)

func _lancer_de(f): return randi_range(1, f)

func _parse_degats(s: String) -> int:
    var rx = RegEx.new()
    rx.compile(r"(\\d+)d(\\d+)([+-]\\d+)?")
    var m = rx.search(s)
    if m == null: return 1
    var nb = int(m.get_string(1))
    var faces = int(m.get_string(2))
    var mod = int(m.get_string(3)) if m.get_string(3) != "" else 0
    var total = mod
    for i in nb: total += _lancer_de(faces)
    return max(1, total)

func _attaquer():
    if combat_fini: return
    en_defense = false
    if snd_attaque: snd_attaque.play()
    var jet = _lancer_de(20)
    var bonus = personnage.get("attack_bonus", 0)
    if jet == 1:
        _ajouter_log("💨 FUMBLE — attaque ratée !")
        if snd_rate: snd_rate.play()
    elif jet == 20:
        var d = _parse_degats("1d6") + _parse_degats("1d6") + max(0, bonus)
        monstre["pv_actuel"] -= d
        if snd_touche: snd_touche.play()
        _ajouter_log("💥 COUP CRITIQUE ! %d dégâts !" % d)
    elif (jet + bonus) >= monstre.get("ac", 12):
        var d = max(1, _parse_degats("1d6") + bonus)
        monstre["pv_actuel"] -= d
        if snd_touche: snd_touche.play()
        _ajouter_log("⚔️ Touché ! %d dégâts (jet %d)" % [d, jet+bonus])
    else:
        if snd_rate: snd_rate.play()
        _ajouter_log("❌ Raté ! (%d vs CA%d)" % [jet+bonus, monstre.get("ac",12)])
    monstre["pv_actuel"] = max(0, monstre["pv_actuel"])
    _maj_affichage()
    if monstre["pv_actuel"] <= 0: _victoire(); return
    await get_tree().create_timer(0.6).timeout
    _tour_monstre()

func _defendre():
    if combat_fini: return
    en_defense = true
    if snd_defense: snd_defense.play()
    _ajouter_log("🛡️ Posture défensive ! (+4 CA ce tour)")
    await get_tree().create_timer(0.6).timeout
    _tour_monstre()

func _fuir():
    if combat_fini: return
    var jet = _lancer_de(20)
    if jet >= 12:
        if snd_fuite: snd_fuite.play()
        _ajouter_log("🏃 Fuite réussie ! (jet %d)" % jet)
        await get_tree().create_timer(1.0).timeout
        _fin_combat()
    else:
        _ajouter_log("🏃 Fuite échouée ! (jet %d)" % jet)
        await get_tree().create_timer(0.6).timeout
        _tour_monstre()

func _tour_monstre():
    if combat_fini: return
    tour += 1
    var ca = personnage.get("armor_class", 10) + (4 if en_defense else 0)
    en_defense = false
    var jet = _lancer_de(20)
    var bonus = monstre.get("attack_bonus", 0)
    if jet == 20:
        var d = _parse_degats(monstre.get("damage","1d6")) * 2
        personnage["hp"] -= d
        if snd_touche: snd_touche.play()
        _ajouter_log("💀 %s CRITIQUE ! %d dégâts !" % [monstre.get("name","?"), d])
    elif (jet + bonus) >= ca:
        var d = max(1, _parse_degats(monstre.get("damage","1d6")))
        personnage["hp"] -= d
        if snd_touche: snd_touche.play()
        _ajouter_log("👹 %s touche ! %d dégâts" % [monstre.get("name","?"), d])
    else:
        if snd_rate: snd_rate.play()
        _ajouter_log("👹 %s rate !" % monstre.get("name","?"))
    personnage["hp"] = max(0, personnage["hp"])
    _maj_affichage()
    if personnage["hp"] <= 0: _defaite()

func _victoire():
    combat_fini = true
    var xp = monstre.get("xp", 0)
    if snd_victoire: snd_victoire.play()
    _ajouter_log("☠️ %s vaincu ! +%d XP" % [monstre.get("name","?"), xp])
    personnage["xp"] = personnage.get("xp",0) + xp
    GameState.character = personnage
    GameState.save()
    _maj_affichage()
    btn_defendre.visible = false
    btn_fuir.visible = false
    btn_attaquer.pressed.disconnect(_attaquer)
    btn_attaquer.pressed.connect(_fin_combat)

func _defaite():
    combat_fini = true
    if snd_mort: snd_mort.play()
    _ajouter_log("💀 Vous êtes tombé au combat...")
    personnage["hp"] = max(1, personnage.get("max_hp",10) / 2)
    GameState.character = personnage
    GameState.save()
    _maj_affichage()
    btn_defendre.visible = false
    btn_fuir.visible = false
    btn_attaquer.pressed.disconnect(_attaquer)
    btn_attaquer.pressed.connect(_retour_menu)

func _fin_combat():
    GameState.save()
    get_tree().change_scene_to_file("res://WorldMap.tscn")

func _retour_menu():
    GameState.save()
    get_tree().change_scene_to_file("res://MainMenu.tscn")

func _input(event):
    if event is InputEventKey and event.pressed:
        if event.keycode == KEY_ESCAPE and not combat_fini:
            _fuir()
'''

# ══════════════════════════════════════════════════════
#  SCÈNES .tscn
# ══════════════════════════════════════════════════════

TSCN_MAINMENU = '''\
[gd_scene load_steps=7 format=3]

[ext_resource type="Script" path="res://scripts/main_menu.gd" id="1"]
[ext_resource type="Texture2D" path="res://assets/ui/panelInset_brown.png" id="2"]
[ext_resource type="Texture2D" path="res://assets/ui/buttonLong_blue.png" id="3"]
[ext_resource type="Texture2D" path="res://assets/ui/buttonLong_blue_pressed.png" id="4"]
[ext_resource type="Texture2D" path="res://assets/ui/buttonLong_grey.png" id="5"]
[ext_resource type="Texture2D" path="res://assets/ui/buttonLong_grey_pressed.png" id="6"]

[node name="MainMenu" type="Control"]
anchor_right = 1.0
anchor_bottom = 1.0
script = ExtResource("1")

[node name="Fond" type="ColorRect" parent="."]
anchor_right = 1.0
anchor_bottom = 1.0
color = Color(0.04, 0.04, 0.07, 1)

[node name="Titre" type="Label" parent="."]
offset_left = 276.0
offset_top = 80.0
offset_right = 876.0
offset_bottom = 170.0
text = "⚔️  La Forêt de Brume"
horizontal_alignment = 1
vertical_alignment = 1
theme_override_colors/font_color = Color(1, 0.85, 0.3, 1)
theme_override_font_sizes/font_size = 42

[node name="SousTitre" type="Label" parent="."]
offset_left = 276.0
offset_top = 175.0
offset_right = 876.0
offset_bottom = 225.0
text = "Un RPG narratif dans les terres d'Edoran"
horizontal_alignment = 1
theme_override_colors/font_color = Color(0.8, 0.7, 0.5, 1)
theme_override_font_sizes/font_size = 18

[node name="CanvasLayer" type="CanvasLayer" parent="."]

[node name="BtnNouveau" type="TextureButton" parent="CanvasLayer"]
offset_left = 396.0
offset_top = 280.0
offset_right = 756.0
offset_bottom = 350.0
texture_normal = ExtResource("3")
texture_pressed = ExtResource("4")
texture_hover = ExtResource("3")

[node name="Label" type="Label" parent="CanvasLayer/BtnNouveau"]
offset_right = 360.0
offset_bottom = 70.0
text = "⚔️  Nouvelle Aventure"
horizontal_alignment = 1
vertical_alignment = 1
theme_override_font_sizes/font_size = 16

[node name="BtnQuitter" type="TextureButton" parent="CanvasLayer"]
offset_left = 396.0
offset_top = 370.0
offset_right = 756.0
offset_bottom = 440.0
texture_normal = ExtResource("5")
texture_pressed = ExtResource("6")
texture_hover = ExtResource("5")

[node name="Label" type="Label" parent="CanvasLayer/BtnQuitter"]
offset_right = 360.0
offset_bottom = 70.0
text = "🚪  Quitter"
horizontal_alignment = 1
vertical_alignment = 1
theme_override_font_sizes/font_size = 16
'''

TSCN_WORLDMAP = '''\
[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://scripts/world_map.gd" id="1"]

[node name="WorldMap" type="Node2D"]
script = ExtResource("1")

[node name="Fond" type="ColorRect" parent="."]
offset_right = 1152.0
offset_bottom = 648.0
color = Color(0.08, 0.12, 0.06, 1)

[node name="Carte" type="Sprite2D" parent="."]
position = Vector2(576, 324)

[node name="Village_Piedval" type="Node2D" parent="."]
position = Vector2(400, 300)

[node name="MarqueurVillage" type="ColorRect" parent="Village_Piedval"]
offset_left = -10.0
offset_top = -10.0
offset_right = 10.0
offset_bottom = 10.0
color = Color(1, 0.8, 0.2, 1)

[node name="NomVillage" type="Label" parent="Village_Piedval"]
offset_left = -40.0
offset_top = -40.0
offset_right = 80.0
offset_bottom = -15.0
text = "🏘️ Piedval"
theme_override_colors/font_color = Color(1, 0.9, 0.5, 1)
theme_override_font_sizes/font_size = 13

[node name="Meredius" type="CharacterBody2D" parent="."]
position = Vector2(576, 324)
collision_layer = 0
collision_mask = 0

[node name="Sprite2D" type="Sprite2D" parent="Meredius"]
scale = Vector2(0.04, 0.04)

[node name="CollisionShape2D" type="CollisionShape2D" parent="Meredius"]

[node name="Camera2D" type="Camera2D" parent="Meredius"]
zoom = Vector2(1.5, 1.5)

[node name="CanvasLayer" type="CanvasLayer" parent="."]

[node name="HUD" type="Label" parent="CanvasLayer"]
offset_left = 10.0
offset_top = 10.0
offset_right = 700.0
offset_bottom = 40.0
text = "Meredius  |  PV: 10/10  |  Or: 50 💰"
theme_override_colors/font_color = Color(1, 0.9, 0.5, 1)
theme_override_font_sizes/font_size = 16

[node name="AudioPas" type="AudioStreamPlayer" parent="."]
[node name="AudioPorte" type="AudioStreamPlayer" parent="."]
'''

TSCN_VILLAGE = '''\
[gd_scene load_steps=6 format=3]

[ext_resource type="Script" path="res://scripts/village.gd" id="1"]
[ext_resource type="Texture2D" path="res://assets/ui/panelInset_brown.png" id="2"]
[ext_resource type="Texture2D" path="res://assets/ui/buttonLong_brown.png" id="3"]
[ext_resource type="Texture2D" path="res://assets/ui/buttonLong_brown_pressed.png" id="4"]
[ext_resource type="Texture2D" path="res://assets/ui/buttonLong_blue.png" id="5"]
[ext_resource type="Texture2D" path="res://assets/ui/buttonLong_blue_pressed.png" id="6"]

[node name="Village" type="Node2D"]
script = ExtResource("1")

[node name="Fond" type="ColorRect" parent="."]
offset_right = 1152.0
offset_bottom = 648.0
color = Color(0.12, 0.08, 0.04, 1)

[node name="CanvasLayer" type="CanvasLayer" parent="."]

[node name="HUD" type="Label" parent="CanvasLayer"]
offset_left = 10.0
offset_top = 10.0
offset_right = 700.0
offset_bottom = 40.0
text = ""
theme_override_colors/font_color = Color(1, 0.9, 0.5, 1)
theme_override_font_sizes/font_size = 16

[node name="Panneau" type="NinePatchRect" parent="CanvasLayer"]
offset_left = 50.0
offset_top = 55.0
offset_right = 1100.0
offset_bottom = 360.0
texture = ExtResource("2")
patch_margin_left = 8
patch_margin_top = 8
patch_margin_right = 8
patch_margin_bottom = 8

[node name="Texte" type="Label" parent="CanvasLayer/Panneau"]
offset_left = 20.0
offset_top = 20.0
offset_right = 1030.0
offset_bottom = 285.0
text = ""
autowrap_mode = 3
theme_override_font_sizes/font_size = 18

[node name="Bouton1" type="TextureButton" parent="CanvasLayer"]
offset_left = 80.0
offset_top = 395.0
offset_right = 400.0
offset_bottom = 465.0
texture_normal = ExtResource("3")
texture_pressed = ExtResource("4")
texture_hover = ExtResource("3")

[node name="Label" type="Label" parent="CanvasLayer/Bouton1"]
offset_right = 320.0
offset_bottom = 70.0
text = ""
horizontal_alignment = 1
vertical_alignment = 1
theme_override_font_sizes/font_size = 15

[node name="Bouton2" type="TextureButton" parent="CanvasLayer"]
offset_left = 416.0
offset_top = 395.0
offset_right = 736.0
offset_bottom = 465.0
texture_normal = ExtResource("5")
texture_pressed = ExtResource("6")
texture_hover = ExtResource("5")

[node name="Label" type="Label" parent="CanvasLayer/Bouton2"]
offset_right = 320.0
offset_bottom = 70.0
text = ""
horizontal_alignment = 1
vertical_alignment = 1
theme_override_font_sizes/font_size = 15

[node name="AudioLivre" type="AudioStreamPlayer" parent="CanvasLayer"]
[node name="AudioClick" type="AudioStreamPlayer" parent="CanvasLayer"]
[node name="AudioCouteau" type="AudioStreamPlayer" parent="CanvasLayer"]
[node name="AudioPieces" type="AudioStreamPlayer" parent="CanvasLayer"]
[node name="AudioPorte" type="AudioStreamPlayer" parent="CanvasLayer"]
'''

TSCN_COMBAT = '''\
[gd_scene load_steps=11 format=3]

[ext_resource type="Script" path="res://scripts/combat.gd" id="1"]
[ext_resource type="Texture2D" path="res://assets/ui/barBack_horizontalMid.png" id="2"]
[ext_resource type="Texture2D" path="res://assets/ui/barRed_horizontalMid.png" id="3"]
[ext_resource type="Texture2D" path="res://assets/ui/barGreen_horizontalMid.png" id="4"]
[ext_resource type="Texture2D" path="res://assets/ui/buttonLong_blue.png" id="5"]
[ext_resource type="Texture2D" path="res://assets/ui/buttonLong_blue_pressed.png" id="6"]
[ext_resource type="Texture2D" path="res://assets/ui/buttonLong_brown.png" id="7"]
[ext_resource type="Texture2D" path="res://assets/ui/buttonLong_brown_pressed.png" id="8"]
[ext_resource type="Texture2D" path="res://assets/ui/buttonLong_grey.png" id="9"]
[ext_resource type="Texture2D" path="res://assets/ui/buttonLong_grey_pressed.png" id="10"]
[ext_resource type="Texture2D" path="res://assets/ui/panelInset_brown.png" id="11"]

[node name="Combat" type="Node2D"]
script = ExtResource("1")

[node name="Fond" type="ColorRect" parent="."]
offset_right = 1152.0
offset_bottom = 648.0
color = Color(0.04, 0.04, 0.07, 1)

[node name="CanvasLayer" type="CanvasLayer" parent="."]

[node name="PanneauJoueur" type="NinePatchRect" parent="CanvasLayer"]
offset_left = 20.0
offset_top = 20.0
offset_right = 420.0
offset_bottom = 200.0
texture = ExtResource("11")
patch_margin_left = 8
patch_margin_top = 8
patch_margin_right = 8
patch_margin_bottom = 8

[node name="PanneauMonstre" type="NinePatchRect" parent="CanvasLayer"]
offset_left = 730.0
offset_top = 20.0
offset_right = 1130.0
offset_bottom = 200.0
texture = ExtResource("11")
patch_margin_left = 8
patch_margin_top = 8
patch_margin_right = 8
patch_margin_bottom = 8

[node name="PanneauLog" type="NinePatchRect" parent="CanvasLayer"]
offset_left = 20.0
offset_top = 380.0
offset_right = 1130.0
offset_bottom = 620.0
texture = ExtResource("11")
patch_margin_left = 8
patch_margin_top = 8
patch_margin_right = 8
patch_margin_bottom = 8

[node name="TexteCombat" type="Label" parent="CanvasLayer"]
offset_left = 440.0
offset_top = 30.0
offset_right = 720.0
offset_bottom = 130.0
text = "Tour 0"
horizontal_alignment = 1
vertical_alignment = 1
theme_override_font_sizes/font_size = 20

[node name="LabelPV" type="Label" parent="CanvasLayer"]
offset_left = 30.0
offset_top = 30.0
offset_right = 410.0
offset_bottom = 65.0
text = "PV: 10/10"
theme_override_font_sizes/font_size = 18

[node name="BarrePV_BG" type="TextureRect" parent="CanvasLayer"]
offset_left = 30.0
offset_top = 70.0
offset_right = 410.0
offset_bottom = 100.0
texture = ExtResource("2")
stretch_mode = 3

[node name="BarrePV" type="TextureRect" parent="CanvasLayer"]
offset_left = 30.0
offset_top = 70.0
offset_right = 410.0
offset_bottom = 100.0
texture = ExtResource("3")
stretch_mode = 3

[node name="LabelMob" type="Label" parent="CanvasLayer"]
offset_left = 740.0
offset_top = 30.0
offset_right = 1120.0
offset_bottom = 65.0
text = "PV monstre: 10/10"
theme_override_font_sizes/font_size = 18

[node name="BarreMob_BG" type="TextureRect" parent="CanvasLayer"]
offset_left = 740.0
offset_top = 70.0
offset_right = 1120.0
offset_bottom = 100.0
texture = ExtResource("2")
stretch_mode = 3

[node name="BarreMob" type="TextureRect" parent="CanvasLayer"]
offset_left = 740.0
offset_top = 70.0
offset_right = 1120.0
offset_bottom = 100.0
texture = ExtResource("4")
stretch_mode = 3

[node name="Log" type="Label" parent="CanvasLayer"]
offset_left = 35.0
offset_top = 390.0
offset_right = 1115.0
offset_bottom = 610.0
text = ""
autowrap_mode = 3
theme_override_font_sizes/font_size = 16

[node name="BtnAttaquer" type="TextureButton" parent="CanvasLayer"]
offset_left = 80.0
offset_top = 280.0
offset_right = 400.0
offset_bottom = 350.0
texture_normal = ExtResource("5")
texture_pressed = ExtResource("6")
texture_hover = ExtResource("5")

[node name="LabelAttaquer" type="Label" parent="CanvasLayer/BtnAttaquer"]
offset_right = 320.0
offset_bottom = 70.0
text = "⚔️  Attaquer"
horizontal_alignment = 1
vertical_alignment = 1

[node name="BtnDefendre" type="TextureButton" parent="CanvasLayer"]
offset_left = 416.0
offset_top = 280.0
offset_right = 736.0
offset_bottom = 350.0
texture_normal = ExtResource("7")
texture_pressed = ExtResource("8")
texture_hover = ExtResource("7")

[node name="LabelDefendre" type="Label" parent="CanvasLayer/BtnDefendre"]
offset_right = 320.0
offset_bottom = 70.0
text = "🛡️  Défendre"
horizontal_alignment = 1
vertical_alignment = 1

[node name="BtnFuir" type="TextureButton" parent="CanvasLayer"]
offset_left = 752.0
offset_top = 280.0
offset_right = 1072.0
offset_bottom = 350.0
texture_normal = ExtResource("9")
texture_pressed = ExtResource("10")
texture_hover = ExtResource("9")

[node name="LabelFuir" type="Label" parent="CanvasLayer/BtnFuir"]
offset_right = 320.0
offset_bottom = 70.0
text = "🏃  Fuir"
horizontal_alignment = 1
vertical_alignment = 1

[node name="AudioAttaque"  type="AudioStreamPlayer" parent="CanvasLayer"]
[node name="AudioTouche"   type="AudioStreamPlayer" parent="CanvasLayer"]
[node name="AudioRate"     type="AudioStreamPlayer" parent="CanvasLayer"]
[node name="AudioMort"     type="AudioStreamPlayer" parent="CanvasLayer"]
[node name="AudioVictoire" type="AudioStreamPlayer" parent="CanvasLayer"]
[node name="AudioFuite"    type="AudioStreamPlayer" parent="CanvasLayer"]
[node name="AudioDefense"  type="AudioStreamPlayer" parent="CanvasLayer"]
'''

PROJECT_GODOT = '''\
; Engine configuration file.
; It's best edited using the editor UI and not directly,
; since the format might change between versions.

[application]

config/name="La Forêt de Brume"
run/main_scene="res://MainMenu.tscn"
config/features=PackedStringArray("4.3", "Forward Plus")

[autoload]

GameState="*res://scripts/GameState.gd"

[display]

window/size/viewport_width=1152
window/size/viewport_height=648
'''

# ══════════════════════════════════════════════════════
#  GÉNÉRATION
# ══════════════════════════════════════════════════════

def main():
    print("\n🎮 Génération de La Forêt de Brume\n")

    print("📜 Scripts GDScript :")
    ecrire("scripts/GameState.gd",  GAMESTATE)
    ecrire("scripts/main_menu.gd",  MAIN_MENU)
    ecrire("scripts/world_map.gd",  WORLD_MAP)
    ecrire("scripts/village.gd",    VILLAGE)
    ecrire("scripts/combat.gd",     COMBAT)

    print("\n📄 Scènes :")
    ecrire("MainMenu.tscn",  TSCN_MAINMENU)
    ecrire("WorldMap.tscn",  TSCN_WORLDMAP)
    ecrire("Village.tscn",   TSCN_VILLAGE)
    ecrire("Combat.tscn",    TSCN_COMBAT)

    print("\n⚙️  Configuration projet :")
    if not os.path.exists("project.godot"):
        ecrire("project.godot", PROJECT_GODOT)
    else:
        print("  ⏭️  project.godot déjà existant — non écrasé")

    print("\n" + "─"*50)
    print("✅ Terminé !\n")
    print("📋 Dans Godot :")
    print("   • Ouvre ce dossier comme projet Godot 4")
    print("   • Copie le dossier assets/ dans ce projet")
    print("   • Lance avec F5\n")

if __name__ == "__main__":
    main()
