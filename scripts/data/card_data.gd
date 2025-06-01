extends Resource
class_name CardData

@export var id: String
@export var name: String
@export var description: String
@export var type: String # "SoldierAttack", "Blessing", "Spell", "Ritual", "Terrain", "Prophecy"
@export var cost: int
@export var effects: Array[Dictionary] # Each effect: { "type": String, "value": Variant, ... }
@export var tags: Array[String] # e.g., ["Void", "Healing", "AoE"]
@export var requirements: Dictionary # For Prophecy or conditional cards
