extends Control
class_name BoardUIManager

@export var board_manager: NodePath
@export var enemy_card_ui_scene: PackedScene

signal location_clicked(location: String)

func _ready():
	var bm = get_node(board_manager)
	bm.card_removed.connect(remove_card_from_slot)
	bm.power_changed.connect(_on_power_changed)
	
	for location in ["left", "middle", "right"]:
		var loc_node = get_parent().get_node(location)
		for row in ["PlayerFrontRow", "PlayerBackRow"]:
			var card_slots = loc_node.get_node("%s/cardSlots" % row)
			for slot in card_slots.get_children():
				slot.set_meta("location", location)
				slot.gui_input.connect(_on_location_gui_input.bind(location))

func _on_location_gui_input(event: InputEvent, location: String):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		emit_signal("location_clicked", location)

func _on_slot_gui_input(event: InputEvent, slot: Panel):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var location = slot.get_meta("location")
		var slot_idx = slot.get_meta("slot_idx")
		emit_signal("slot_clicked", location, slot_idx)

# Highlight entire location if any player slot is available
func highlight_valid_locations(card_instance):
	var board = get_node(board_manager)
	for location in board.locations:
		var found = false
		for idx in [0, 1, 2, 3]:
			if board.board[location]["player"][idx] == null:
				found = true
				break
		for idx in [0, 1, 2, 3]:
			var slot_node = get_slot_node(location, idx)
			if slot_node:
				slot_node.modulate = Color(0.7, 1, 0.7) if found else Color(1, 1, 1)

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
	
# Adds a CardUI node to the correct slot (player or enemy), sets scale/anchors for board display
func add_card_to_slot(card_instance: Dictionary, location: String, side: String, slot_idx: int, card_ui_scene: PackedScene) -> CardUI:
	var slot_node = get_slot_node_for_side(location, side, slot_idx)
	if slot_node == null:
		print("ERROR: No slot node found for", location, side, slot_idx)
		return null
	var card_ui = card_ui_scene.instantiate()
	card_ui.set_card_instance(card_instance)
	card_ui.scale = Vector2(0.7, 0.7)
	# Center the card in the slot
	card_ui.anchor_left = 0.5
	card_ui.anchor_top = 0
	card_ui.anchor_right = 0
	card_ui.anchor_bottom = 0
	card_ui.position = Vector2.ZERO
	card_ui.size_flags_horizontal = Control.SIZE_FILL
	card_ui.size_flags_vertical = Control.SIZE_FILL
	slot_node.add_child(card_ui)
	return card_ui

# Utility: Returns the correct slot node (Panel) for player or enemy
func get_slot_node_for_side(location: String, side: String, idx: int) -> Panel:
	var row : String
	if side == "player":
		row = "PlayerFrontRow" if idx < 2 else "PlayerBackRow"
	elif side == "enemy":
		row = "EnemyFrontRow" if idx < 2 else "EnemyBackRow"
	else:
		print("Invalid side:", side)
		return null
	var slot_name = "Slot%d" % idx
	var node_path = "../%s/%s/cardSlots/%s" % [location, row, slot_name]
	if has_node(node_path):
		return get_node(node_path)
	return null

func add_enemy_card_to_slot(card_instance: Dictionary, location: String, slot_idx: int):
	var card_ui_scene = enemy_card_ui_scene if enemy_card_ui_scene else preload("res://scenes/card.tscn")
	var card_ui = card_ui_scene.instantiate()
	card_ui.set_card_instance(card_instance)
	card_ui.scale = Vector2(0.5, 0.5)
	card_ui.modulate = Color(1, 0.85, 0.85, 1)
	var slot_node = get_enemy_slot_node(location, slot_idx)
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
	else:
		print("Could not find enemy slot node for", location, slot_idx)

func get_enemy_slot_node(location: String, idx: int) -> Panel:
	var row = "EnemyFrontRow" if idx < 2 else "EnemyBackRow"
	var slot_name = "Slot%d" % idx
	var node_path = "../%s/%s/cardSlots/%s" % [location, row, slot_name]
	if has_node(node_path):
		return get_node(node_path)
	return null

func remove_card_from_slot(location: String, side: String, slot_idx: int) -> void:
	var slot_node = get_slot_node_for_side(location, side, slot_idx)
	if slot_node:
		for child in slot_node.get_children():
			child.queue_free()

# Call after repacking: updates visual position of all cards in a row
func repack_cards_in_location(location: String, side: String) -> void:
	for idx in [0, 1, 2, 3]:
		remove_card_from_slot(location, side, idx)
		var card_instance = get_node(board_manager).board[location][side][idx]
		if card_instance:
			add_card_to_slot(card_instance, location, side, idx, enemy_card_ui_scene if side == "enemy" else preload("res://scenes/card.tscn"))

# Call this after setup_terrain or at combat start
func update_location_info():
	var bm = get_node(board_manager)
	for location in ["left", "middle", "right"]:
		var terrain = bm.terrain_by_location.get(location, null)
		if terrain == null:
			continue
		var loc_node = get_parent().get_node(location)
		var info_node = loc_node.get_node("LocationInfo")
		info_node.get_node("Art").texture = terrain.art
		info_node.get_node("LocationName").text = terrain.name
		info_node.get_node("LocationDescription").text = terrain.effect_description

# Call this to update all power labels in the UI
func update_power_labels():
	var bm = get_node(board_manager)
	for location in bm.locations:
		var player_power = bm.calculate_power(location, "player")
		var enemy_power = bm.calculate_power(location, "enemy")
		var loc_node = get_parent().get_node(location)
		var info_node = loc_node.get_node("LocationInfo")
		info_node.get_node("PlayerPowerLabel").text = str(player_power)
		info_node.get_node("EnemyPowerLabel").text = str(enemy_power)

# This function will update the UI labels for a single location when power changes
func _on_power_changed(location: String, player_power: int, enemy_power: int) -> void:
	print("Power changed at %s: player %d, enemy %d" % [location, player_power, enemy_power])
	var loc_node = get_parent().get_node(location)
	if not loc_node.has_node("LocationInfo/PlayerPowerLabel"):
		# You need to add these labels in your scene for each location!
		return
	var info_node = loc_node.get_node("LocationInfo")
	info_node.get_node("PlayerPowerLabel").text = str(player_power)
	info_node.get_node("EnemyPowerLabel").text = str(enemy_power)
