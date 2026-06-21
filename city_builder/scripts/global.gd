extends Node

# Autoloaded singleton used to pass intent from the main menu to the game scene.

# When true, the Builder will load the previously saved map on start instead
# of starting from an empty city.
var load_save_on_start: bool = false

# Biome selected on the terrain screen (key into TERRAINS).
var terrain_id: String = "grass"

const SAVE_PATH := "user://map.res"

# Available biomes. 'ground' tints the terrain plane, 'sky' tints the
# background/ambient so each map has its own mood.
const TERRAINS := {
	"grass": {
		"name": "Grass Valley",
		"ground": Color(0.36, 0.56, 0.27),
		"sky": Color(0.55, 0.78, 0.9),
	},
	"desert": {
		"name": "Desert",
		"ground": Color(0.85, 0.73, 0.46),
		"sky": Color(0.95, 0.85, 0.6),
	},
	"snow": {
		"name": "Snow",
		"ground": Color(0.9, 0.93, 0.97),
		"sky": Color(0.78, 0.85, 0.93),
	},
	"rocky": {
		"name": "Rocky Highlands",
		"ground": Color(0.5, 0.47, 0.42),
		"sky": Color(0.66, 0.69, 0.72),
	},
}

func terrain() -> Dictionary:
	return TERRAINS.get(terrain_id, TERRAINS["grass"])

# Returns true if a saved city exists on disk (used to enable 'Continue').
func has_save() -> bool:
	return ResourceLoader.exists(SAVE_PATH)
