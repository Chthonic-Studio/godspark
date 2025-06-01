extends Control
class_name HandManager

# HOW TO USE:
# - Attach this script to a Control node in your combat scene (e.g., "HandPanel").
# - Set 'card_ui_scene' to your Card.tscn scene.
# - Set 'hand_container' to an HBoxContainer/GridContainer for hand cards.
# - Set 'combat_manager' to the NodePath of your CombatManager node (e.g., "../../CombatManager").
# - Set 'board_ui_manager' to the NodePath of your BoardUIManager node (e.g., "../BoardPanel/BoardUIManager").
# - Call refresh_hand() after drawing, discarding, or playing cards.
# - Signals from CardUI will trigger play/cancel logic (see _on_card_play_attempt, _on_card_cancelled).
# - Integrate with BoardUIManager for slot selection on card play.

@export var card_ui_scene: PackedScene
@export var hand_container: NodePath # reference to a UI container node (e.g., HBoxContainer)
@export var combat_manager: NodePath
@export var board_ui_manager: NodePath

var card_instances: Array[Node] = []
var selected_card_ui: Node = null

func _ready():
	refresh_hand()
	get_node(board_ui_manager).slot_clicked.connect(_on_board_slot_clicked)
	
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
		card_ui.card_selected.connect(_on_card_selected)
		card_ui.card_play_attempt.connect(_on_card_play_attempt)
		card_ui.card_cancelled.connect(_on_card_cancelled)
		container.add_child(card_ui)
		card_instances.append(card_ui)

# Handles play attempts (drag or click)
func _on_card_play_attempt(card_ui):
	selected_card_ui = card_ui
	get_node(board_ui_manager).highlight_valid_slots(card_ui.card_data)
	# Wait for slot_clicked signal to proceed

func _on_board_slot_clicked(location, slot_idx):
	if selected_card_ui:
		var combat_manager_node = get_node(combat_manager)
		var played = combat_manager_node.play_card(selected_card_ui.card_data, location, slot_idx)
		if played:
			var board_ui = get_node(board_ui_manager)
			var card_ui = card_ui_scene.instantiate()
			card_ui.set_card_data(selected_card_ui.card_data)
			card_ui.scale = Vector2(0.5, 0.5)
			var slot_node = board_ui.get_slot_node(location, slot_idx) # <-- changed to get_slot_node
			if slot_node:
				slot_node.add_child(card_ui)
				card_ui.anchor_left = 0.5
				card_ui.anchor_top = 0.5
				card_ui.anchor_right = 0.5
				card_ui.anchor_bottom = 0.5
				card_ui.offset_left = -30 # -half width (60/2)
				card_ui.offset_top = -37.5 # -half height (75/2)
				card_ui.offset_right = 30
				card_ui.offset_bottom = 37.5
				card_ui.position = Vector2.ZERO
				card_ui.size_flags_horizontal = Control.SIZE_FILL
				card_ui.size_flags_vertical = Control.SIZE_FILL
				card_ui.scale = Vector2(0.5, 0.5) # your current test scaling
			else:
				print("Could not find slot node for", location, slot_idx)
			refresh_hand()
		get_node(board_ui_manager).clear_highlights()
		selected_card_ui = null

func _on_card_cancelled(card_ui):
	card_ui.is_selected = false
	card_ui.get_node("HighlightOverlay").visible = false
	get_node(board_ui_manager).clear_highlights()
	selected_card_ui = null

func _on_card_selected(card_ui):
	# Deselect all cards
	for c in card_instances:
		c.is_selected = false
		c.get_node("HighlightOverlay").visible = false
	# Select the clicked card
	card_ui.is_selected = true
	card_ui.get_node("HighlightOverlay").visible = true
	selected_card_ui = card_ui
	get_node(board_ui_manager).highlight_valid_slots(card_ui.card_data)

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_F1:
		DeckManager._generate_test_cards()
		refresh_hand()
