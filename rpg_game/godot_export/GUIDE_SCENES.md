# Guide de construction des scènes Godot

## Assets disponibles

### Images UI (res://assets/ui/)
- `buttonLong_blue.png` / `buttonLong_blue_pressed.png` → boutons bleus
- `buttonLong_brown.png` / `buttonLong_brown_pressed.png` → boutons marron (style RPG)
- `buttonLong_beige.png` / `buttonLong_beige_pressed.png` → boutons beige
- `buttonLong_grey.png` / `buttonLong_grey_pressed.png` → boutons gris
- `buttonRound_blue.png` / `buttonRound_beige.png` → boutons ronds
- `barRed_horizontalMid.png` → barre PV joueur (rouge)
- `barGreen_horizontalMid.png` → barre PV monstre (verte)
- `barBlue_horizontalBlue.png` → barre bleue (mana)
- `barBack_horizontalMid.png` → fond de barre
- `panelInset_brown.png` → panneau texte brun
- `arrowBrown_right/left.png` → flèches navigation

### Sons (res://assets/audio/)
- `footstep02.ogg` → pas du héros sur la carte
- `doorOpen_1.ogg` / `doorClose_1.ogg` → entrée/sortie lieu
- `bookOpen.ogg` / `bookFlip1.ogg` → dialogue / page narrative
- `click1.ogg` → clic bouton
- `drawKnife1/2.ogg` → début combat / attaque
- `knifeSlice.ogg` → coup réussi
- `handleCoins.ogg` / `handleCoins2.ogg` → or / récompense
- `metalLatch.ogg` → mort ennemi
- `metalClick.ogg` → défense / armure
- `footstep07.ogg` → fuite
- `creak1/2/3.ogg` → atmosphère donjon
- `cloth1/2/3/4.ogg` → inventaire / équipement

---

## WorldMap.tscn

```
Node2D (script: world_map.gd)
├── Carte (Sprite2D) ← maps.jpg
├── Village_Piedval (Area2D)
│   ├── CollisionShape2D (CircleShape2D rayon 30)
│   ├── Banniere (Sprite2D) ← PIEDVAL.png, scale 0.3, pos y=-80
│   └── [autres lieux à dupliquer]
├── Meredius (CharacterBody2D)
│   ├── Sprite2D ← heros.jpg, scale 0.04
│   ├── Camera2D
│   └── PointLight2D (optionnel)
├── CanvasLayer
│   └── HUD (Label, pos 10,10, couleur blanche)
├── AudioPas (AudioStreamPlayer)
└── AudioPorte (AudioStreamPlayer)
```

---

## Village.tscn

```
Node2D (script: village.gd)
├── Fond (Sprite2D) ← village.jpg, pos 576,324
└── CanvasLayer
    ├── HUD (Label, pos 10,10)
    ├── Panneau (NinePatchRect ← panelInset_brown.png)
    │   ├── pos: 50,80 / size: 700,300
    │   └── Texte (Label, Autowrap=On, size 650,280)
    ├── Bouton1 (TextureButton)
    │   ├── Texture Normal ← buttonLong_brown.png
    │   ├── Texture Pressed ← buttonLong_brown_pressed.png
    │   ├── pos: 100,420 / scale: 2,2
    │   └── Label (texte du choix, centré)
    ├── Bouton2 (TextureButton)
    │   ├── (mêmes textures)
    │   ├── pos: 550,420 / scale: 2,2
    │   └── Label
    ├── AudioLivre (AudioStreamPlayer)
    ├── AudioClick (AudioStreamPlayer)
    ├── AudioCouteau (AudioStreamPlayer)
    ├── AudioPieces (AudioStreamPlayer)
    └── AudioPorte (AudioStreamPlayer)
```

**Connecter les signaux :**
- Bouton1 → pressed → _on_bouton1_pressed
- Bouton2 → pressed → _on_bouton2_pressed

---

## Combat.tscn

```
Node2D (script: combat.gd)
├── Fond (ColorRect noir #0a0a12, plein écran)
└── CanvasLayer
    ├── TexteCombat (Label, pos 50,30, taille 400,100)
    ├── Log (Label, pos 50,400, taille 700,200, Autowrap=On)
    │
    ├── # Barre PV joueur
    ├── BarrePV_BG (TextureRect ← barBack_horizontalMid.png, pos 50,150, size 300,20)
    ├── BarrePV (TextureRect ← barRed_horizontalMid.png, pos 50,150, size 300,20)
    ├── LabelPV (Label, pos 50,130)
    │
    ├── # Barre PV monstre
    ├── BarreMob_BG (TextureRect ← barBack_horizontalMid.png, pos 650,150, size 300,20)
    ├── BarreMob (TextureRect ← barGreen_horizontalMid.png, pos 650,150, size 300,20)
    ├── LabelMob (Label, pos 650,130)
    │
    ├── BtnAttaquer (TextureButton ← buttonLong_blue.png, pos 100,320, scale 2,2)
    ├── BtnDefendre (TextureButton ← buttonLong_brown.png, pos 450,320, scale 2,2)
    ├── BtnFuir (TextureButton ← buttonLong_grey.png, pos 800,320, scale 2,2)
    │
    ├── AudioAttaque (AudioStreamPlayer)
    ├── AudioTouche (AudioStreamPlayer)
    ├── AudioRate (AudioStreamPlayer)
    ├── AudioMort (AudioStreamPlayer)
    ├── AudioVictoire (AudioStreamPlayer)
    ├── AudioFuite (AudioStreamPlayer)
    └── AudioDefense (AudioStreamPlayer)
```

---

## Pour lancer un combat depuis village.gd ou world_map.gd

```gdscript
# Avant de charger la scène combat :
GameState.lancer_combat("gobelin")  # ou "bandit", "loup", etc.
get_tree().change_scene_to_file("res://Combat.tscn")
```

---

## Monstres disponibles (depuis monsters.json)
- gobelin, loup, squelette, araignee_geante
- bandit, ogre, zombie_garde
- liche (boss final), demon_gardien, seigneur_demon
