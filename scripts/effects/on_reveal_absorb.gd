extends CardEffect
@export var damage: int = 2

func _init():
	effect_name = "OnRevealAbsorb"

func execute(card: CardData, context: Dictionary) -> void:
	var board = context["board"]
	var location = context["location"]
	var owner = context["owner"]
	var enemy = "enemy" if owner == "player" else "player"
	var total_absorbed = 0
	for idx in [0, 1, 2, 3]:
		var unit = board.board[location][enemy][idx]
		if unit:
			var pre_hp = unit.health
			unit.health -= damage
			var dealt = min(damage, pre_hp)
			if unit.health <= 0:
				board.remove_card(location, enemy, idx)
			total_absorbed += dealt
	card.health += total_absorbed
