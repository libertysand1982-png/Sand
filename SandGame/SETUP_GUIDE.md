# Sand - The Cursed Village : Guide de Configuration UE5

## Concept du Jeu
Jeu d'action/horreur gothique à la **troisième personne**.  
Le joueur explore un village maudit peuplé de zombies, squelettes et vampires.

---

## 1. Ouvrir le Projet

1. Double-clique sur `SandGame.uproject`
2. Choisis **"Yes"** pour générer les fichiers de projet Visual Studio
3. UE5 compilera automatiquement les sources C++

---

## 2. Importer les Assets du Dépôt

Les FBX et GLB du dépôt sont tes assets visuels. Dans Content Browser :

### Maisons & Portes (FBX)
- `Content/Meshes/Buildings/` → importe `House_01_parts.fbx` … `House_16_parts.fbx`
- `Content/Meshes/Doors/` → importe `DOOR_01_1.fbx` … `DOOR_06_Balkon_1.fbx`

### Props Gothiques (GLB → FBX)
Convertis les `.glb` en `.fbx` via Blender (File → Export → FBX), puis importe :
- `coffin.glb`, `crypt.glb`, `cross.glb` → `Content/Meshes/Cemetery/`
- `character-zombie.glb`, `character-skeleton.glb`, `character-vampire.glb` → `Content/Meshes/Characters/`
- `chest.glb`, `barrel.glb`, `bench.glb` → `Content/Meshes/Props/`
- `weapon-sword.glb`, `weapon-spear.glb` → `Content/Meshes/Weapons/`

### Sons (OGG)
- Importe les `.ogg` dans `Content/Audio/`

---

## 3. Créer les Blueprints

### BP_SandCharacter (joueur)
1. Crée un Blueprint basé sur `ASandCharacter`
2. Assigne le Skeletal Mesh du personnage humain
3. Crée un **Input Mapping Context** dans `Content/Input/IMC_Default`
4. Crée les **Input Actions** :
   - `IA_Move` (Axis2D) → WASD
   - `IA_Look` (Axis2D) → souris
   - `IA_Jump` (Bool) → Espace
   - `IA_Attack` (Bool) → Clic gauche
   - `IA_Interact` (Bool) → E
   - `IA_Sprint` (Bool) → Shift gauche
5. Assigne l'IMC dans le détail du Blueprint

### BP_EnemyZombie
1. Blueprint basé sur `ASandEnemyZombie`
2. Skeletal Mesh → character-zombie
3. AIController → `ASandEnemyAIController`
4. Crée un **Behavior Tree** `BT_Zombie` :
   - Selector → Séquence (bCanSeePlayer == true) → Move To → Perform Attack
   - Selector → Random Patrol → Wait

### BP_EnemySkeleton & BP_EnemyVampire
- Même processus avec les meshes correspondants

### BP_SandDoor
1. Blueprint basé sur `ASandDoor`
2. Static Mesh DoorFrame → un des `House_XX_parts`
3. Static Mesh DoorMesh → un des `DOOR_XX_1`

### BP_SandChest
1. Blueprint basé sur `ASandChest`
2. Meshes → `chest.glb`

### BP_EnemySpawner
1. Blueprint basé sur `ASandEnemySpawner`
2. Ajoute les entrées dans Enemy Pool :
   - Zombie × 3 (poids 3.0)
   - Skeleton × 2 (poids 2.0)
   - Vampire × 1 (poids 1.0)

---

## 4. Créer le HUD (Widget Blueprint)

`Content/UI/WBP_HUD` :
- **Barre de vie** : Progress Bar lié à `GetHealthPercent()`
- **Compteur de pièces** : Text Block lié à `GetCoins()`
- **Vague actuelle** : Text Block

`Content/UI/WBP_GameOver` :
- Texte "VOUS ÊTES MORT"
- Bouton "Réessayer" → `RestartLevel`

`Content/UI/WBP_Win` :
- Texte "VILLAGE LIBÉRÉ !"
- Score et temps

---

## 5. Créer la Map

1. `File → New Level → Empty Level`
2. Sauve sous `Content/Maps/SandVillage`
3. Ajoute un **NavMesh Bounds Volume** (couvre toute la map)
4. Place les Blueprints :
   - Quelques `BP_SandDoor` aux entrées de bâtiments
   - 2-3 `BP_SandChest` cachés dans les cryptes
   - 1 `BP_EnemySpawner` au centre
5. Éclairage : utilise une **Directional Light** en lumière de lune (bleuâtre, intensité faible)
6. Ajoute **Exponential Height Fog** pour l'ambiance gothique

---

## 6. PostProcess et Ambiance

Dans le volume PostProcess :
- **Bloom** : Scale 0.5, intensité 2.0
- **Vignette** : Intensity 0.5
- **Color Grading** : teintes bleu/vert désaturées
- **Chromatic Aberration** : légère

---

## Architecture des Classes C++

```
ASandGameMode          → contrôle vagues, victoire/défaite
ASandPlayerController  → HUD, pause, écrans
ASandCharacter         → joueur (mouvement, attaque, interaction)
USandHealthComponent   → santé générique (joueur + ennemis)
ASandEnemyBase         → ennemi de base (abstrait)
  ASandEnemyZombie     → lent, fort
  ASandEnemySkeleton   → medium, bloque
  ASandEnemyVampire    → rapide, vol de vie, régénère
ASandEnemyAIController → perception (vue), blackboard
ASandEnemySpawner      → spawne par vagues
ISandInteractable      → interface d'interaction
ASandDoor              → porte animée (clé optionnelle)
ASandChest             → coffre avec butin
```
