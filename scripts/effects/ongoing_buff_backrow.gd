extends CardEffect
@export var power_buff: int = 2

func _init():
	effect_name = "BuffBackrow"

func is_ongoing() -> bool:
	return true

func execute(card: CardData, context: Dictionary) -> void:
	pass # Logic handled in BoardManager.calculate_power
