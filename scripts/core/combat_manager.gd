extends Node

@export var board_manager: BoardManager
@export var enemy_deck_manager: EnemyDeckManager
@export var player_health: int = 100
@export var enemy_health: int = 100

var turn: int = 1
var phase: String = "PlayerTurn"
var divinity: int = 10 # Faith for playing cards

signal divinity_changed
signal phase_changed
signal turn_changed

# Called once at combat start
func start_combat():
	DeckManager.start_game()
	enemy_deck_manager.draw_cards(3)
	phase = "PlayerTurn"
	divinity = 10
	turn = 1
	board_manager.setup_board()
	emit_signal("phase_changed")
	emit_signal("turn_changed")

func end_player_turn():
	# (Resolve end-of-turn effects, etc. as needed)
	phase = "EnemyTurn"
	emit_signal("phase_changed")
	call_deferred("enemy_turn")

func enemy_turn():
	enemy_deck_manager.draw_cards(1)
	for location in board_manager.locations:
		var slot = board_manager.get_available_slot(location, "enemy")
		if slot != -1 and enemy_deck_manager.hand.size() > 0:
			var card = enemy_deck_manager.hand[0] # Simplest AI: play first card
			board_manager.place_card(card, location, "enemy", slot)
			enemy_deck_manager.play_card(card)
			# Instantiate UI here (see below)
			if has_node("/root/CombatScene/BoardPanel/BoardUIManager"):
				var board_ui = get_node("/root/CombatScene/BoardPanel/BoardUIManager")
				board_ui.add_enemy_card_to_slot(card, location, slot)
			break  # Play only one card per turn for now
	phase = "Resolution"
	call_deferred("resolve_turn")
	emit_signal("phase_changed")

func resolve_turn():
	if turn >= 4:
		var player_total = 0
		var enemy_total = 0
		for loc in board_manager.locations:
			var player_power = board_manager.calculate_power(loc, "player")
			var enemy_power = board_manager.calculate_power(loc, "enemy")
			player_total += max(enemy_power - player_power, 0)
			enemy_total += max(player_power - enemy_power, 0)
		player_health -= player_total
		enemy_health -= enemy_total
		# Add UI feedback for health change here

	# Check for defeat/victory
	check_end_conditions()

	# Prepare for next turn
	turn += 1
	emit_signal("turn_changed")
	phase = "PlayerTurn"
	DeckManager.draw_cards(1)
	divinity += 1
	emit_signal("divinity_changed")
	emit_signal("phase_changed")

func play_card(card: CardData, location: String, slot_idx: int = -1) -> String:
	if divinity < card.cost:
		return "Not enough Divinity!"
	if slot_idx == -1:
		slot_idx = board_manager.get_available_slot(location, "player", card.type=="Spell")
		if slot_idx == -1:
			return "Location is full!"
	var placement_success = board_manager.place_card(card, location, "player", slot_idx)
	if not placement_success:
		return "That slot is already occupied!"
	divinity -= card.cost
	emit_signal("divinity_changed")
	DeckManager.play_card(card)
	for effect in card.effects:
		if effect is CardEffect:
			var context = {
				"combat_manager": self,
				"board": board_manager,
				"owner": "player",
				"location": location,
				"slot_idx": slot_idx
			}
			effect.execute(card, context)
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


# When you implement AI, simply call the same BoardUIManager function for the enemy side:
# Example call from CombatManager or AI logic:
# $BoardUIManager.add_card_to_slot(enemy_card_data, location, "enemy", slot_idx, card_ui_scene)
