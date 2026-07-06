# Crépuscule — version Godot 4

Mini *Vampire Survivors* en **Godot 4.x** (testé sur **Godot 4.7-stable**), écrit en
**GDScript natif**. Graphismes et sons issus de ta bibliothèque (dépôt `Sand`).

## Ouvrir et jouer

1. Lance Godot (`Godot_v4.7-stable_win64.exe`).
2. Gestionnaire de projets → **Importer** → `project.godot` → **Importer & Éditer**.
   (Au premier ouvrage, Godot ré-importe les images/sons : c'est normal.)
3. **F5** (ou ▶) pour lancer.

## L'histoire — et le but du jeu

Au premier **Nouvelle Partie**, une **cinématique** raconte l'histoire (revoyable
via le bouton **HISTOIRE** du menu ; clic/touche pour avancer, **PASSER** pour sauter) :
le Seigneur du Crépuscule a rouvert les cavernes, ses hordes déferlent.

**Le but : survivre, monter jusqu'au NIVEAU 99 (le maximum) et vaincre le
Seigneur du Crépuscule en personne.** Tous les **10 niveaux**, un **gardien**
de plus en plus puissant se dresse sur la route.

## Choix du héros (5 jouables, avec portraits)

| Héros | Style | PV | Vitesse | Capacités (1→5) | Ultime |
|-------|-------|----|---------|----|--------|
| **Sorcier Maudit** | mage à distance (boules de feu auto) | 100 | ●●○ | Boule de feu · Éclair · Gel · Soin · Météore | Tempête arcanique |
| **Samurai Errant** | mêlée rapide | 135 | ●●● | Entaille · Ruée · Tourbillon · Garde · Lame volante | Mille coupures |
| **Chevalier de l'Aube** | tank sacré, gros dégâts | 170 | ●○○ | Entaille · **Égide sacrée** · Ruée · Soin · Lame volante | Jugement |
| **Kobold Sauvage** | berserker féral, fragile et véloce | 90 | ●●●● | **Croissant sanglant** · **Nova écarlate** · Piétinement · **Frénésie** · Tourbillon | Rage primordiale |
| **Gladiateur** | champion d'arène, équilibré | 150 | ●●○ | Entaille · Piétinement · Ruée · Garde · Lame volante | Rugissement de l'arène |

Nouveaux sorts marquants :
- **Égide sacrée** — bouclier d'**invincibilité (3,5 s)** + soin.
- **Croissant sanglant** — éventail de 7 lames en **arc de cercle**.
- **Nova écarlate** — anneau complet de 14 projectiles.
- **Piétinement** — onde de choc : dégâts + repoussée + ralentissement.
- **Frénésie** — attaque 2× plus vite et cours plus vite quelques secondes.
- Ultimes : **Jugement** (zone sainte géante + invincibilité) · **Rage primordiale** (double anneau + longue frénésie).

## Commandes

- **Déplacement :** WASD / ZQSD / flèches — ou **stick gauche** (manette).
- **Attaque de base : automatique** (boules de feu ou coups de mêlée selon le héros).
- **Capacités : déclenchées par toi** — touches **1 2 3 4 5** (ou **A B X Y / LB**).
- **Ultime :** touche **6** / **Espace** (ou **RB**) — quand la **jauge de puissance**
  est pleine (elle monte en tuant, +25% par boss).
- **Pause :** P / Échap / Start · **Son :** M

## Les gardiens (tous les 10 niveaux) — esquive !

Aux niveaux **10, 20, …, 90**, un **boss gardien** apparaît (barre de vie en haut
de l'écran), de plus en plus fort, avec des attaques à **esquiver** :

| Niveau | Gardien | Attaques |
|--------|---------|----------|
| 10 | **NightBorne** | anneaux d'orbes + tirs visés |
| 20 | **Porteur de Mort** | zones télégraphiées + invocations |
| 30 | **L'Œil Dévoreur** (démon) | volées de tirs + invocations |
| 40 | **Dragon Écarlate** | **souffle enflammé** (éventail d'orbes lourds) + nappes de feu |
| 50 | **Brute Démoniaque** | volées de tirs + invocations |
| 60 | **Porteur de Mort** | zones + invocations |
| 70 | **Ombre Cornue** (démon) | volées de tirs + invocations |
| 80 | **Dragon d'Ivoire** | souffle + nappes |
| 90 | **Dragon du Crépuscule** | souffle + nappes |

Astuce : les **cercles rouges** annoncent une explosion — sors-en avant le boom !
Passé 4 minutes, des **démons** rejoignent aussi la horde de base.

Chaque gardien vaincu lâche un **objet** (⚔️ +30% dégâts · 🛡️ +40 PV max · 🧪 soin complet).

Au **niveau 99** : le **☠ SEIGNEUR DU CRÉPUSCULE ☠** (MegaBoss enflammé, géant) —
anneaux, zones, souffle et tirs à la fois. Vaincs-le pour la **VICTOIRE**
(bonus de **+10 000** au score) !

## Montée en puissance (des deux côtés)

- Chaque niveau : choix d'**amélioration** + **Onde arcanique** + petits bonus
  passifs (+2 PV max, +1,5% dégâts, vitesse).
- Mais les ennemis gagnent aussi en vie et en dégâts **avec ton niveau** et avec
  le temps — la course à la puissance ne s'arrête jamais.

## Tableau des scores

À la mort **ou à la victoire** : saisis ton **nom**, ton score est enregistré
(persistant dans `user://scores.json`), et le **classement** s'affiche.
Accessible aussi depuis le menu (**Scores**).

### Rangs (pack Fantasy Ranks)

Chaque fin de partie t'attribue un **rang** selon ton score — **18 paliers** :
**Bronze I→VI** (dès 0), **Argent I→VI** (dès 4 000), **Or I→VI** (dès 14 000 —
la victoire au niveau 99 et son bonus de +10 000 t'ouvrent les rangs Or !).
L'**emblème** (chevrons bronze/argent/or) s'affiche en grand sur l'écran de fin
et devant **chaque ligne du classement**.

## Contenu visuel & audio

- **5 héros animés** : Evil Wizard, Samurai, Knight, Kobold Warrior, **Gladiator** (CraftPix).
- **Boss** : NightBorne, **Bringer of Death**, **3 Démons**, **3 Dragons**, **MegaBoss** final.
- **Monstres** : gobelin, chauve-souris, œil volant, champignon, squelette + **démons** (tard).
- **Carte** : sol **RPGW Caves v2.1** en patchwork varié (cristaux, rochers).
- **Interface : pack CraftPix RPG UI Elements** (vraies textures, styles de calques
  rendus via Photopea) — cadres **dorés à pointes de flèche** pour PV/XP, **bannière
  ornée** pour la barre de boss, **slots dorés** de la barre de skills, grand **panneau
  sombre à bordure dorée** pour tous les menus, **boutons-plaques** dorés, **bannières
  parchemin** (fins de partie, niveau supérieur), curseurs à **poignée diamant**.
  Polices **Ringbearer** (titres/boutons) et **Palatino** (texte).
- **Rangs : pack Fantasy Ranks** — 18 emblèmes à chevrons (Bronze/Argent/Or I→VI).
- **Menus** : forêt crépusculaire + **cinématique d'intro** + séparateurs Kenney.
- **Icônes de sorts** : Raven Fantasy + **BloodMage** + **Spell Icons Vol.1** (packs peints).
- **Audio** : musique menu/jeu + un son par sort.

## Comment c'est construit

```text
godot/
├─ project.godot · scenes/Main.tscn
├─ scripts/
│  ├─ Main.gd        Boucle, héros, spawn, boss & patterns, sorts, ultimes, intro, scores
│  ├─ Player.gd      Héros animé (AnimatedSprite2D) + Camera2D
│  ├─ Enemy.gd       Monstre animé (+ champs boss : palier, patterns)
│  ├─ EnemyShot.gd   Orbe de boss à esquiver
│  ├─ DangerZone.gd  Zone d'explosion télégraphiée (cercle d'alerte)
│  ├─ Projectile.gd  Projectile du joueur (boule de feu / lames)
│  ├─ Nova.gd        Anneau de sort · Bolt.gd Éclairs · Gem.gd XP
│  ├─ Wheel.gd       Barre de skills (recharges + jauge + ultime)
│  ├─ Scores.gd      Tableau des scores persistant (user://)
│  ├─ Item.gd        Loot des boss
│  ├─ Hud.gd         Menus, sélection (portraits), cinématique, barre de boss, victoire
│  └─ Sfx.gd         Sons + musique + volumes
├─ assets/  wizard/ samurai/ knight/ kobold/ monsters/ boss/ spells/ items/ fx/ bg/ ui/ audio/
└─ icon.svg
```

### Détails techniques
- **Héros** = table `HEROES` (stats, frames, style, skills, ult, crop du portrait) ;
  **capacités** = table `SKILLS`. Ajouter un héros/sort = éditer ces tables.
- **Boss** : `_spawn_boss(tier)` tous les 10 niveaux, patterns dans `_update_bosses`
  (anneaux `_boss_ring`, tirs `_boss_aimed`, zones `_boss_zones`, invocations `_boss_summon`).
- **Cinématique** : tableaux construits en code (`_intro_slides`), fondu + avance auto,
  skippable ; texte + sprites du jeu.
- **Niveau max** : `MAX_LEVEL = 99` ; XP quasi linéaire (`5 + niveau × 3`).
- **Entrées** : `InputMap` au démarrage, clavier QWERTY/AZERTY **et** manette.
- Astuce dev : argument `--smoke` = démarre une partie automatiquement (tests).

## Crédits assets (tous CC0 / libres, via le dépôt `Sand` + CraftPix)
- **Evil Wizard**, **Samurai**, **Knight 2D**, **Kobold Warrior**, **Gladiator** — héros animés.
- **NightBorne** · **Bringer of Death** · **Demon Pack** · **Dragon Pack** · **Mega Boss** — boss animés.
- **Monsters Creatures Fantasy** · **Dark Fantasy Enemies** — monstres.
- **Raven Fantasy Icons** · **BloodMage Free** · **Spell Icons Volume 1** — icônes de sorts.
- **CraftPix — RPG UI Elements** — cadres dorés, bannières, parchemin, panneaux, slots, curseurs (rendus depuis les PSD).
- **CraftPix — RPG MMO UI** — polices (Ringbearer / Palatino).
- **CraftPix — Fantasy Ranks** — 18 emblèmes de rang.
- **Kenney — Fantasy UI Borders** — séparateurs dorés.
- **RPGW Caves v2.1** — tileset de la carte.
- **Fire Bullet Pack** (boule de feu) · **16x16 Assorted RPG Icons** (loot).
- **Musique / SFX** — boucles d'ambiance & d'action + banque de sons + clics Kenney.
