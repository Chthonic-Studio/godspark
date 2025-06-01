extends CardEffect
@export var shield_amount: int = 3

func execute(card: CardData, context: Dictionary) -> void:
	var board = context["board"]
	var location = context["location"]
	var side = context["owner"]
	for idx in [0, 1, 2, 3]:
		var ally = board.board[location][side][idx]
		if ally:
			ally.shield = shield_amount # Implement shield logic in damage resolution
