extends CardEffect
@export var amount: int = 2

func execute(card: CardData, context: Dictionary) -> void:
	var board = context["board"]
	var location = context["location"]
	var side = context["owner"]
	for idx in [0, 1, 2, 3]:
		var ally = board.board[location][side][idx]
		if ally:
			ally.health += amount # Cap at max if you wish
