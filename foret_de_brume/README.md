# La Foret de Brume — nouvelle base

Projet Godot 4.3 repartant proprement sur les bases du RPG, avec un menu
principal soigne (UI et sons issus des assets du depot).

## Lancer

Ouvrir le dossier `foret_de_brume/` dans Godot 4.3+ puis lancer la scene
principale `scenes/MainMenu.tscn` (deja definie comme scene de demarrage).

## Contenu actuel

- **Menu principal** (`scenes/MainMenu.tscn`) :
  - Fond mur de pierre + vignette, panneau central NinePatch.
  - Titre a la police *Lilita One*, boutons textures (`buttonLong_brown`).
  - Sons : ouverture du menu (`bookOpen`), survol (`rollover1`), clic (`click1`).
- **Theme** (`theme/menu_theme.tres`) : style des boutons (normal / survol / presse).
- **Audio** (`scripts/Audio.gd`, autoload) : gestionnaire de sons global.

## Structure

```
foret_de_brume/
├── project.godot
├── scenes/MainMenu.tscn
├── scripts/MainMenu.gd
├── scripts/Audio.gd        (autoload)
├── theme/menu_theme.tres
└── assets/ (ui, audio, bg, fonts)  — embarques, projet autonome
```

## Prochaines etapes

- Brancher le bouton « Commencer l'aventure » sur la carte du monde.
- Reprendre les systemes du RPG (combat, personnages, quetes).
