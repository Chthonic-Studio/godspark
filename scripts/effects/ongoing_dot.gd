extends CardEffect
@export var damage: int = 1
@export var turns: int = 3

func execute(card: CardData, context: Dictionary) -> void:
	var board = context["board"]
	var location = context["location"]
	var target_side = "enemy" if context["owner"] == "player" else "player"
	for idx in [0, 1, 2, 3]:
		var target = board.board[location][target_side][idx]
		if target:
			if not target.has("poison_turns"):
				target.poison_turns = 0
			target.poison_turns = turns
			target.poison_damage = damage
