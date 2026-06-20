"""Export all game data to JSON files for Godot import."""
import json, sys, os
sys.path.insert(0, os.path.dirname(__file__))

from data.story import STORY
from data.world import LOCATIONS, QUESTS, NPCS
from data.monsters import MONSTERS

os.makedirs("godot_export", exist_ok=True)

# Story nodes
with open("godot_export/story.json", "w", encoding="utf-8") as f:
    json.dump(STORY, f, ensure_ascii=False, indent=2)
print(f"story.json — {len(STORY)} nodes")

# Locations
with open("godot_export/locations.json", "w", encoding="utf-8") as f:
    json.dump(LOCATIONS, f, ensure_ascii=False, indent=2)
print(f"locations.json — {len(LOCATIONS)} locations")

# Monsters
with open("godot_export/monsters.json", "w", encoding="utf-8") as f:
    json.dump(MONSTERS, f, ensure_ascii=False, indent=2)
print(f"monsters.json — {len(MONSTERS)} monsters")

# Quests
with open("godot_export/quests.json", "w", encoding="utf-8") as f:
    json.dump(QUESTS, f, ensure_ascii=False, indent=2)
print(f"quests.json — {len(QUESTS)} quests")

# NPCs
with open("godot_export/npcs.json", "w", encoding="utf-8") as f:
    json.dump(NPCS, f, ensure_ascii=False, indent=2)
print(f"npcs.json — {len(NPCS)} NPCs")

print("\nExport terminé → dossier godot_export/")
