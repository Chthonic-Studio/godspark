extends CardEffect
@export var amount: int = 1
@export var turns: int = 2

func execute(card: CardData, context: Dictionary) -> void:
	var board = context["board"]
	var location = context["location"]
	var target_side = "enemy" if context["owner"] == "player" else "player"
	for idx in [0, 1, 2, 3]:
		var target = board.board[location][target_side][idx]
		if target:
			# Safely get or create temp_buffs array
			var debuffs = target.get_meta("temp_buffs") if target.has_meta("temp_buffs") else []
			debuffs.append({
				"stat": "power",
				"amount": -amount,
				"turns_left": turns
			})
			target.set_meta("temp_buffs", debuffs)
