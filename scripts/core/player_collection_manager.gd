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

# --- How to use ---
# - Add to autoload as PlayerCollectionManager
# - Use add_card() to add new cards to collection
# - Use get_available_instances() for deck editing
# - Use get_owned_count() and get_available_for_deck() for deck constraints/validation
# - Store deck as array of card instance dicts (with instance_id)
