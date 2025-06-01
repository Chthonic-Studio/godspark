extends Node
class_name BoardManager

# Structure: board[location][side][slot] = CardData or null
var locations := ["left", "middle", "right"]
var board := {}

func _ready():
	# Failsafe: if the board is empty, set it up
	if board.is_empty():
		setup_board()

# Called once at combat start
func setup_board():
	board.clear()
	for loc in locations:
		board[loc] = {
			"player": [null, null, null, null], # slots 0,1 = front, 2,3 = back
			"enemy": [null, null, null, null]
		}
	print("setup_board called. Current board: ", board)

# Place a card in a given slot (location, side, slot_idx)
func place_card(card: CardData, location: String, side: String, slot_idx: int) -> bool:
	if not board.has(location):
		print("ERROR: board missing location: ", location, " available: ", board.keys())
		return false
	if not board[location].has(side):
		print("ERROR: board[", location, "] missing side: ", side, " available: ", board[location].keys())
		return false
	if slot_idx < 0 or slot_idx >= board[location][side].size():
		print("ERROR: slot_idx out of range: ", slot_idx)
		return false
	if board[location][side][slot_idx] == null:
		board[location][side][slot_idx] = card
		return true
	return false
	
# Remove a card from its slot
func remove_card(location: String, side: String, slot_idx: int) -> void:
	board[location][side][slot_idx] = null

# Find the first available slot for a side in a location (front/back optional)
func get_available_slot(location: String, side: String, prefer_back: bool=false) -> int:
	if not board.has(location):
		print("ERROR: get_available_slot missing location: ", location)
		return -1
	if not board[location].has(side):
		print("ERROR: get_available_slot missing side: ", side)
		return -1
	var range = [2, 3, 0, 1] if prefer_back else [0, 1, 2, 3]
	for idx in range:
		if board[location][side][idx] == null:
			return idx
	return -1

# Move card from one slot to another (for effects)
func move_card(from_loc, from_side, from_idx, to_loc, to_side, to_idx) -> bool:
	var card = board[from_loc][from_side][from_idx]
	if card and board[to_loc][to_side][to_idx] == null:
		board[from_loc][from_side][from_idx] = null
		board[to_loc][to_side][to_idx] = card
		return true
	return false

# Calculate total power for a side in a location
func calculate_power(location: String, side: String) -> int:
	var total = 0
	for card in board[location][side]:
		if card:
			total += card.get_power() # CardData should have get_power()
	return total

# For UI: Get cards in a location and side, with position info
func get_cards_in_location(location: String, side: String) -> Array:
	var cards = []
	for idx in range(4):
		cards.append({"card": board[location][side][idx], "row": "front" if idx < 2 else "back", "slot_index": idx})
	return cards
