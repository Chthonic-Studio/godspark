extends CardEffect
@export var amount: int = 1
@export var turns: int = 1

func execute(card: CardData, context: Dictionary) -> void:
	var board = context["board"]
	var location = context["location"]
	var target_side = "enemy" if context["owner"] == "player" else "player"
	for idx in [0, 1, 2, 3]:
		var target = board.board[location][target_side][idx]
		if target:
			target.power = max(0, target.power - amount)
			# Optionally: add a duration system for temporary debuffs
