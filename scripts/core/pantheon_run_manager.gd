extends Node

# ========== DATA STRUCTURES ==========
var liberated_pantheons: Array[String] = []
var void_pantheons_used: Array[String] = []
var current_run_active: bool = false

var available_pantheons = []
var available_void_pantheons = []

var current_pantheon: String = ""
var current_void_pantheon: String = ""
var current_node_index: int = 0
var current_node_terrains: Array[Dictionary] = [] # 5 nodes: [{pantheon: TerrainData, void: TerrainData, player: TerrainData}, ...]

var player_deck: Array[Dictionary] = []
var player_terrain_cards: Array[Resource] = [] # 3 TerrainData
var available_player_terrain_cards: Array[Resource] = []
var dead_soldiers: Array[String] = [] # Card IDs of fallen soldiers (removed after defeat)
var run_seed: int = 0

# ========== SIGNALS ==========
signal run_started
signal pantheon_selected(pantheon_name)
signal node_unlocked(node_idx)
signal combat_ready(node_idx)
signal combat_cleared(node_idx)
signal pantheon_cleared(pantheon_name)
signal run_abandoned

# ========== PUBLIC INTERFACE ==========


# ========== TESTING VARIABLES ==========

var isTest: bool = true

func _ready() -> void:
	if isTest == true:
		start_new_run()
	else:
		pass
		
# Call to start a new run
func start_new_run(seed: int = 0):
	liberated_pantheons.clear()
	void_pantheons_used.clear()
	current_run_active = true
	current_pantheon = ""
	current_void_pantheon = ""
	current_node_index = 0
	current_node_terrains.clear()
	player_deck.clear()
	player_terrain_cards.clear()
	dead_soldiers.clear()
	run_seed = seed if seed != 0 else randi()
	randomize()
	for pantheon in preload("res://scripts/data/pantheon_list.gd").PANTHEONS:
		available_pantheons.append(pantheon)
	var terrain_pools = preload("res://scripts/data/terrain_pools.gd")
	available_void_pantheons = terrain_pools.VOID_TERRAIN_POOL.keys().duplicate()
	print("Available void pantheons at start:", available_void_pantheons)
	available_player_terrain_cards.clear()
	# Assign 4 random unique terrains from a specific pool
	var player_pool = preload("res://scripts/data/terrain_pools.gd").PLAYER_TERRAIN_POOL.duplicate()
	player_pool.shuffle()
	for i in range(min(4, player_pool.size())):
		available_player_terrain_cards.append(player_pool[i])
	emit_signal("run_started")

# Called when the player picks a pantheon from campaign screen
func select_pantheon(pantheon_name: String):
	current_pantheon = pantheon_name
	available_pantheons.erase(pantheon_name)
	# Filter for unused void pantheons
	var pool = available_void_pantheons.filter(func(p): return not void_pantheons_used.has(p))
	if pool.is_empty():
		push_error("No available void pantheons remain for this run. Cannot assign a void pantheon to this selection.")
		emit_signal("pantheon_selected", null)
		return
	current_void_pantheon = pool[randi() % pool.size()]
	void_pantheons_used.append(current_void_pantheon)
	_generate_pantheon_nodes()
	current_node_index = 0
	print("Filtered available void pantheons:", pool)
	emit_signal("pantheon_selected", pantheon_name)

# Returns the current node's terrain assignment (for ZoneGenerator/CombatManager)
func get_current_node_terrains() -> Dictionary:
	if current_node_terrains.size() > current_node_index:
		return current_node_terrains[current_node_index]
	return {}

# After clearing a combat node, advance to next node
func advance_to_next_node():
	current_node_index += 1
	if current_node_index >= current_node_terrains.size():
		# Pantheon cleared
		liberated_pantheons.append(current_pantheon)
		emit_signal("pantheon_cleared", current_pantheon)
	else:
		emit_signal("node_unlocked", current_node_index)

# Called after combat, with result: "victory" or "defeat"
func on_combat_result(result: String, fallen_cards: Array[String]=[]):
	if result == "victory":
		emit_signal("combat_cleared", current_node_index)
		advance_to_next_node()
	elif result == "defeat":
		# Remove dead soldiers from deck
		for card_id in fallen_cards:
			player_deck = player_deck.filter(func(cd): return cd.id != card_id)
			dead_soldiers.append(card_id)
		# Stay on current node, can retry

# Called when player abandons run
func abandon_run():
	current_run_active = false
	player_deck.clear()
	player_terrain_cards.clear()
	liberated_pantheons.clear()
	void_pantheons_used.clear()
	current_pantheon = ""
	current_void_pantheon = ""
	current_node_index = 0
	current_node_terrains.clear()
	dead_soldiers.clear()
	emit_signal("run_abandoned")
	
func validate_deck(deck: Array) -> Dictionary:
	# Returns { "valid": bool, "error": String, "type_counts": {type: count}, "deck_size": int }
	const DECK_SIZE = 14
	const TYPE_LIMITS = {
		"DivineSoldier": { "min": 3, "max": 5 },
		"Levy": { "min": 6, "max": 10 },
		"Spell": { "min": 1, "max": 3 }
	}
	var counts = { "DivineSoldier": 0, "Levy": 0, "Spell": 0 }
	var seen_soldiers := {}
	for inst in deck:
		var t = inst.get("type", "Levy")
		if t in counts:
			counts[t] += 1
		if t == "DivineSoldier":
			if seen_soldiers.has(inst["base_id"]):
				return { "valid": false, "error": "Divine Soldier %s is unique and already in deck." % inst["custom_name"], "type_counts": counts, "deck_size": deck.size() }
			seen_soldiers[inst["base_id"]] = true
	# Enforce deck size
	if deck.size() != DECK_SIZE:
		return { "valid": false, "error": "Deck must have exactly %d cards." % DECK_SIZE, "type_counts": counts, "deck_size": deck.size() }
	# Enforce type min/max
	for k in counts:
		if counts[k] < TYPE_LIMITS[k]["min"]:
			return { "valid": false, "error": "Not enough %ss." % k, "type_counts": counts, "deck_size": deck.size() }
		if counts[k] > TYPE_LIMITS[k]["max"]:
			return { "valid": false, "error": "Too many %ss." % k, "type_counts": counts, "deck_size": deck.size() }
	return { "valid": true, "error": "", "type_counts": counts, "deck_size": deck.size() }

# ========== INTERNAL HELPERS ==========

func _generate_pantheon_nodes():
	# Each pantheon: 5 combat nodes. Assign 1 terrain from pantheon, 1 from void, right from player (chosen at combat).
	var terrain_pools = preload("res://scripts/data/terrain_pools.gd")
	var pantheon_terrains = terrain_pools.PANTHEON_TERRAIN_POOLS.get(current_pantheon, []).duplicate()
	pantheon_terrains.shuffle()
	var void_terrains = terrain_pools.VOID_TERRAIN_POOL.get(current_void_pantheon, []).duplicate()
	void_terrains.shuffle()
	current_node_terrains.clear()
	for i in range(5):
		current_node_terrains.append({
			"pantheon": pantheon_terrains[i],
			"void": void_terrains[i],
			"player": null # Filled at combat start via terrain card shuffle
		})

# At combat start, call this with the player's shuffled terrain cards
func set_player_terrain_for_current_combat(selected_terrain: Resource):
	if current_node_terrains.size() > current_node_index:
		current_node_terrains[current_node_index]["player"] = selected_terrain

# Save/Load helpers can be added here (or handled in GameManager)
