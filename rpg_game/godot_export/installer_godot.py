#!/usr/bin/env python3
"""
installer_godot.py — Installe La Forêt de Brume dans ton projet Godot 4
Usage : python installer_godot.py <chemin_vers_ton_projet_godot>
Exemple : python installer_godot.py C:/Users/Toi/Documents/foret_de_brume
"""

import os
import sys
import shutil

# ── Fichiers à copier ──────────────────────────────────────────────────────────
SCENES = [
    "MainMenu.tscn",
    "WorldMap.tscn",
    "Village.tscn",
    "Combat.tscn",
]

SCRIPTS = [
    "scripts/main_menu.gd",
    "scripts/world_map.gd",
    "scripts/village.gd",
    "scripts/combat.gd",
    "scripts/GameState.gd",
    "scripts/Character.gd",
    "scripts/CombatEngine.gd",
]

def copier(src, dst):
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    shutil.copy2(src, dst)
    print(f"  ✅ {os.path.basename(src)}")

def main():
    if len(sys.argv) < 2:
        print("❌ Usage : python installer_godot.py <chemin_projet_godot>")
        print("   Exemple : python installer_godot.py C:/projets/foret_de_brume")
        sys.exit(1)

    projet = sys.argv[1].rstrip("/\\")

    if not os.path.isdir(projet):
        print(f"❌ Dossier introuvable : {projet}")
        sys.exit(1)

    # Vérifier qu'il s'agit bien d'un projet Godot
    if not os.path.exists(os.path.join(projet, "project.godot")):
        print(f"⚠️  Aucun project.godot trouvé dans : {projet}")
        reponse = input("Continuer quand même ? (o/n) : ").strip().lower()
        if reponse != "o":
            sys.exit(0)

    # Dossier source = là où se trouve ce script
    src_dir = os.path.dirname(os.path.abspath(__file__))

    print(f"\n🎮 Installation de La Forêt de Brume")
    print(f"   Source  : {src_dir}")
    print(f"   Projet  : {projet}\n")

    # ── Scènes ────────────────────────────────────────────────────────────────
    print("📄 Scènes :")
    for fichier in SCENES:
        src = os.path.join(src_dir, fichier)
        dst = os.path.join(projet, fichier)
        if os.path.exists(src):
            copier(src, dst)
        else:
            print(f"  ⚠️  Manquant : {fichier}")

    # ── Scripts ───────────────────────────────────────────────────────────────
    print("\n📜 Scripts :")
    for fichier in SCRIPTS:
        src = os.path.join(src_dir, fichier)
        dst = os.path.join(projet, fichier)
        if os.path.exists(src):
            copier(src, dst)
        else:
            print(f"  ⚠️  Manquant : {fichier}")

    # ── Assets UI ─────────────────────────────────────────────────────────────
    ui_src = os.path.join(src_dir, "assets", "ui")
    ui_dst = os.path.join(projet, "assets", "ui")
    print("\n🖼️  Assets UI :")
    if os.path.isdir(ui_src):
        for f in sorted(os.listdir(ui_src)):
            if f.endswith(".png"):
                copier(os.path.join(ui_src, f), os.path.join(ui_dst, f))
    else:
        print("  ⚠️  Dossier assets/ui introuvable")

    # ── Assets Audio ──────────────────────────────────────────────────────────
    audio_src = os.path.join(src_dir, "assets", "audio")
    audio_dst = os.path.join(projet, "assets", "audio")
    print("\n🔊 Assets Audio :")
    if os.path.isdir(audio_src):
        for f in sorted(os.listdir(audio_src)):
            if f.endswith(".ogg"):
                copier(os.path.join(audio_src, f), os.path.join(audio_dst, f))
    else:
        print("  ⚠️  Dossier assets/audio introuvable")

    # ── Données JSON ──────────────────────────────────────────────────────────
    data_src = os.path.join(src_dir, "data")
    data_dst = os.path.join(projet, "data")
    print("\n📦 Données JSON :")
    if os.path.isdir(data_src):
        for f in sorted(os.listdir(data_src)):
            if f.endswith(".json"):
                copier(os.path.join(data_src, f), os.path.join(data_dst, f))
    else:
        print("  ⚠️  Dossier data introuvable (optionnel)")

    print("\n" + "─" * 50)
    print("✅ Installation terminée !\n")
    print("📋 Étapes suivantes dans Godot :")
    print("   1. Ouvre ton projet dans Godot 4")
    print("   2. Projet > Paramètres du projet > AutoLoad")
    print("      → Ajoute : scripts/GameState.gd  (nom : GameState)")
    print("   3. Projet > Paramètres du projet > Général > Application > Run")
    print("      → Main Scene : res://MainMenu.tscn")
    print("   4. Lance le jeu avec F5 !")
    print()

if __name__ == "__main__":
    main()
