extends CardEffect
@export var target_location: String = "middle" # or pass via context

func execute(card: CardData, context: Dictionary) -> void:
	var board = context["board"]
	var from_location = context["location"]
	var slot_idx = context["slot_idx"]
	var side = context["owner"]
	var to_location = target_location
	var to_idx = board.get_available_slot(to_location, side)
	if to_idx != -1:
		board.move_card(from_location, side, slot_idx, to_location, side, to_idx)
		# Update UI as needed
