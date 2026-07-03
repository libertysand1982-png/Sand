# Crépuscule — version Godot 4

Mini *Vampire Survivors* en **Godot 4.x** (testé sur **Godot 4.7-stable**), écrit en
**GDScript natif**. Graphismes et sons issus de ta bibliothèque (dépôt `Sand`).

## Ouvrir et jouer

1. Lance Godot (`Godot_v4.7-stable_win64.exe`).
2. Gestionnaire de projets → **Importer** → `project.godot` → **Importer & Éditer**.
   (Au premier ouvrage, Godot ré-importe les images/sons : c'est normal.)
3. **F5** (ou ▶) pour lancer.

## Nouvelle Partie → choix du héros

Depuis le menu (**cadre fantasy Kenney** + musique d'ambiance), **Nouvelle Partie**
ouvre l'écran de **sélection du héros**. Chaque carte montre le **style de combat**,
les **5 capacités** et l'**ultime**. Deux héros jouables :

| Héros | Style | Attaque auto | PV | Capacités (1→5) | Ultime |
|-------|-------|--------------|----|----|--------|
| **Sorcier Maudit** | mage à distance | boules de feu | 100 | Boule de feu · Éclair · Gel · Soin · Météore | Tempête arcanique |
| **Samurai Errant** | mêlée rapide | coups de sabre | 135 | Entaille · Ruée · Tourbillon · Garde · Lame volante | Mille coupures |

## Commandes

- **Déplacement :** WASD / ZQSD / flèches — ou **stick gauche** (manette).
- **Attaque de base : automatique** (vise l'ennemi le plus proche).
- **Capacités : déclenchées par toi** — touches **1 2 3 4 5** (ou **A B X Y / LB**).
- **Ultime :** touche **6** / **Espace** (ou **RB**) — seulement quand la **jauge de
  puissance** est pleine (elle monte en tuant des ennemis, surtout les boss).
- **Pause :** P / Échap / Start · **Son :** M
- Monte en niveau en ramassant les gemmes (**Onde arcanique** à chaque niveau).

## Barre de skills (bas-centre)

La barre horizontale au **milieu-bas** de l'écran affiche les **5 capacités** (icône sur
cadre CraftPix + touche + recharge en camembert), la **jauge de puissance**, puis
l'emplacement d'**ultime** (halo doré + « ULTIME PRÊT ! » quand la jauge est pleine).

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

- **Héros :** *Evil Wizard* (sorcier) et *Samurai* animés (idle / déplacement / mort).
- **Monstres animés :** gobelin, chauve-souris, œil volant, champignon, squelette + **boss NightBorne**.
- **Carte :** sol du tileset **RPGW Caves v2.1**.
- **Menus :** **forêt crépusculaire** + **cadre fantasy Kenney** (nine-patch teinté or).
- **Audio :** **musique** au menu et en jeu + SFX (**un son par sort** : feu / éclair / glace / soin).

## Comment c'est construit

```text
godot/
├─ project.godot · scenes/Main.tscn
├─ scripts/
│  ├─ Main.gd        Boucle, héros, spawn, collisions, niveaux, sorts, ultime, scores, audio
│  ├─ Player.gd      Héros animé (AnimatedSprite2D) + Camera2D
│  ├─ Enemy.gd       Monstre animé (+ ralentissement par le Gel)
│  ├─ Projectile.gd  Boule de feu de l'arme auto
│  ├─ Nova.gd        Anneau de sort (couleur paramétrable)
│  ├─ Bolt.gd        Éclairs en dents de scie
│  ├─ Gem.gd         Gemme d'XP
│  ├─ Wheel.gd       Barre de skills (icônes + recharge + jauge de puissance + ultime)
│  ├─ Scores.gd      Tableau des scores persistant (user://)
│  ├─ Item.gd        Objet de loot lâché par les boss
│  ├─ Hud.gd         Interface + menus (accueil/sélection/options/scores/niveau/fin/pause)
│  └─ Sfx.gd         Sons (un par sort) + musique (menu / jeu) + volumes
├─ assets/  wizard/  samurai/  monsters/  boss/  spells/  items/  fx/  bg/  ui/  audio/
└─ icon.svg
```

### Détails techniques
- **Héros** : dictionnaire `HEROES` (stats, frames, style, skills, ultime) ; `SKILLS`
  décrit chaque capacité (nom, icône, recharge). Changer/ajouter un héros = éditer ces deux tables.
- **Capacités au clavier/manette** via `_unhandled_input` (n'interfère pas avec la saisie du nom).
- **Manette** : `InputEventJoypadMotion` (stick) + `InputEventJoypadButton` (boutons).
- **Barre de skills** = `Control` dessiné en `_draw` (camembert de recharge + jauge).
- **Cadre de menu** = `NinePatchRect` (frame fantasy Kenney, centre transparent, teinté or).
- **Musique** = `AudioStreamPlayer` (MP3 en boucle) ; volumes réglables dans **Options**.
- **Scores** = JSON dans `user://` (`FileAccess` + `JSON`).
- **Entrées** : `InputMap` configuré au démarrage, compatible QWERTY **et** AZERTY.
- Astuce dev : argument `--smoke` = démarre une partie automatiquement (tests).

## Crédits assets (tous CC0 / libres, via le dépôt `Sand`)
- **Evil Wizard** et **Samurai** — héros animés (LuizMelo).
- **Monsters Creatures Fantasy** — gobelin / œil volant / champignon / squelette (LuizMelo).
- **Raven Fantasy Icons** — icônes de sorts.
- **CraftPix — Basic Pixel Art UI for RPG** — cadres ronds de la barre de skills.
- **Kenney — Fantasy UI Borders** — cadre des menus (nine-patch).
- **RPGW Caves v2.1** — tileset de la carte.
- **Dark Fantasy Enemies** (chauve-souris) · **NightBorne** (boss) · **Fire Bullet Pack** (boule de feu) · **16x16 Assorted RPG Icons** (objets de loot).
- **Musique / SFX** — boucles d'ambiance & d'action + banque de sons (feu / éclair / glace / bénédiction) + clics Kenney.
