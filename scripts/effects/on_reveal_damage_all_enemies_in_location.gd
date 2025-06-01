extends CardEffect
@export var amount: int = 2

func execute(card: CardData, context: Dictionary) -> void:
	var board = context["board"]
	var location = context["location"]
	var target_side = "enemy" if context["owner"] == "player" else "player"
	for idx in [0, 1, 2, 3]:
		var target = board.board[location][target_side][idx]
		if target:
			target.health -= amount
			if target.health <= 0:
				board.remove_card(location, target_side, idx)
				# Call BoardUIManager.remove_card_from_slot if you use direct removal
