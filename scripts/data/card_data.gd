extends Resource
class_name CardData

@export var id: String
@export var name: String
@export var description: String
@export var type: String # "SoldierAttack", etc.
@export var cost: int
@export var effects: Array[CardEffect] # <- THIS LINE CHANGED
@export var tags: Array[String]
@export var requirements: Dictionary
