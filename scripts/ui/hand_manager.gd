extends Control
class_name HandManager

# HOW TO USE:
# - Attach this script to a Control node in your combat scene (e.g., "HandPanel").
# - Set 'card_ui_scene' to your Card.tscn scene.
# - Set 'hand_container' to an HBoxContainer/GridContainer for hand cards.
# - Set 'combat_manager' to the node path of your CombatManager.
# - Call refresh_hand() after drawing, discarding, or playing cards.
# - Signals from CardUI will trigger play/cancel logic (see _on_card_play_attempt, _on_card_cancelled).
# - Integrate with BoardUIManager for slot selection on card play.

@export var card_ui_scene: PackedScene
@export var hand_container: NodePath # reference to a UI container node (e.g., HBoxContainer)
@export var combat_manager: NodePath

var card_instances: Array[Node] = []

func _ready():
	refresh_hand()

# Call this after every draw/discard/play event
func refresh_hand():
	# Clear existing UI
	for card_ui in card_instances:
		card_ui.queue_free()
	card_instances.clear()

	var container = get_node(hand_container)
	for card_data in DeckManager.hand:
		var card_ui = card_ui_scene.instantiate()
		card_ui.set_card_data(card_data)
		card_ui.card_play_attempt.connect(_on_card_play_attempt)
		card_ui.card_cancelled.connect(_on_card_cancelled)
		container.add_child(card_ui)
		card_instances.append(card_ui)

# Handles play attempts (drag or click)
func _on_card_play_attempt(card_ui):
	# This assumes you have logic to choose location and slot, or prompt the player
	var result = _prompt_for_location_and_slot(card_ui)
	var location = result[0]
	var slot_idx = result[1]	
	if location != null and slot_idx != null:
		var combat_manager_node = get_node(combat_manager) # Use exported variable 'combat_manager'
		var played = combat_manager_node.play_card(card_ui.card_data, location, slot_idx)
		if played:
			refresh_hand() # Remove from hand UI

func _on_card_cancelled(card_ui):
	card_ui.is_selected = false
	card_ui.get_node("HighlightOverlay").visible = false

func _prompt_for_location_and_slot(card_ui):
	# TODO: Implement UI to allow player to click/select where to play
	# For now, return dummy values or integrate with your board UI logic
	return ["middle", 0]
