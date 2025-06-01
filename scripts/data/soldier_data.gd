extends Resource
class_name DivineSoldierData

@export var id: String
@export var name: String
@export var pantheon: String
@export var max_hp: int
@export var base_stats: Dictionary # "attack", "defense", etc.
@export var abilities: Array[String] # For passive/active skills
@export var traits: Array[String]
@export var starting_cards: Array[Resource] # CardData resources
@export var ascension_rank: int
@export var void_corruption: int
