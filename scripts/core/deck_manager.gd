extends Node

var draw_pile: Array[Dictionary] = []
var discard_pile: Array[Dictionary] = []
var hand: Array[Dictionary] = []
var max_hand_size: int = 7

func _ready():
	if GameManager.dev_mode and draw_pile.is_empty() and hand.is_empty():
		_generate_test_cards()

func start_game():
	shuffle_draw_pile()
	draw_cards(3)
	
func _generate_test_cards():
	var test_cards: Array[Dictionary] = []
	for i in range(5):
		var card = CardData.new()
		card.id = "test_%d" % i
		card.name = "Test Card %d" % i
		card.description = "A debug card for prototyping."
		card.power = i % 3 + 1
		card.health = i % 7 + 2
		card.type = "SoldierAttack"
		card.cost = i % 3 + 1
		card.effects.clear()
		card.tags.clear()
		card.requirements = {}
		test_cards.append({
			"instance_id": "test_%d" % i,
			"card_data": card,
			"type": card.type,
			"current_hp": card.health
		}) # <--- This is a dictionary!
	setup_deck(test_cards)
	draw_cards(max_hand_size)

# Accepts a list of card instance dictionaries (from PantheonRunManager.player_deck or deck editor)
func setup_deck(card_instance_list: Array[Dictionary]) -> void:
	draw_pile = card_instance_list.duplicate(true)
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

func play_card(card_instance: Dictionary) -> void:
	# Remove card from hand by unique instance_id
	for i in range(hand.size()):
		if hand[i]["instance_id"] == card_instance["instance_id"]:
			discard_pile.append(hand[i])
			hand.remove_at(i)
			return
	print("WARNING: Tried to play a card not found in hand (id:", card_instance.get("instance_id", "???"), ")")

func reshuffle_discard_into_draw() -> void:
	if discard_pile.is_empty():
		return
	draw_pile = discard_pile.duplicate(true)
	discard_pile.clear()
	shuffle_draw_pile()
