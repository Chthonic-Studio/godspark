extends Node

var draw_pile: Array[CardData] = []
var discard_pile: Array[CardData] = []
var hand: Array[CardData] = []
var max_hand_size: int = 7

var debug_generate_test_cards := true

func _ready():
	if debug_generate_test_cards and draw_pile.is_empty() and hand.is_empty():
		_generate_test_cards()

func start_game():
	shuffle_draw_pile()
	draw_cards(3)
	
func _generate_test_cards():
	# Generates 5 simple test CardData resources for debugging.
	var test_cards: Array[CardData] = []
	for i in range(5):
		var card = CardData.new()
		card.id = "test_%d" % i
		card.name = "Test Card %d" % i
		card.description = "A debug card for prototyping."
		card.power = i % 3 + 1
		card.health = i % 7 + 2
		card.type = "SoldierAttack"
		card.cost = i % 3 + 1
		card.effects.clear() # <- FIX: clear instead of assigning a new array
		card.tags.clear()
		card.requirements = {}
		test_cards.append(card)
	setup_deck(test_cards)
	draw_cards(max_hand_size) # Ensures hand is filled at start

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
	# Remove card from hand by ID, not by reference
	for i in range(hand.size()):
		if hand[i].id == card.id:
			discard_pile.append(hand[i])
			hand.remove_at(i)
			return
	print("WARNING: Tried to play a card not found in hand (id:", card.id, ")")
	# Card effect processing: call combat system

func reshuffle_discard_into_draw() -> void:
	if discard_pile.is_empty():
		return
	draw_pile = discard_pile.duplicate()
	discard_pile.clear()
	shuffle_draw_pile()
