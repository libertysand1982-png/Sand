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
- **Sorts actifs :** touches **1 2 3 4** (voir la roue en bas à gauche)
- **Pause :** P / Échap · **Son :** M
- Menu : **Nouvelle Partie · Options · Scores · Quitter**
- Monte en niveau en ramassant les gemmes (sort d'**Onde arcanique** à chaque niveau).

## Sorts actifs (roue en bas-gauche)

| Touche | Sort | Effet | Recharge |
|--------|------|-------|----------|
| **1** | Boule de feu | explosion de zone sur l'ennemi le plus proche | 3,5 s |
| **2** | Éclair | foudroie jusqu'à 4 ennemis proches | 6 s |
| **3** | Gel | onde glaciale : dégâts + ralentit autour de toi | 10 s |
| **4** | Soin | rend des PV | 18 s |

La roue affiche l'icône, la touche et la recharge (camembert + compte à rebours).

## Tableau des scores

À la mort : saisis ton **nom**, ton score est calculé et **enregistré** (persistant
dans `user://scores.json`), puis le **classement** s'affiche (ton entrée surlignée).
Accessible aussi depuis le menu (**Scores**).

## Contenu visuel & audio

- **Héros :** *HeroKnight* animé (idle / course / mort).
- **Monstres animés :** gobelin, œil volant, champignon, squelette.
- **Fond :** sol organique généré + **forêt crépusculaire** dans les menus.
- **Audio :** musique de combat en boucle + SFX.

## Comment c'est construit

```text
godot/
├─ project.godot · scenes/Main.tscn
├─ scripts/
│  ├─ Main.gd        Boucle, spawn, collisions, niveaux, sorts, scores, audio
│  ├─ Player.gd      Héros animé (AnimatedSprite2D) + Camera2D
│  ├─ Enemy.gd       Monstre animé (+ ralentissement par le Gel)
│  ├─ Projectile.gd  Éclat de l'arme auto
│  ├─ Nova.gd        Anneau de sort (couleur paramétrable)
│  ├─ Bolt.gd        Éclairs en dents de scie
│  ├─ Gem.gd         Gemme d'XP
│  ├─ Wheel.gd       Roue de sorts (icônes + recharge radiale)
│  ├─ Scores.gd      Tableau des scores persistant (user://)
│  ├─ Hud.gd         Interface + menus (accueil/options/scores/niveau/fin/pause)
│  └─ Sfx.gd         Sons + musique + volumes
├─ assets/  knight/  monsters/  spells/  bg/  audio/
└─ icon.svg
```

### Détails techniques
- **Animations** via `AnimatedSprite2D` + `SpriteFrames` construits en code.
- **Sorts au clavier** via `_unhandled_input` (n'interfère pas avec la saisie du nom).
- **Roue** = `Control` dessiné en `_draw` (camembert de recharge).
- **Scores** = JSON dans `user://` (`FileAccess` + `JSON`).
- **Entrées** : `InputMap` configuré au démarrage, compatible QWERTY **et** AZERTY.
- Astuce dev : argument `--smoke` = démarre une partie automatiquement (tests).

## Crédits assets (tous CC0 / libres, via le dépôt `Sand`)
- **HeroKnight** — chevalier animé (Sven Thole).
- **Monsters Creatures Fantasy** — gobelin / œil volant / champignon / squelette (LuizMelo).
- **Raven Fantasy Icons** — icônes de sorts (boule de feu, éclair, gel, potion).
- **Fond forêt** — décors nature pixel-art · **Musique & SFX** — `foret_de_brume` + clics Kenney.
