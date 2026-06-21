# Sand

Dépôt regroupant **une seule bibliothèque d'assets** (`assets/`) et plusieurs projets de jeu Godot.

## Structure

```
assets/                BIBLIOTHÈQUE UNIQUE — tous les assets, classés par catégorie
├── audio/             Sons et musiques (.ogg)
├── backgrounds/       Décors pixel-art (nature_*, forêt, montagne, aurore…)
├── characters/        Sprites de personnages
│   ├── knights/       Chevaliers animés (Knight_1/2/3 : Idle, Run, Attack…)
│   ├── wizards/       Mages animés (Fire Wizard, Lightning Mage…)
│   └── Male_*         Sprites de personnages génériques (Run/Pickup/Idle)
├── items/             Icônes d'objets RPG
│   ├── icons/         Icônes 512² (avec ombre)
│   └── no_shadow/     Icônes 256² (sans ombre)
├── models/            Modèles 3D (.glb)
├── objects/           Objets isométriques (orientations _E/_N/_S/_W)
├── portraits/         Portraits de personnages
│   ├── framed/        Avec fond (512²)
│   └── transparent/   Sans fond
├── sprites/           Spritesheets génériques (sprite_*)
├── tiles/             Tuiles de terrain (tile_*)
│   └── buildings/     Tuiles de bâtiments (buildingTiles_*)
├── ui/                Interface (panels, barres, boutons, flèches, curseurs)
├── source/            Fichiers sources éditables (.svg, .xml, .tmx, .tsx, .swf)
└── misc/              Pack cartographie + décors (château, montagnes, parchemins…)

foret_de_brume/        Projet Godot — RPG "La Forêt de Brume" (menu, création, carte)
city_builder/          Projet Godot — city builder
rpg_game/              Projet RPG (Python + export Godot)
```

## Notes

- **Tous les assets bruts sont regroupés dans `assets/`** (une seule bibliothèque).
- Les projets de jeu (`foret_de_brume/`, `city_builder/`, `rpg_game/`) sont
  **autonomes** : ils embarquent leurs propres copies d'assets via `res://` et
  n'utilisent pas `assets/` directement. Ne pas déplacer leur contenu interne.
