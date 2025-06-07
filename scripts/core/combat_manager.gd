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

signal divinity_changed
signal phase_changed
signal turn_changed

# Called once at combat start
func start_combat():
	print("\n=== COMBAT SCENE DEBUG ===")
	print("PantheonRunManager.current_run_active:", PantheonRunManager.current_run_active)
	print("PantheonRunManager.current_node_index:", PantheonRunManager.current_node_index)
	print("PantheonRunManager.current_node_terrains:", PantheonRunManager.current_node_terrains)
	print("PantheonRunManager.player_deck (size):", PantheonRunManager.player_deck.size())
	print("PantheonRunManager.player_terrain_cards (size):", PantheonRunManager.player_terrain_cards.size())
	print("PantheonRunManager.current_void_pantheon:", PantheonRunManager.current_void_pantheon)
	print("==========================\n")

	if PantheonRunManager.current_run_active:
		# --- CAMPAIGN/DEMO MODE ---
		var node_terrain = PantheonRunManager.get_current_node_terrains()
		print("node_terrain at combat start:", node_terrain)
		
		# Make sure player terrain is assigned for this node
		if node_terrain.has("void") and node_terrain.has("pantheon") and node_terrain.has("player") and node_terrain["player"] != null:
			# Use ZoneGenerator to build a proper assignment
			var zone_gen = get_node_or_null("/root/CombatScene/ZoneGenerator")
			if not zone_gen:
				print("ERROR: ZoneGenerator node not found in scene!")
				current_terrain_assignments = {}
			else:
				current_terrain_assignments = zone_gen.get_combat_terrain_assignment(
					node_terrain,
					node_terrain["player"]
				)
				print("current_terrain_assignments for board:", current_terrain_assignments)
		else:
			print("WARNING: Terrain assignments incomplete for this node! node_terrain:", node_terrain)
			current_terrain_assignments = {}
		
		# Terrain and board setup
		board_manager.setup_terrain(current_terrain_assignments)
		board_manager.setup_board()
		board_ui_manager.update_power_labels()

		# Deck setup
		print("Assigning DeckManager.setup_deck with size:", PantheonRunManager.player_deck.size())
		DeckManager.setup_deck(PantheonRunManager.player_deck)
		print("After setup_deck, DeckManager.draw_pile size:", DeckManager.draw_pile.size())
		DeckManager.start_game()
		print("After start_game, DeckManager.hand size:", DeckManager.hand.size())

		# Enemy deck setup
		if enemy_deck_manager and PantheonRunManager.current_void_pantheon != "":
			print("Setting up enemy deck for void pantheon:", PantheonRunManager.current_void_pantheon)
			enemy_deck_manager.setup_deck(generate_enemy_deck_for_void_pantheon(PantheonRunManager.current_void_pantheon))
		elif enemy_deck_manager:
			print("WARNING: No void pantheon assigned for this node! Using test cards.")
			enemy_deck_manager._generate_test_cards()
	else:
		# --- DEV/TEST MODE (fallback) ---
		if not current_terrain_assignments or current_terrain_assignments.is_empty():
			var TerrainPool = preload("res://scripts/data/terrain_pools.gd")
			current_terrain_assignments = {
				"left": TerrainPool.VOID_TERRAIN_POOL["THE DREAMING MAW"][0],
				"middle": TerrainPool.PANTHEON_TERRAIN_POOLS["GREEK"][0],
				"right": TerrainPool.PANTHEON_TERRAIN_POOLS["GREEK"][0],
			}
			print("DEBUG: Assigned fake terrain for direct scene test.")
		board_manager.setup_terrain(current_terrain_assignments)
		board_manager.setup_board()
		board_ui_manager.update_power_labels()

		if DeckManager.draw_pile.is_empty() and DeckManager.hand.is_empty():
			print("Generating test cards for DeckManager (DEV MODE).")
			DeckManager._generate_test_cards()
		if enemy_deck_manager.draw_pile.is_empty() and enemy_deck_manager.hand.is_empty():
			print("Generating test cards for EnemyDeckManager (DEV MODE).")
			enemy_deck_manager._generate_test_cards()

	# === COMMON SETUP (UI, health bars, etc) ===
	var player_bar = $"../PlayerHUD/PlayerHealthBar"
	player_bar.fade_in()
	player_bar.set_health(player_health)

	var enemy_bar = $"../EnemyHUD/EnemyHealthBar"
	enemy_bar.fade_in()
	enemy_bar.set_health(enemy_health)

	# Draw initial hand if not already drawn (in case start_game hasn't)
	DeckManager.start_game()
	if hand_manager:
		hand_manager.refresh_hand()
	enemy_deck_manager.draw_cards(3)
	phase = "PlayerTurn"
	divinity = 10
	turn = 1
	emit_signal("phase_changed")
	emit_signal("turn_changed")

func end_player_turn():
	phase = "EnemyTurn"
	board_ui_manager.update_power_labels()
	emit_signal("phase_changed")
	call_deferred("enemy_turn")

func enemy_turn():
	enemy_deck_manager.draw_cards(1)
	for location in board_manager.locations:
		var slot = board_manager.get_available_slot(location, "enemy")
		if slot != -1 and enemy_deck_manager.hand.size() > 0:
			var enemy_card_instance = enemy_deck_manager.hand[0]
			board_manager.place_card(enemy_card_instance, location, "enemy", slot)
			enemy_deck_manager.play_card(enemy_card_instance)
			board_ui_manager.update_power_labels()
			if has_node("/root/CombatScene/BoardPanel/BoardUIManager"):
				var board_ui = get_node("/root/CombatScene/BoardPanel/BoardUIManager")
				board_ui.add_enemy_card_to_slot(enemy_card_instance, location, slot)
			# Execute enemy card effects
			var card_data = enemy_card_instance.get("card_data", null)
			if card_data:
				for effect in card_data.effects:
					if board_manager.is_location_silenced(location) and effect.effect_name != "Silence":
						print("Effect skipped due to ongoing Silence at location %s" % location)
						continue
					if effect is CardEffect:
						var context = {
							"combat_manager": self,
							"board": board_manager,
							"owner": "enemy",
							"location": location,
							"slot_idx": slot,
							"hand_manager": hand_manager, # Add for completeness (not used unless you want to affect player hand in enemy turn)
							"enemy_deck_manager": enemy_deck_manager
						}
						effect.execute(card_data, context)
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
		
		# Calculate damage reductions to health
		var player_reduction = board_manager.get_commander_damage_reduction("player")
		var enemy_reduction = board_manager.get_commander_damage_reduction("enemy")
		player_total = max(0, player_total - player_reduction)
		enemy_total = max(0, enemy_total - enemy_reduction)
		
		# Deal commander health damage
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
	# Apply permanent divinity bonus if set
	var perm_bonus = get_meta("permanent_divinity_bonus") if has_meta("permanent_divinity_bonus") else {"player": 0, "enemy": 0}
	divinity += 1 + (perm_bonus["player"] if perm_bonus.has("player") else 0)
	
	# Apply temporary divinity bonus if set, then clear it
	var temp_bonus = get_meta("temp_divinity_bonus") if has_meta("temp_divinity_bonus") else {"player": 0, "enemy": 0}
	if temp_bonus.has("player") and temp_bonus["player"] != 0:
		divinity += temp_bonus["player"]
		temp_bonus["player"] = 0
		set_meta("temp_divinity_bonus", temp_bonus)
	hand_manager.refresh_hand()
	board_ui_manager.update_power_labels()
	emit_signal("divinity_changed")
	emit_signal("phase_changed")

func play_card(card_instance: Dictionary, location: String, slot_idx: int = -1) -> String:
	var card_data = card_instance["card_data"]
	if divinity < card_data.cost:
		return "Not enough Divinity!"
	if slot_idx == -1:
		slot_idx = board_manager.get_available_slot(location, "player", card_data.type == "Spell")
		if slot_idx == -1:
			return "Location is full!"
	var placement_success = board_manager.place_card(card_instance, location, "player", slot_idx)
	if not placement_success:
		return "That slot is already occupied!"
	divinity -= card_data.cost
	emit_signal("divinity_changed")
	DeckManager.play_card(card_instance)
	for effect in card_data.effects:
		if board_manager.is_location_silenced(location) and effect.effect_name != "Silence":
			print("Effect skipped due to ongoing Silence at location %s" % location)
			continue
		var context = {
			"combat_manager": self,
			"board": board_manager,
			"owner": "player",
			"location": location,
			"slot_idx": slot_idx,
			"hand_manager": hand_manager, # <--- Add this!
			"enemy_deck_manager": enemy_deck_manager
		}
		effect.execute(card_data, context)
	board_ui_manager.update_power_labels()
	return "success"

func deal_commander_damage(target: String, amount: int):
	if target == "enemy":
		enemy_health -= amount
	elif target == "player":
		player_health -= amount

func set_terrain_assignments(terrain_assignments: Dictionary) -> void:
	current_terrain_assignments = terrain_assignments

# Call this from campaign/pantheon flow before start_combat to set up terrain using PantheonRunManager and ZoneGenerator.
func assign_terrain_from_run():
	if not PantheonRunManager.current_run_active:
		print("PantheonRunManager: No active run, skipping terrain assignment.")
		return
	var node_terrain = PantheonRunManager.get_current_node_terrains()
	print("node_terrain at combat start:", node_terrain)
	if node_terrain.has("player") and node_terrain["player"] != null:
		print("Player terrain is set correctly for combat!")
	else:
		print("ERROR: Player terrain is still null at combat start!")
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

# Called when the game ends (victory or defeat)
func game_over(result: String):
	if get_tree().current_scene.has_node("GameOverScreen"):
		print ("Game Over screen already showing")
		return  # Already showing, don't add another
		
	print("Game Over! Result: %s" % result)
	# Gather info for the screen
	var fallen_cards: Array[String] = []
	if result == "defeat":
		for card in DeckManager.hand + DeckManager.draw_pile + DeckManager.discard_pile:
			if card.type == "SoldierAttack" and card.health <= 0:
				fallen_cards.append(card.name) # use name, not id, for display
	var turns = turn
	var void_pantheon = "Unknown"
	if GameManager.dev_mode:
		void_pantheon = "TEST VOID PANTHEON"
	else:
		void_pantheon = PantheonRunManager.current_void_pantheon
	
	var screen = preload("res://scenes/game_over.tscn").instantiate()
	screen.name = "GameOverScreen"
	get_tree().current_scene.add_child(screen)
	screen.setup(result, turns, void_pantheon, fallen_cards)
	screen.play_reveal_animation()
	
	# Block Finish turn button after Game Over screen shows
	var hud = get_node_or_null("PlayerHUD")
	if hud and hud.has_method("set_enabled"):
		hud.set_enabled(false)
	
	# Reset fade state on show (in case of reloads)
	var combat_scene = get_tree().current_scene
	screen.reset_fade_state(combat_scene)

	screen.confirmed.connect(func ():
		get_tree().change_scene_to_file("res://scenes/pantheon_map.tscn")
	)
	
	# Notify run manager
	PantheonRunManager.on_combat_result(result, fallen_cards)

# Call when the player wins the combat
func victory():
	game_over("victory")

# Call when the player loses the combat
func defeat():
	game_over("defeat")

# Check both victory and defeat conditions at end of each turn
func check_end_conditions():
	if player_health <= 0:
		defeat()
	elif enemy_health <= 0:
		victory()
		

# Utility: Generate an enemy deck for the current void pantheon
func generate_enemy_deck_for_void_pantheon(void_pantheon: String) -> Array:
	var card_pools = preload("res://scripts/data/cards/card_pools.gd")
	var void_pool_map = {
		"THE DREAMING MAW": card_pools.DREAMING_MAW_VOID_PANTHEON,
		"THE PRIMAL ROIL": card_pools.PRIMAL_ROIL_VOID_PANTHEON,
		"THE INFINITE MESSENGER": card_pools.INFINITE_MESSENGER_VOID_PANTHEON,
		# ...add more as you add new void pantheons
	}
	var pool = void_pool_map.get(void_pantheon, [])
	var deck: Array = []
	if pool.is_empty():
		push_error("No enemy card pool for void pantheon: %s" % void_pantheon)
		return deck
	for i in range(14):
		var card = pool.pick_random()
		deck.append({
			"instance_id": "void_%s_%d" % [void_pantheon, i],
			"card_data": card,
			"type": card.type
		})
	return deck
# When you implement AI, simply call the same BoardUIManager function for the enemy side:
# $BoardUIManager.add_card_to_slot(enemy_card_instance, location, "enemy", slot_idx, card_ui_scene)
