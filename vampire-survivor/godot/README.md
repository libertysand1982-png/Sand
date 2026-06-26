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
- **Attaque :** **boules de feu** automatiques (visent l'ennemi le plus proche)
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

La roue affiche l'icône sur un **cadre rond** (pack CraftPix), la touche et la recharge (camembert + compte à rebours).

## Tableau des scores

À la mort : saisis ton **nom**, ton score est calculé et **enregistré** (persistant
dans `user://scores.json`), puis le **classement** s'affiche (ton entrée surlignée).
Accessible aussi depuis le menu (**Scores**).

## Boss & objets

Tous les **5 niveaux**, un **boss NightBorne** apparaît. En mourant, il lâche un
objet à ramasser (au contact) :
- ⚔️ **Arme** — +30% de dégâts
- 🛡️ **Armure** — +40 PV max
- 🧪 **Potion** — PV au maximum

## Contenu visuel & audio

- **Héros :** *Evil Wizard* animé — un sorcier lanceur de sorts (idle / déplacement / mort).
- **Monstres animés :** gobelin, **chauve-souris** (dark fantasy), œil volant, champignon, squelette + **boss NightBorne**.
- **Fond :** sol organique généré + **forêt crépusculaire** dans les menus.
- **Audio :** SFX uniquement (pas de musique) — **un son par sort** (feu / éclair / glace / soin).

## Comment c'est construit

```text
godot/
├─ project.godot · scenes/Main.tscn
├─ scripts/
│  ├─ Main.gd        Boucle, spawn, collisions, niveaux, sorts, scores, audio
│  ├─ Player.gd      Héros animé (AnimatedSprite2D) + Camera2D
│  ├─ Enemy.gd       Monstre animé (+ ralentissement par le Gel)
│  ├─ Projectile.gd  Boule de feu de l'arme auto
│  ├─ Nova.gd        Anneau de sort (couleur paramétrable)
│  ├─ Bolt.gd        Éclairs en dents de scie
│  ├─ Gem.gd         Gemme d'XP
│  ├─ Wheel.gd       Roue de sorts (icônes + recharge radiale)
│  ├─ Scores.gd      Tableau des scores persistant (user://)
│  ├─ Item.gd        Objet de loot lâché par les boss
│  ├─ Hud.gd         Interface + menus (accueil/options/scores/niveau/fin/pause)
│  └─ Sfx.gd         Sons (un par sort) + volumes
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
- **Evil Wizard** — sorcier animé (LuizMelo).
- **Monsters Creatures Fantasy** — gobelin / œil volant / champignon / squelette (LuizMelo).
- **Raven Fantasy Icons** — icônes de sorts (boule de feu, éclair, gel, potion).
- **CraftPix — Basic Pixel Art UI for RPG** — cadres ronds de la roue de sorts.
- **Dark Fantasy Enemies** (chauve-souris) · **NightBorne** (boss) · **Fire Bullet Pack** (boule de feu) · **16x16 Assorted RPG Icons** (objets de loot).
- **Fond forêt** — décors nature pixel-art · **SFX** — banque de sons (feu / éclair / glace / bénédiction) + `foret_de_brume` + clics Kenney.
