extends Control
class_name HandManager

@export var card_ui_scene: PackedScene
@export var hand_container: NodePath
@export var combat_manager: NodePath
@export var board_ui_manager: NodePath

@onready var error_label = $"../../PlayerHUD/ErrorLabel"

var card_instances: Array[Node] = []
var selected_card_ui: Node = null

func _ready():
	refresh_hand()
	get_node(board_ui_manager).location_clicked.connect(_on_board_location_clicked)

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
	
	selected_card_ui = null # <- always clear selection after hand refresh
	print("Hand contains ", DeckManager.hand.size(), " cards.")

func _on_card_play_attempt(card_ui):
	selected_card_ui = card_ui
	get_node(board_ui_manager).highlight_valid_locations(card_ui.card_data)

func _on_board_location_clicked(location):
	if selected_card_ui:
		var combat_manager_node = get_node(combat_manager)
		var board_manager_node = combat_manager_node.board_manager
		var slot_idx = board_manager_node.get_available_slot(location, "player")
		if slot_idx == -1:
			show_error("Location is full!")
			return
		var result = combat_manager_node.play_card(selected_card_ui.card_data, location, slot_idx)
		if result == "success":
			# (existing card placement code)
			var board_ui = get_node(board_ui_manager)
			var card_ui = card_ui_scene.instantiate()
			card_ui.set_card_data(selected_card_ui.card_data)
			card_ui.scale = Vector2(0.5, 0.5)
			var slot_node = board_ui.get_slot_node(location, slot_idx)
			if slot_node:
				slot_node.add_child(card_ui)
				card_ui.anchor_left = 0.5
				card_ui.anchor_top = 0.5
				card_ui.anchor_right = 0.5
				card_ui.anchor_bottom = 0.5
				card_ui.offset_left = -30
				card_ui.offset_top = -37.5
				card_ui.offset_right = 30
				card_ui.offset_bottom = 37.5
				card_ui.position = Vector2.ZERO
				card_ui.size_flags_horizontal = Control.SIZE_FILL
				card_ui.size_flags_vertical = Control.SIZE_FILL
				card_ui.scale = Vector2(0.5, 0.5)
			else:
				show_error("Cannot play card: slot not found!")
			refresh_hand()
		else:
			show_error(result)
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
	get_node(board_ui_manager).highlight_valid_locations(card_ui.card_data)

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_F1:
		DeckManager._generate_test_cards()
		refresh_hand()

func show_error(msg: String):
	error_label.text = msg
	error_label.visible = true
	await get_tree().create_timer(1.2).timeout
	error_label.visible = false
