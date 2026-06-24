# Crépuscule — version Godot 4

Portage **Godot 4.x** (testé sur **Godot 4.7-stable**) du mini Vampire-Survivors.
Même jeu que la version web, réécrit en **GDScript natif**. Les graphismes et les
sons viennent de ton dépôt `Sand` (assets Kenney, CC0).

## Ouvrir et jouer

1. Lance Godot (`Godot_v4.7-stable_win64.exe`).
2. Dans le gestionnaire de projets : **Importer** → choisis le fichier
   `E:\InkFlow\vampire-survivor-godot\project.godot` → **Importer & Éditer**.
   (Au premier ouvrage, Godot ré-importe les images/sons : c'est normal.)
3. Appuie sur **F5** (ou le bouton ▶ en haut à droite) pour lancer le jeu.

## Commandes

- **Déplacement :** WASD / ZQSD / flèches
- **Attaque :** automatique (vise l'ennemi le plus proche)
- **Pause :** P ou Échap · **Son :** M
- Monte en niveau en ramassant les gemmes, puis choisis une amélioration.

## Comment c'est construit

Tout est piloté par **`scripts/Main.gd`** (la boucle de jeu), à la manière de la
version web. Les scènes sont créées par code pour rester simples et robustes ;
la seule scène sur disque est `scenes/Main.tscn` (un `Node2D` + `Main.gd`).

```text
vampire-survivor-godot/
├─ project.godot            Configuration (scène principale, fenêtre, rendu net)
├─ scenes/Main.tscn         Scène racine (lance Main.gd)
├─ scripts/
│  ├─ Main.gd               Contrôleur : boucle, spawn, collisions, niveaux, états, HUD
│  ├─ Player.gd  (VSPlayer) Héros : sprite + Camera2D + stats
│  ├─ Enemy.gd   (VSEnemy)  Monstres : gobelin / bandit / garde (+ barre de vie)
│  ├─ Projectile.gd         Éclat de l'arme (dessiné via _draw)
│  ├─ Gem.gd     (VSGem)    Gemme d'expérience
│  ├─ Hud.gd     (VSHud)    Interface (barres, chrono, menus, choix d'amélioration)
│  └─ Sfx.gd     (VSSfx)    Lecteur de sons (pool de voix)
├─ assets/                  characters / ui / map / audio  (Kenney, CC0)
└─ icon.svg
```

### Détails techniques
- **Rendu net** (pixel-art) : filtre de texture *Nearest* par défaut + sur chaque sprite.
- **Profondeur** : les ennemis et le héros sont sous un nœud `y_sort_enabled`
  (celui devant l'autre selon la position verticale).
- **Sol** : texture en damier générée par code (`Image`), répétée sur l'arène.
- **Entrées** : actions ajoutées au démarrage (`InputMap`), compatibles QWERTY **et** AZERTY.
- Astuce dev : lancer avec l'argument `--smoke` démarre une partie automatiquement
  (utile pour tester rapidement, y compris en `--headless`).

## Aller plus loin
- Découper les entités en vraies scènes `.tscn` si tu préfères l'éditeur visuel.
- Ajouter d'autres armes, un boss (sprite `garde`/`marchand` agrandi), des objets.
- Réutiliser ces scripts comme un mini-jeu intégré dans ton RPG « La Forêt de Brume ».

Voir `CREDITS.md` (dans la version web) pour le détail des assets.
