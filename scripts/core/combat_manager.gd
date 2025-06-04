extends Node

@export var board_manager: BoardManager
@export var hand_manager: HandManager
@export var enemy_deck_manager: EnemyDeckManager
@export var board_ui_manager: BoardUIManager
@export var player_health: int = 100
@export var enemy_health: int = 100

var turn: int = 1
var phase: String = "PlayerTurn"
var divinity: int = 10 # Faith for playing cards

# Hold terrain assignments for this combat
var current_terrain_assignments: Dictionary = {}

var DEBUG_FAKE_TERRAIN := true

signal divinity_changed
signal phase_changed
signal turn_changed

# Called once at combat start
func start_combat():
	
	# Fallback: For direct testing, if current_terrain_assignments is empty, assign test terrain
	if (not current_terrain_assignments or current_terrain_assignments.is_empty()) and DEBUG_FAKE_TERRAIN:
		# Only for debug! Replace with real terrain assignments via PantheonRunManager in-game.
		var TerrainPool = preload("res://scripts/data/terrain_pools.gd")
		current_terrain_assignments = {
			"left": TerrainPool.VOID_TERRAIN_POOL["THE DREAMING MAW"][0],
			"middle": TerrainPool.PANTHEON_TERRAIN_POOLS["GREEK"][0],
			"right": TerrainPool.PANTHEON_TERRAIN_POOLS["GREEK"][0],
		}
		print("DEBUG: Assigned fake terrain for direct scene test.")
	# Called once at combat start.
	# In campaign flow: call assign_terrain_from_run() before this to set up terrain.
	# In direct scene test: set DEBUG_FAKE_TERRAIN = true to use hardcoded test terrrain.
	if current_terrain_assignments and not current_terrain_assignments.is_empty():
		board_manager.setup_terrain(current_terrain_assignments)
		print("CombatManager: Terrain assignments:", current_terrain_assignments)
	else:
		print("WARNING: No terrain assignments set for this combat!")
	board_manager.setup_board()
	board_ui_manager.update_power_labels()
	
	var player_bar = $"../PlayerHUD/PlayerHealthBar"
	print("Player health bar: " + str(player_bar))
	player_bar.fade_in()
	player_bar.set_health(player_health)

	var enemy_bar = $"../EnemyHUD/EnemyHealthBar"
	print("Player health bar: " + str(enemy_bar))
	enemy_bar.fade_in()
	enemy_bar.set_health(enemy_health)
	
	DeckManager.start_game()
	enemy_deck_manager.draw_cards(3)
	phase = "PlayerTurn"
	divinity = 10
	turn = 1
	emit_signal("phase_changed")
	emit_signal("turn_changed")

func end_player_turn():
	# (Resolve end-of-turn effects, etc. as needed)
	phase = "EnemyTurn"
	board_ui_manager.update_power_labels()
	emit_signal("phase_changed")
	call_deferred("enemy_turn")

func enemy_turn():
	enemy_deck_manager.draw_cards(1)
	for location in board_manager.locations:
		var slot = board_manager.get_available_slot(location, "enemy")
		if slot != -1 and enemy_deck_manager.hand.size() > 0:
			var card = enemy_deck_manager.hand[0]
			board_manager.place_card(card, location, "enemy", slot)
			enemy_deck_manager.play_card(card)
			board_ui_manager.update_power_labels()
			if has_node("/root/CombatScene/BoardPanel/BoardUIManager"):
				var board_ui = get_node("/root/CombatScene/BoardPanel/BoardUIManager")
				board_ui.add_enemy_card_to_slot(card, location, slot)
			# --- ADD: Execute enemy card effects ---
			for effect in card.effects:
				if board_manager.is_location_silenced(location) and effect.effect_name != "Silence":
					print("Effect skipped due to ongoing Silence at location %s" % location)
					continue
				if effect is CardEffect:
					var context = {
						"combat_manager": self,
						"board": board_manager,
						"owner": "enemy",
						"location": location,
						"slot_idx": slot
					}
					effect.execute(card, context)
			break
	phase = "Resolution"
	call_deferred("resolve_turn")
	emit_signal("phase_changed")

func resolve_turn():
	board_manager.resolve_ongoing_effects()
	board_manager.resolve_terrain_end_of_turn_triggers()
	board_manager.decrement_and_cleanup_temporary_buffs()
	
	if turn >= 4:
		var player_total = 0
		var enemy_total = 0
		for loc in board_manager.locations:
			var player_power = board_manager.calculate_power(loc, "player")
			var enemy_power = board_manager.calculate_power(loc, "enemy")
			# UI: update power labels
			if has_node("/root/CombatScene/BoardPanel/BoardUIManager"):
				get_node("/root/CombatScene/BoardPanel/BoardUIManager").update_power_labels()
			if player_power > enemy_power:
				enemy_total += player_power - enemy_power
			elif enemy_power > player_power:
				player_total += enemy_power - player_power
			# (no damage if equal)
		player_health -= player_total
		enemy_health -= enemy_total
		# Update health bars visually after health changes
		if has_node("/root/CombatScene/PlayerHUD/PlayerHealthBar"):
			var player_bar = get_node("/root/CombatScene/PlayerHUD/PlayerHealthBar")
			player_bar.set_health(player_health)
		if has_node("/root/CombatScene/EnemyHUD/EnemyHealthBar"):
			var enemy_bar = get_node("/root/CombatScene/EnemyHUD/EnemyHealthBar")
			enemy_bar.set_health(enemy_health)
			
	
	check_end_conditions()

	# Prepare for next turn
	turn += 1
	emit_signal("turn_changed")
	phase = "PlayerTurn"
	DeckManager.draw_cards(1)
	divinity += 1
	hand_manager.refresh_hand()
	board_ui_manager.update_power_labels()
	emit_signal("divinity_changed")
	emit_signal("phase_changed")

func play_card(card: CardData, location: String, slot_idx: int = -1) -> String:
	if divinity < card.cost:
		return "Not enough Divinity!"
	if slot_idx == -1:
		slot_idx = board_manager.get_available_slot(location, "player", card.type == "Spell")
		if slot_idx == -1:
			return "Location is full!"
	var placement_success = board_manager.place_card(card, location, "player", slot_idx)
	if not placement_success:
		return "That slot is already occupied!"
	divinity -= card.cost
	emit_signal("divinity_changed")
	DeckManager.play_card(card)
	for effect in card.effects:
		# Skip all effects if location is silenced, except for silence itself
		if board_manager.is_location_silenced(location) and effect.effect_name != "Silence":
			print("Effect skipped due to ongoing Silence at location %s" % location)
			continue
		var context = {
			"combat_manager": self,
			"board": board_manager,
			"owner": "player",
			"location": location,
			"slot_idx": slot_idx,
			"enemy_deck_manager": enemy_deck_manager
		}
		effect.execute(card, context)
	board_ui_manager.update_power_labels()
	return "success"

func deal_commander_damage(target: String, amount: int):
	if target == "enemy":
		enemy_health -= amount
	elif target == "player":
		player_health -= amount

func check_end_conditions():
	if player_health <= 0:
		defeat()
	elif enemy_health <= 0:
		victory()

func victory():
	# Handle victory logic, faith reward, etc.
	pass

func defeat():
	# Handle defeat logic, soldier loss, etc.
	pass

func set_terrain_assignments(terrain_assignments: Dictionary) -> void:
	current_terrain_assignments = terrain_assignments

# Call this from campaign/pantheon flow before start_combat to set up terrain using PantheonRunManager and ZoneGenerator.
func assign_terrain_from_run():
	if not PantheonRunManager.current_run_active:
		print("PantheonRunManager: No active run, skipping terrain assignment.")
		return
	var node_terrain = PantheonRunManager.get_current_node_terrains()
	var player_terrains = PantheonRunManager.player_terrain_cards
	if player_terrains.size() != 3:
		print("CombatManager: Player must have exactly 3 terrain cards selected!")
		return
	player_terrains.shuffle()
	var selected_terrain = player_terrains[0]
	PantheonRunManager.set_player_terrain_for_current_combat(selected_terrain)
	var zone_gen = get_node_or_null("/root/CombatScene/ZoneGenerator")
	if not zone_gen:
		print("CombatManager: ZoneGenerator node not found in scene!")
		return
	var terrain_assignment = zone_gen.get_combat_terrain_assignment(node_terrain, selected_terrain)
	set_terrain_assignments(terrain_assignment)

# When you implement AI, simply call the same BoardUIManager function for the enemy side:
# Example call from CombatManager or AI logic:
# $BoardUIManager.add_card_to_slot(enemy_card_data, location, "enemy", slot_idx, card_ui_scene)
