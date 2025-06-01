extends CardEffect
@export var damage_reduction: int = 2

func is_ongoing() -> bool:
	return true

func _init():
	effect_name = "TauntBackrow"

func execute(card: CardData, context: Dictionary) -> void:
	pass # Logic handled in BoardManager.apply_damage
