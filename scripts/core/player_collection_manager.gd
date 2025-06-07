extends Node

# --- Card instance structure ---
# {
#     "instance_id": String,       # Unique per-card
#     "base_id": String,           # CardData id
#     "type": String,              # "DivineSoldier", "Levy", "Spell"
#     "pantheon": String,          # For name generation, deck filtering
#     "upgrade_level": int,        # 0 = base
#     "current_hp": int,           # Only for DivineSoldier/Levy
#     "max_hp": int,               # For DivineSoldier/Levy
#     "void_corruption": int,      # Only for DivineSoldier
#     "custom_name": String,       # Only for DivineSoldier
#     "card_data": CardData,       # Reference to resource
#     ... (future fields as needed)
# }

var owned_cards: Array = [] # All card instances owned by player (full collection)

# Divine soldier name stubs per pantheon (expand as needed)
const DIVINE_SOLDIER_NAME_POOLS = {
	"GREEK": ["Alexios", "Dion", "Thaleia", "Eleni", "Petros"],
	"EGYPTIAN": ["Mehmed", "Nefertari", "Khalid", "Layla", "Sahir"],
	"NORSE": ["Astrid", "Bjorn", "Kari", "Leif", "Sigrid"],
	# ...add more pantheons as needed
}

# Utility for generating unique instance IDs
var _last_instance_id: int = 1

func _get_next_instance_id() -> String:
	_last_instance_id += 1
	return "cardinst_%d" % _last_instance_id

# --- API ---

# Add a new card to the player's collection (creates a new instance)
func add_card(base_id: String, type: String, pantheon: String, card_data: Resource, max_hp: int = 0, upgrade_level: int = 0) -> Dictionary:
	var instance = {
		"instance_id": _get_next_instance_id(),
		"base_id": base_id,
		"type": type,
		"pantheon": pantheon,
		"upgrade_level": upgrade_level,
		"card_data": card_data
	}
	if type == "DivineSoldier":
		instance["max_hp"] = max_hp
		instance["current_hp"] = max_hp
		instance["void_corruption"] = 0
		instance["custom_name"] = _generate_divine_soldier_name(pantheon, card_data.name)
	elif type == "Levy":
		instance["max_hp"] = max_hp
		instance["current_hp"] = max_hp
	# Spells: No HP/corruption
	owned_cards.append(instance)
	return instance

# Generate unique Divine Soldier name: {first_name} the {meta_name}
func _generate_divine_soldier_name(pantheon: String, meta_name: String) -> String:
	var pool = DIVINE_SOLDIER_NAME_POOLS.get(pantheon, [])
	if pool.size() > 0:
		var first = pool[randi() % pool.size()]
		return "%s the %s" % [first, meta_name]
	return meta_name # fallback

# Query all instances available for deckbuilding (not dead, not in fallen bin)
func get_available_instances(type: String = "", pantheon: String = "") -> Array:
	var arr = []
	for inst in owned_cards:
		if type != "" and inst.type != type:
			continue
		if pantheon != "" and inst.pantheon != pantheon:
			continue
		# TODO: Exclude dead soldiers in "fallen bin" if relevant
		arr.append(inst)
	return arr

# Query how many of a given base_id are owned (Levy/Spell)
func get_owned_count(base_id: String) -> int:
	var count = 0
	for inst in owned_cards:
		if inst.base_id == base_id:
			count += 1
	return count

# For deck screen: get all instances by base_id that are NOT already in the deck
func get_available_for_deck(base_id: String, current_deck: Array) -> Array:
	var in_deck_ids = current_deck.map(func(e): return e["instance_id"])
	var result = []
	for inst in owned_cards:
		if inst.base_id == base_id and not in_deck_ids.has(inst["instance_id"]):
			result.append(inst)
	return result

# Remove instance from collection (for permadeath, etc)
func remove_instance(instance_id: String):
	for i in range(owned_cards.size()):
		if owned_cards[i]["instance_id"] == instance_id:
			owned_cards.remove_at(i)
			break

# Get instance by ID
func get_instance(instance_id: String) -> Dictionary:
	for inst in owned_cards:
		if inst["instance_id"] == instance_id:
			return inst
	return {}

# Utility: get all dead/fallen Divine Soldiers (for "fallen bin")
func get_fallen_soldiers(dead_ids: Array) -> Array:
	var arr = []
	for inst in owned_cards:
		if inst.type == "DivineSoldier" and dead_ids.has(inst["instance_id"]):
			arr.append(inst)
	return arr

# Utility: clear all fallen soldiers from bin (reset after run ends)
func clear_fallen_bin(dead_ids: Array):
	# Optionally move to legacy pool or just remove from owned_cards
	for id in dead_ids:
		remove_instance(id)

# Utility: reset HP/corruption for all (after Pantheon clear)
func reset_all_card_states():
	for inst in owned_cards:
		if inst.type in ["DivineSoldier", "Levy"]:
			inst["current_hp"] = inst.get("max_hp", 1)
		if inst.type == "DivineSoldier":
			inst["void_corruption"] = 0

# Get all CardData resources for a pantheon and type
static func get_cards_for_pantheon_type(pantheon: String, card_type: int) -> Array:
	var pools = preload("res://scripts/data/cards/card_pools.gd")
	var pool_map = {
		"GREEK": pools.GREEK_PANTHEON,
		"NORSE": pools.NORSE_PANTHEON,
		"EGYPTIAN": pools.EGYPTIAN_PANTHEON,
		# ...add more pantheons as you expand
	}
	var card_pool = pool_map.get(pantheon, [])
	var matches = []
	for card in card_pool:
		if card.type == card_type:
			matches.append(card)
	return matches

# Generate the starting deck for a pantheon: 5 Divine Soldiers, 12 Levies, 5 Spells
func generate_starting_collection(pantheon: String):
	var CardData = preload("res://scripts/data/card_data.gd")
	var card_pools = preload("res://scripts/data/cards/card_pools.gd")
	var pool_map = {
		"GREEK": card_pools.GREEK_PANTHEON,
		"NORSE": card_pools.NORSE_PANTHEON,
		"EGYPTIAN": card_pools.EGYPTIAN_PANTHEON,
		# ...add others as needed
	}
	var card_pool = pool_map.get(pantheon, [])
	if card_pool.is_empty():
		push_error("No card pool found for pantheon: %s" % pantheon)
		return

	# Separate by type
	var divine_soldiers = []
	var levies = []
	var spells = []
	for card in card_pool:
		match card.type:
			CardData.CardType.DIVINE_SOLDIER:
				divine_soldiers.append(card)
			CardData.CardType.LEVY:
				levies.append(card)
			CardData.CardType.SPELL:
				spells.append(card)

	# --- Pick with replacement ---
	# Divine Soldiers (7)
	for i in range(7):
		var pick = divine_soldiers.pick_random()
		add_card(pick.id, "DivineSoldier", pantheon, pick, pick.health)
	# Levies (12)
	for i in range(12):
		var pick = levies.pick_random()
		add_card(pick.id, "Levy", pantheon, pick, pick.health)
	# Spells (5)
	for i in range(5):
		var pick = spells.pick_random()
		add_card(pick.id, "Spell", pantheon, pick)
		
# --- How to use ---
# - Add to autoload as PlayerCollectionManager
# - Use add_card() to add new cards to collection
# - Use get_available_instances() for deck editing
# - Use get_owned_count() and get_available_for_deck() for deck constraints/validation
# - Store deck as array of card instance dicts (with instance_id)
