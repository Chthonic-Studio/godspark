extends CardEffect

func execute(card: CardData, context: Dictionary) -> void:
	var board = context["board"]
	var location = context["location"]
	var side = context["owner"]
	for idx in [0, 1, 2, 3]:
		var ally = board.board[location][side][idx]
		if ally:
			if ally.has("poison_turns"):
				ally.poison_turns = 0
			# Remove other debuffs as needed
