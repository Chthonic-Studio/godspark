extends Control
class_name BoardUIManager

@export var board_manager: NodePath

signal slot_clicked(location: String, slot_idx: int)

func _ready():
	for location in ["left", "middle", "right"]:
		var loc_node = get_parent().get_node(location)
		var player_front_row = loc_node.get_node("PlayerFrontRow/cardSlots")
		for idx in [0, 1]:
			var slot = player_front_row.get_node("Slot%d" % idx)
			slot.set_meta("location", location)
			slot.set_meta("slot_idx", idx)
			slot.gui_input.connect(_on_slot_gui_input.bind(slot))
		var player_back_row = loc_node.get_node("PlayerBackRow/cardSlots")
		for idx in [2, 3]:
			var slot = player_back_row.get_node("Slot%d" % idx)
			slot.set_meta("location", location)
			slot.set_meta("slot_idx", idx)
			slot.gui_input.connect(_on_slot_gui_input.bind(slot))

func _on_slot_gui_input(event: InputEvent, slot: Panel):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var location = slot.get_meta("location")
		var slot_idx = slot.get_meta("slot_idx")
		emit_signal("slot_clicked", location, slot_idx)

func highlight_valid_slots(card_data):
	var board = get_node(board_manager)
	for location in board.locations:
		if typeof(location) != TYPE_STRING:
			print("Location is not a string:", location)
			continue
		if not board.board.has(location):
			print("Board is missing location key:", location, "; available keys:", board.board.keys())
			continue
		for idx in [0, 1, 2, 3]:
			if board.board[location]["player"][idx] == null:
				var slot_node = get_slot_node(location, idx)
				if slot_node:
					slot_node.modulate = Color(0.7, 1, 0.7)
			else:
				var slot_node = get_slot_node(location, idx)
				if slot_node:
					slot_node.modulate = Color(1, 1, 1)

func clear_highlights():
	for location in ["left", "middle", "right"]:
		for idx in [0, 1, 2, 3]:
			var slot_node = get_slot_node(location, idx)
			if slot_node:
				slot_node.modulate = Color(1, 1, 1)

func get_slot_node(location: String, idx: int) -> Panel:
	var row = "PlayerFrontRow" if idx < 2 else "PlayerBackRow"
	var slot_name = "Slot%d" % idx
	var node_path = "../%s/%s/cardSlots/%s" % [location, row, slot_name]
	if has_node(node_path):
		return get_node(node_path)
	return null
