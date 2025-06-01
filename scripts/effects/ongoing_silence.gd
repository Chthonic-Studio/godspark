extends CardEffect
func is_ongoing() -> bool:
	return true

func _init():
	effect_name = "Silence"

func execute(card: CardData, context: Dictionary) -> void:
	var board = context["board"]
	var location = context["location"]
	board.silenced_locations[location] = true
