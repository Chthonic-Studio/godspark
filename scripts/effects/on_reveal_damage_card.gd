extends CardEffect
@export var amount: int = 2

func execute(card: CardData, context: Dictionary) -> void:
	var board = context["board"]
	var location = context["location"]
	var target_side = "enemy" if context["owner"] == "player" else "player"
	# Find the first target in the front row
	for idx in [0, 1]:
		var target = board.board[location][target_side][idx]
		if target:
			target.health -= amount
			if target.health <= 0:
				board.remove_card(location, target_side, idx)
				# Remove from UI
				if Engine.has_singleton("BoardUIManager"):
					var ui = Engine.get_singleton("BoardUIManager")
					ui.remove_card_from_slot(location, target_side, idx)
			break
