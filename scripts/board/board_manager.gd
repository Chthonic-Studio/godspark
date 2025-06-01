extends Node
class_name BoardManager

var silenced_locations: Dictionary = {} # location : bool
var pending_on_play_damage: Dictionary = {} # key: str (location_side), value: damage
var terrain_by_location: Dictionary = {} # e.g. "left": TerrainData

# Structure: board[location][side][slot] = CardData or null
var locations := ["left", "middle", "right"]
var board := {}

signal card_removed(location, side, slot_idx)

func _ready():
	# Failsafe: if the board is empty, set it up
	if board.is_empty():
		setup_board()

# Called once at combat start
func setup_board():
	board.clear()
	silenced_locations.clear()
	pending_on_play_damage.clear()
	for loc in locations:
		board[loc] = {
			"player": [null, null, null, null], # slots 0,1 = front, 2,3 = back
			"enemy": [null, null, null, null]
		}
	print("setup_board called. Current board: ", board)

# Place a card in a given slot (location, side, slot_idx)
func place_card(card: CardData, location: String, side: String, slot_idx: int) -> bool:
	if not board.has(location):
		print("BoardManager: ERROR - board missing location:", location, "Available keys:", board.keys())
		return false
	if not board[location].has(side):
		print("BoardManager: ERROR - board[%s] missing side: %s Available sides: %s" % [location, side, board[location].keys()])
		return false
	if slot_idx < 0 or slot_idx >= board[location][side].size():
		print("BoardManager: ERROR - slot_idx out of range: %d (location: %s, side: %s)" % [slot_idx, location, side])
		return false

	# Check Ongoing Silence before placing card (optional: allow unit play, block effects)
	# If you want to block play entirely, uncomment:
	# if is_location_silenced(location):
	#     print("BoardManager: Cannot play card, location is silenced!")
	#     return false

	if board[location][side][slot_idx] == null:
		board[location][side][slot_idx] = card
		print("BoardManager: Placed card '%s' in %s/%s slot %d" % [card.name, location, side, slot_idx])

		# On Reveal: Damage Next Unit Played
		var key = "%s_%s" % [location, side]
		if pending_on_play_damage.has(key):
			var damage = pending_on_play_damage[key]
			if card.health > 0:
				card.health -= damage
				print("On Reveal: %s takes %d damage" % [card.name, damage])
			# Remove trigger after use
			pending_on_play_damage.erase(key)
		return true
	else:
		print("BoardManager: Slot %d at %s/%s is already occupied (card: %s)" % [slot_idx, location, side, board[location][side][slot_idx].name])
	return false
	
# Remove a card from its slot
func remove_card(location: String, side: String, slot_idx: int):
	board[location][side][slot_idx] = null
	emit_signal("card_removed", location, side, slot_idx)

# Find the first available slot for a side in a location (front/back optional)
func get_available_slot(location: String, side: String, prefer_back: bool=false) -> int:
	if not board.has(location):
		print("ERROR: get_available_slot missing location: ", location)
		return -1
	if not board[location].has(side):
		print("ERROR: get_available_slot missing side: ", side)
		return -1
	var range = [2, 3, 0, 1] if prefer_back else [0, 1, 2, 3]
	print("Checking slots for", location, side, "range:", range)
	for idx in range:
		print("- slot", idx, "=", board[location][side][idx])
		if board[location][side][idx] == null:
			print("-- returning idx", idx)
			return idx
	print("-- No available slot found")
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
# Power calculation with Buff Backrow
func calculate_power(location: String, side: String) -> int:
	var total = 0
	var ongoing_effects = get_ongoing_effects_in_location(location, side)
	var buff_amount = 0
	var buff_slots = []
	for entry in ongoing_effects:
		if entry.effect.effect_name == "BuffBackrow":
			# Buff all backrow except the card itself
			for back_idx in [2, 3]:
				if back_idx != entry.slot:
					buff_slots.append(back_idx)
					buff_amount = entry.effect.power_buff # Adjust property name as needed
	# The power calculation for the cards in this location/side
	for idx in range(board[location][side].size()):
		var card = board[location][side][idx]
		if card:
			var power = card.get_power()
			if idx in buff_slots:
				power += buff_amount
			total += power
	return total

# For UI: Get cards in a location and side, with position info
func get_cards_in_location(location: String, side: String) -> Array:
	var cards = []
	for idx in range(4):
		cards.append({"card": board[location][side][idx], "row": "front" if idx < 2 else "back", "slot_index": idx})
	return cards

# Utility: Check if a location is silenced
func is_location_silenced(location: String) -> bool:
	return silenced_locations.has(location) and silenced_locations[location]

# Helper to detect ongoing effects
func get_ongoing_effects_in_location(location: String, side: String) -> Array:
	var effects = []
	for idx in range(4):
		var card = board[location][side][idx]
		if card:
			for effect in card.effects:
				if effect.is_ongoing():
					effects.append({"effect": effect, "slot": idx, "card": card})
	return effects

# Call once each at end of player and enemy turn
func resolve_ongoing_effects():
	for loc in locations:
		for side in ["player", "enemy"]:
			for idx in range(4):
				var card = board[loc][side][idx]
				if card:
					for effect in card.effects:
						if effect.is_ongoing() and effect.has_method("on_end_turn"):
							# You can pass context as needed
							var context = {
								"board": self,
								"location": loc,
								"side": side,
								"slot_idx": idx,
								"card": card
							}
							effect.on_end_turn(card, context)

func setup_terrain(terrain_assignments: Dictionary):
	# terrain_assignments: {"left": TerrainData, "middle": TerrainData, "right": TerrainData}
	terrain_by_location = terrain_assignments.duplicate()

# Call at end of turn, before power/damage resolution
func resolve_terrain_end_of_turn_triggers():
	for location in locations:
		var terrain = terrain_by_location.get(location, null)
		if terrain == null:
			continue
		for trigger in terrain.triggers:
			if trigger.get("event", "") == "on_end_turn":
				_process_terrain_trigger(location, terrain, trigger)

# Helper: process one trigger for one location
func _process_terrain_trigger(location: String, terrain: TerrainData, trigger: Dictionary) -> void:
	var effect = trigger.get("effect", "")
	var amount = int(trigger.get("amount", 0))
	var side = trigger.get("side", "both") # "player", "enemy", or "both"

	if effect == "heal_lowest":
		for s in (["player", "enemy"] if side == "both" else [side]):
			var lowest_hp = INF
			var lowest_idx = -1
			for idx in range(4):
				var card = board[location][s][idx]
				if card and card.health < lowest_hp:
					lowest_hp = card.health
					lowest_idx = idx
			if lowest_idx != -1:
				board[location][s][lowest_idx].health += amount
	elif effect == "damage_all":
		for s in (["player", "enemy"] if side == "both" else [side]):
			for idx in range(4):
				var card = board[location][s][idx]
				if card:
					card.health -= amount
					if card.health <= 0:
						remove_card(location, s, idx)
	elif effect == "add_void_corruption":
		for s in (["player", "enemy"] if side == "both" else [side]):
			for idx in range(4):
				var card = board[location][s][idx]
				if card and card.has_method("apply_void_corruption"):
					card.apply_void_corruption(amount)
	elif effect == "olympus_odd_turn":
		# Only trigger on odd turns
		if has_node("/root/CombatScene/CombatManager"):
			var cm = get_node("/root/CombatScene/CombatManager")
			if cm.turn % 2 == 1:
				for s in (["player", "enemy"] if side == "both" else [side]):
					for idx in range(4):
						var card = board[location][s][idx]
						if card:
							if randi() % 2 == 0:
								# +1 power (temporary, for 1 turn)
								if not card.has_meta("temp_buffs"):
									card.set_meta("temp_buffs", [])
								var buffs = card.get_meta("temp_buffs")
								buffs.append({ "stat": "power", "amount": 1, "turns_left": 1 })
								card.set_meta("temp_buffs", buffs)
							else:
								# -1 health
								card.health = max(0, card.health - 1)
								# Optionally handle unit death here
								if card.health == 0:
									remove_card(location, s, idx)
									
func decrement_and_cleanup_temporary_buffs():
	for location in locations:
		for side in ["player", "enemy"]:
			for idx in range(4):
				var card = board[location][side][idx]
				if card and card.has_meta("temp_buffs"):
					var buffs = card.get_meta("temp_buffs")
					# Decrement durations
					for buff in buffs:
						buff["turns_left"] = buff.get("turns_left", 0) - 1
					# Remove expired
					buffs = buffs.filter(func(b): return b.get("turns_left", 0) > 0)
					card.set_meta("temp_buffs", buffs)
