extends Resource
class_name TerrainData

@export var id: String
@export var name: String
@export var effect_description: String
@export var triggers: Array[Dictionary] # e.g., on_enter, on_end_turn, etc.
@export var owner_type: String # "Player", "Void", "Pantheon"
