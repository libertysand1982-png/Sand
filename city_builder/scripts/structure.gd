extends Resource
class_name Structure

@export_subgroup("Model")
@export var model:PackedScene # Model of the structure

@export_subgroup("Gameplay")
@export var price:int # Price of the structure when building
@export var income:int = 0 # Cash generated (or upkeep, if negative) per economy tick
@export var title:String = "" # Display name shown in the build bar
@export var category:String = "Roads" # Tab the structure appears under in the build bar
@export var tile_fill:bool = false # Stretch the model to fill the grid cell (roads/ground)

@export_subgroup("Progression")
@export var unlock_population:int = 0 # Population required before this can be built

@export_subgroup("Services")
@export var needs_services:bool = false # Requires nearby power AND water to be active
@export var provides_power:bool = false # Acts as a power source
@export var provides_water:bool = false # Acts as a water source
@export var service_radius:int = 6 # Coverage range in cells (for providers)
