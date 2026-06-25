# Crépuscule — version Godot 4

Mini *Vampire Survivors* en **Godot 4.x** (testé sur **Godot 4.7-stable**), écrit en
**GDScript natif**. Graphismes et sons issus de ta bibliothèque (dépôt `Sand`).

## Ouvrir et jouer

1. Lance Godot (`Godot_v4.7-stable_win64.exe`).
2. Gestionnaire de projets → **Importer** → `project.godot` → **Importer & Éditer**.
   (Au premier ouvrage, Godot ré-importe les images/sons : c'est normal.)
3. **F5** (ou ▶) pour lancer.

## Commandes

- **Déplacement :** WASD / ZQSD / flèches
- **Attaque :** automatique (vise l'ennemi le plus proche)
- **Pause :** P / Échap · **Son :** M
- Menu : **Nouvelle Partie · Options** (volume musique/effets) **· Quitter**
- Monte en niveau en ramassant les gemmes, puis choisis une amélioration.

## Contenu visuel & audio

- **Héros :** *HeroKnight* animé (idle / course / mort), retourné selon la direction.
- **Monstres animés :** gobelin, œil volant, champignon, squelette (course + mort).
- **Fond :** sol organique généré + **forêt crépusculaire** dans les menus.
- **Audio :** musique de combat en boucle + SFX (coup, magie, pièces, mort, pas, clic).

## Comment c'est construit

Tout est piloté par **`scripts/Main.gd`** ; la seule scène sur disque est
`scenes/Main.tscn` (un `Node2D` + `Main.gd`). Le reste est créé par code.

```text
godot/
├─ project.godot
├─ scenes/Main.tscn
├─ scripts/
│  ├─ Main.gd        Boucle, spawn, collisions, niveaux, états, audio, construction des anims
│  ├─ Player.gd      Héros animé (AnimatedSprite2D) + Camera2D
│  ├─ Enemy.gd       Monstre animé (feuilles découpées en AtlasTexture)
│  ├─ Projectile.gd  Éclat de l'arme (dessiné via _draw)
│  ├─ Gem.gd         Gemme d'expérience
│  ├─ Hud.gd         Interface + menus (accueil/options/niveau/fin/pause)
│  └─ Sfx.gd         Sons (pool de voix) + musique + volumes
├─ assets/  knight/  monsters/  bg/  audio/  ui/  characters/
└─ icon.svg
```

### Détails techniques
- **Animations** via `AnimatedSprite2D` + `SpriteFrames` construits en code
  (frames individuelles pour le héros, feuilles horizontales découpées en
  `AtlasTexture` pour les monstres).
- **Rendu net** (pixel-art) : filtre *Nearest* par défaut.
- **Profondeur** : héros + monstres sous un nœud `y_sort_enabled`.
- **Sol** : tuile d'herbe générée (sans couture) répétée sur l'arène.
- **Entrées** : `InputMap` configuré au démarrage, compatible QWERTY **et** AZERTY.
- Astuce dev : argument `--smoke` = démarre une partie automatiquement (tests).

## Crédits assets (tous CC0 / libres, via le dépôt `Sand`)
- **HeroKnight** — pack de chevalier animé (Sven Thole).
- **Monsters Creatures Fantasy** — gobelin / œil volant / champignon / squelette (LuizMelo).
- **Fond forêt** — pack de décors nature pixel-art.
- **Musique & SFX** — `foret_de_brume` (battle, hit, magic, coins, death) + clics Kenney.

## Aller plus loin
- Ajouter un **boss** (le *Shadowed Wetlands Boss* est dans ta bibliothèque), d'autres armes, des objets.
- Animer une attaque du héros (frames *Attack1/2/3* dispo) sur le tir.
