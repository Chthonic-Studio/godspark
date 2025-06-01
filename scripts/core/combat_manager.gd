extends Node

@export var board_manager: BoardManager
@export var player_health: int = 100
@export var enemy_health: int = 100

var turn: int = 1
var phase: String = "PlayerTurn"
var resources: int = 3 # Faith for playing cards

# Called once at combat start
func start_combat():
	DeckManager.draw_cards(DeckManager.max_hand_size)
	phase = "PlayerTurn"
	resources = 3
	turn = 1
	board_manager.setup_board()

func end_player_turn():
	# (Resolve end-of-turn effects, etc. as needed)
	phase = "EnemyTurn"
	call_deferred("enemy_turn")

func enemy_turn():
	# (Enemy AI logic goes here)
	# After enemies act:
	phase = "Resolution"
	call_deferred("resolve_turn")

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
	phase = "PlayerTurn"
	DeckManager.draw_cards(DeckManager.max_hand_size)
	resources += 1

func play_card(card: CardData, location: String, slot_idx: int = -1):
	if resources < card.cost:
		return false # Not enough Faith
	if slot_idx == -1:
		slot_idx = board_manager.get_available_slot(location, "player", card.type=="Spell") # Spells can prefer back
	if board_manager.place_card(card, location, "player", slot_idx):
		resources -= card.cost
		DeckManager.play_card(card)
		# Execute effects
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
		return true
	return false

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
