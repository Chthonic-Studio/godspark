# HOW TO USE:
# - Attach to a Control node representing the board (e.g., "BoardPanel").
# - Set 'board_manager' to the NodePath of your BoardManager node.
# - Each slot (e.g., Panel or Button) should have a unique name or metadata for location/slot index.
# - Call highlight_valid_slots(card_data) when a card is selected.
# - Connect the slot_clicked signal to your HandManager or game flow controller to handle card placement.

extends Control
class_name BoardUIManager

@export var board_manager: NodePath

signal slot_clicked(location: String, slot_idx: int)

func _ready():
	# Assign metadata and connect gui_input for all slots
	for location in ["Left", "Middle", "Right"]:
		var container = get_parent().get_node(location)
		for i in range(4):
			var slot = container.get_node("Slot%d" % i)
			slot.set_meta("location", location.to_lower())
			slot.set_meta("slot_idx", i)
			slot.gui_input.connect(_on_slot_gui_input.bind(slot))

func _on_slot_gui_input(event: InputEvent, slot: Panel):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var location = slot.get_meta("location")
		var slot_idx = slot.get_meta("slot_idx")
		emit_signal("slot_clicked", location, slot_idx)


# Call this to highlight valid slots for a card
func highlight_valid_slots(card_data):
	var board = get_node(board_manager)
	for location in board.locations:
		for idx in range(4):
			if board.board[location]["player"][idx] == null:
				var slot_node = _get_slot_node(location, idx)
				if slot_node:
					slot_node.modulate = Color(0.7, 1, 0.7)

# Call this to clear all highlights
func clear_highlights():
	for location in ["left", "middle", "right"]:
		for idx in range(4):
			var slot_node = _get_slot_node(location, idx)
			if slot_node:
				slot_node.modulate = Color(1, 1, 1)

# Internal utility to get the slot Control node
func _get_slot_node(location: String, idx: int):
	var node_path = "../%s/Slot%d" % [location.capitalize(), idx]
	if has_node(node_path):
		return get_node(node_path)
	return null

# This should be called by each slot node when clicked
func on_slot_pressed(location: String, slot_idx: int):
	emit_signal("slot_clicked", location, slot_idx)
