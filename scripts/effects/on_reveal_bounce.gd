extends CardEffect

func _init():
	effect_name = "OnRevealBounce"

func execute(card: CardData, context: Dictionary) -> void:
	var board = context["board"]
	var location = context["location"]
	for side in ["player", "enemy"]:
		var hand = DeckManager.hand if side == "player" else context["enemy_deck_manager"].hand
		var max_hand = DeckManager.max_hand_size if side == "player" else context["enemy_deck_manager"].max_hand_size
		var bounced = []
		for idx in [0, 1, 2, 3]:
			var unit = board.board[location][side][idx]
			if unit and unit != card:
				if hand.size() < max_hand:
					hand.append(unit)
					bounced.append(idx)
		for idx in bounced:
			board.remove_card(location, side, idx)
		# Repack remaining units
		var new_row = []
		for idx in [0, 1, 2, 3]:
			var unit = board.board[location][side][idx]
			if unit:
				new_row.append(unit)
		for i in range(4):
			board.board[location][side][i] = new_row[i] if i < new_row.size() else null
		# UI sync: call BoardUIManager.remove_card_from_slot for each bounced idx and reposition remaining CardUIs
