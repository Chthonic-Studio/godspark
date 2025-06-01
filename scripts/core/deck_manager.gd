extends Node

var draw_pile: Array[CardData] = []
var discard_pile: Array[CardData] = []
var hand: Array[CardData] = []
var max_hand_size: int = 5

func setup_deck(card_list: Array[CardData]) -> void:
	draw_pile = card_list.duplicate()
	discard_pile.clear()
	hand.clear()
	shuffle_draw_pile()

func shuffle_draw_pile() -> void:
	draw_pile.shuffle()

func draw_cards(amount: int) -> void:
	for i in amount:
		if draw_pile.is_empty():
			reshuffle_discard_into_draw()
		if draw_pile.is_empty():
			break
		hand.append(draw_pile.pop_back())
	while hand.size() > max_hand_size:
		discard_pile.append(hand.pop_front()) # Optionally discard excess

func play_card(card: CardData) -> void:
	hand.erase(card)
	discard_pile.append(card)
	# Card effect processing: call combat system

func reshuffle_discard_into_draw() -> void:
	draw_pile = discard_pile.duplicate()
	discard_pile.clear()
	shuffle_draw_pile()
