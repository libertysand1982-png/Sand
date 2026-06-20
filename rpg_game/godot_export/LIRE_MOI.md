# Portage vers Godot — La Forêt de Brume

## Contenu de ce dossier

```
godot_export/
├── data/               ← copier dans res://data/ dans Godot
│   ├── story.json      (59 nœuds narratifs)
│   ├── locations.json  (13 lieux)
│   ├── monsters.json   (10 monstres)
│   ├── quests.json     (8 quêtes)
│   └── npcs.json       (16 PNJs)
├── scripts/            ← copier dans res://scripts/
│   ├── GameState.gd    (singleton — logique de jeu)
│   ├── Character.gd    (stats, dés, niveau)
│   └── CombatEngine.gd (combat tour par tour)
└── LIRE_MOI.md
```

## Instructions Godot

### 1. Créer le projet
- Godot → Nouveau Projet → 2D
- Renderer: Compatibility (pour export mobile)

### 2. Copier les fichiers
```
res://
├── data/         ← les 5 JSON
└── scripts/      ← les 3 .gd
```

### 3. Configurer GameState comme Singleton
- Projet > Paramètres du Projet > AutoLoad
- Ajouter : `res://scripts/GameState.gd` → nom : `GameState`

### 4. Scènes à créer dans Godot (dans l'éditeur)
1. **MainMenu.tscn** — boutons Nouvelle Partie / Continuer
2. **CharacterCreation.tscn** — formulaire race/classe/stats
3. **WorldMap.tscn** — carte avec TileMap + nœud hero
4. **DialogueBox.tscn** — panneau texte + boutons de choix
5. **CombatScene.tscn** — interface combat tour par tour

### 5. Utiliser les données dans GDScript
```gdscript
# Charger une histoire
var node = GameState.story["piedval_auberge"]
print(node["text"])

# Lancer un combat
var engine = CombatEngine.new(GameState.character, GameState.monsters["gobelin"])
engine.player_attack()
print(engine.log)
```

## Ce qui est déjà fait
- ✅ Toute la logique narrative (59 nœuds)
- ✅ Système D&D 5e (dés, stats, CA, modificateurs)
- ✅ Combat tour par tour avec statuts (poison/peur/brûlure)
- ✅ 8 quêtes avec objectifs
- ✅ Système de 7 fragments + forge d'artefact
- ✅ Sauvegarde/chargement JSON

## Ce qui reste à faire dans Godot
- UI (menus, dialogues, HUD) → utiliser Control nodes
- Carte du monde → TileMap avec tuiles PNG
- Sprites monstres/lieux → importer des assets PNG
- Son → AudioStreamPlayer + fichiers OGG
- Export Android → suivre doc Godot export Android
