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

## Choix du héros (4 jouables)

| Héros | Style | PV | Vitesse | Capacités (1→5) | Ultime |
|-------|-------|----|---------|----|--------|
| **Sorcier Maudit** | mage à distance (boules de feu auto) | 100 | ●●○ | Boule de feu · Éclair · Gel · Soin · Météore | Tempête arcanique |
| **Samurai Errant** | mêlée rapide | 135 | ●●● | Entaille · Ruée · Tourbillon · Garde · Lame volante | Mille coupures |
| **Chevalier de l'Aube** | tank sacré, gros dégâts | 170 | ●○○ | Entaille · **Égide sacrée** · Ruée · Soin · Lame volante | Jugement |
| **Kobold Sauvage** | berserker féral, fragile et véloce | 90 | ●●●● | **Croissant sanglant** · **Nova écarlate** · Piétinement · **Frénésie** · Tourbillon | Rage primordiale |

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

- **NightBorne** (niv 10, 30, 50, 70, 90) — **anneaux d'orbes** violets + **tirs visés**.
- **Porteur de Mort** (niv 20, 40, 60, 80) — **zones d'explosion télégraphiées**
  (cercles rouges : sors-en avant le boom !) + **invocations** de monstres.

Chaque gardien vaincu lâche un **objet** (⚔️ +30% dégâts · 🛡️ +40 PV max · 🧪 soin complet).

Au **niveau 99** : le **☠ SEIGNEUR DU CRÉPUSCULE ☠** — géant, tous les patterns
à la fois. Vaincs-le pour la **VICTOIRE** (bonus de **+10 000** au score) !

## Montée en puissance (des deux côtés)

- Chaque niveau : choix d'**amélioration** + **Onde arcanique** + petits bonus
  passifs (+2 PV max, +1,5% dégâts, vitesse).
- Mais les ennemis gagnent aussi en vie et en dégâts **avec ton niveau** et avec
  le temps — la course à la puissance ne s'arrête jamais.

## Tableau des scores

À la mort **ou à la victoire** : saisis ton **nom**, ton score est enregistré
(persistant dans `user://scores.json`), et le **classement** s'affiche.
Accessible aussi depuis le menu (**Scores**).

## Contenu visuel & audio

- **4 héros animés** : Evil Wizard, Samurai, **Knight**, **Kobold Warrior** (LuizMelo & co).
- **Boss** : NightBorne + **Bringer of Death** (marche/mort/sort d'explosion animés).
- **Monstres** : gobelin, chauve-souris, œil volant, champignon, squelette.
- **Carte** : sol **RPGW Caves v2.1** en patchwork varié (cristaux, rochers).
- **Menus** : forêt crépusculaire + **cadre fantasy Kenney** + **cinématique d'intro**.
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

## Crédits assets (tous CC0 / libres, via le dépôt `Sand`)
- **Evil Wizard**, **Samurai**, **Knight 2D**, **Kobold Warrior** — héros animés.
- **NightBorne** · **Bringer of Death** — boss animés.
- **Monsters Creatures Fantasy** · **Dark Fantasy Enemies** — monstres.
- **Raven Fantasy Icons** · **BloodMage Free** · **Spell Icons Volume 1** — icônes de sorts.
- **CraftPix — Basic Pixel Art UI** — cadres de la barre de skills.
- **Kenney — Fantasy UI Borders** — cadre des menus + séparateurs.
- **RPGW Caves v2.1** — tileset de la carte.
- **Fire Bullet Pack** (boule de feu) · **16x16 Assorted RPG Icons** (loot).
- **Musique / SFX** — boucles d'ambiance & d'action + banque de sons + clics Kenney.
