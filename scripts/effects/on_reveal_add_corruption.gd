extends CardEffect
@export var amount: int = 2

func execute(card: CardData, context: Dictionary) -> void:
	var board = context["board"]
	var location = context["location"]
	var target_side = "enemy" if context["owner"] == "player" else "player"
	for idx in [0, 1, 2, 3]:
		var target = board.board[location][target_side][idx]
		if target and target.has_method("apply_void_corruption"):
			target.apply_void_corruption(amount)
