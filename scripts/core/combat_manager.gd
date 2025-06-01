extends Node

@export var deck_manager: DeckManager
@export var soldier_nodes: Array[DivineSoldier]
@export var enemy_nodes: Array[Node]
@export var terrain_right: TerrainData
@export var terrain_middle: TerrainData
@export var terrain_left: TerrainData

var phase: String = "PlayerTurn"
var resources: int = 0
var faith_earned: int = 0

func start_combat():
	DeckManager.draw_cards(deck_manager.max_hand_size)
	phase = "PlayerTurn"
	resources = 3 # Or whatever resource system you implement

func end_player_turn():
	# Apply all end-of-turn effects, terrain triggers, corruption accrual, etc.
	phase = "EnemyTurn"
	call_deferred("enemy_turn")

func enemy_turn():
	# Enemies perform actions, possibly using location/terrain
	# Apply void effects, damage, etc.
	# After enemies are done:
	phase = "PlayerTurn"
	DeckManager.draw_cards(deck_manager.max_hand_size)
	resources += 1 # Or scale as needed

func play_card(card: CardData, target_location: String):
	# Consume resource, resolve card effects, update board state
	DeckManager.play_card(card)
	# Check for confluences, prophecy, etc.

func check_end_conditions():
	# If all enemies dead: call victory()
	# If all soldiers dead: call defeat()
	pass
