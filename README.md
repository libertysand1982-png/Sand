# Sand

Dépôt regroupant une bibliothèque d'assets (style Kenney) et deux projets de jeu Godot.

## Structure

```
assets/                Bibliothèque d'assets partagée (réorganisée par catégorie)
├── audio/             Sons et musiques (.ogg)
├── characters/        Sprites de personnages animés (Male_*, Run/Pickup/Idle)
├── models/            Modèles 3D (.glb)
├── objects/           Objets isométriques (orientations _E/_N/_S/_W)
├── sprites/           Spritesheets génériques (sprite_*)
├── tiles/             Tuiles de terrain (tile_*)
│   └── buildings/     Tuiles de bâtiments (buildingTiles_*)
├── ui/                Éléments d'interface (panels, barres, boutons, flèches, curseurs)
├── source/            Fichiers sources éditables (.svg, .xml, .tmx, .tsx, .swf)
└── misc/              Décors divers (rochers, parchemins, structures de carte…)

city_builder/          Projet Godot — city builder (autonome, res:// interne)
rpg_game/              Projet RPG (Python + export Godot, autonome)
```

## Notes

- Les deux projets `city_builder/` et `rpg_game/` sont autonomes : ils embarquent
  leurs propres assets et n'utilisent pas la bibliothèque `assets/` directement.
- `assets/` est une bibliothèque de ressources brutes, fusionnée depuis les deux
  branches d'origine et réorganisée par catégorie.
