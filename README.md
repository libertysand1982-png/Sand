# Sand

Dépôt regroupant **une seule bibliothèque d'assets** (`assets/`) et plusieurs projets de jeu Godot.

## Structure

```
assets/                BIBLIOTHÈQUE — tous les assets, classés par catégorie
├── RPG FULL-ok/        Gros pack RPG (factions ORK/TROLL : Tiles, Objects, Animated)
├── animals/            Animaux animés (Boar, Fox, Deer, Hare, Black_grouse)
├── audio/              Sons et musiques (.ogg) — inclut Sounds/ et Music/
├── backgrounds/        Décors pixel-art (nature_*, forêt, montagne, aurore…)
├── buildings/          Bâtiments médiévaux complets (château, tours, forge, marché…)
├── characters/         Sprites de personnages (knights/, wizards/, Male_*)
├── effects/            Effets visuels (slash, slash2…slash10)
├── emblems/            Emblèmes / blasons de factions
├── equipment/          Icônes d'armes, armures, casques, accessoires
├── icons/              Icônes diverses (Icon*, Division32_*)
├── items/              Icônes d'objets RPG (grimoires) + framed/ + no_shadow/
├── kenney_iso/         Pièces isométriques Kenney brutes (woodWall, roof, planks…)
├── misc/               Pack cartographie + décors (parchemins, montagnes…)
├── models/             Modèles 3D (.glb)
├── objects/            Objets isométriques rangés (_E/_N/_S/_W)
├── portraits/          Portraits (framed/ avec fond, transparent/ sans fond)
├── sprites/            Spritesheets génériques (sprite_*)
├── tiles/              Tuiles de terrain (tile_*, buildings/)
├── ui/                 Interface (panels, barres, boutons, flèches)
├── source/             Fichiers sources éditables (.psd, .svg, .xml…)
├── divers/             Assets non encore classés (à trier)
└── All/ PNG/ Animations/   Packs récents en attente de tri

foret_de_brume/        Projet Godot — RPG "La Forêt de Brume" (menu, création, carte, village, combat)
city_builder/          Projet Godot — city builder
rpg_game/              Projet RPG (Python + export Godot)
```

## Notes

- **Tous les assets bruts sont regroupés dans `assets/`** (une seule bibliothèque).
- Les projets de jeu (`foret_de_brume/`, `city_builder/`, `rpg_game/`) sont
  **autonomes** : ils embarquent leurs propres copies d'assets via `res://` et
  n'utilisent pas `assets/` directement. Ne pas déplacer leur contenu interne.
