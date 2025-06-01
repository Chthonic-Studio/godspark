extends Node
class_name EnemyDeckManager

var draw_pile: Array[CardData] = []
var discard_pile: Array[CardData] = []
var hand: Array[CardData] = []
var max_hand_size: int = 7

var debug_generate_test_cards := true

func _ready():
	if debug_generate_test_cards and draw_pile.is_empty() and hand.is_empty():
		_generate_test_cards()

func _generate_test_cards():
	# Generates 5 simple test CardData resources for debugging.
	var test_cards: Array[CardData] = []
	for i in range(5):
		var card = CardData.new()
		card.id = "enemy_test_%d" % i
		card.name = "Enemy Card %d" % i
		card.description = "A debug enemy card."
		card.type = "SoldierAttack"
		card.cost = i % 3 + 1
		card.effects.clear()
		card.tags.clear()
		card.requirements = {}
		test_cards.append(card)
	setup_deck(test_cards)
	draw_cards(max_hand_size)

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
		discard_pile.append(hand.pop_front())

func play_card(card: CardData) -> void:
	hand.erase(card)
	discard_pile.append(card)

func reshuffle_discard_into_draw() -> void:
	if discard_pile.is_empty():
		return
	draw_pile = discard_pile.duplicate()
	discard_pile.clear()
	shuffle_draw_pile()
