# Crépuscule 🌒

Un petit jeu d'action *roguelite* dans l'esprit de **Vampire Survivors** : tu te
déplaces, ton arme frappe toute seule, tu ramasses des gemmes, tu montes en
niveau et tu choisis des améliorations pendant que les vagues de monstres
grossissent.

Le dépôt contient **deux versions** du même jeu :

| Dossier | Techno | Lancer |
|---------|--------|--------|
| [`web/`](web/) | HTML5 Canvas + JavaScript vanilla | ouvrir `web/index.html` (ou `web/play.ps1`) |
| [`godot/`](godot/) | Godot 4.x (GDScript) | ouvrir `godot/project.godot` dans Godot, puis **F5** |

## Commandes

- **Déplacement :** WASD / ZQSD / flèches
- **Attaque :** automatique (vise l'ennemi le plus proche)
- **Pause :** P / Échap · **Son :** M
- Monte en niveau en ramassant les gemmes, puis choisis une amélioration.

## Assets

Graphismes et sons issus du dépôt **`Sand`** (packs **Kenney**, licence **CC0**) :
sprites de personnages (héros, gobelin, bandit, garde), barres d'interface et
effets sonores. Voir `web/CREDITS.md` pour le détail.

## Contenu

- `web/` — version jouable dans le navigateur, sans installation.
- `godot/` — portage natif Godot 4 (scènes pilotées par code, voir `godot/README.md`).

Le code du jeu est original ; les assets sont sous CC0.
