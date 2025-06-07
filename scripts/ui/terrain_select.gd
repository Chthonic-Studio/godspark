extends Control
# Attach to TerrainSelectRoot

## EXPORTED VARS
@export var card_scene: PackedScene   # Assign terrain_card.tscn in the editor

## NODES
@onready var card_hbox = $VBoxContainer/CardScroll/CardHbox
@onready var selected_vbox = $VBoxContainer/HBoxContainer/SelectedVbox
@onready var confirm_btn = $VBoxContainer/HBoxContainer/ButtonsVBox/ConfirmButton
@onready var cancel_btn = $VBoxContainer/HBoxContainer/ButtonsVBox/CancelButton
@onready var error_label = $VBoxContainer/ErrorLabel

## LOGIC VARS
var available_terrains: Array[Resource] = []
var selected_terrains: Array[Resource] = []

func _ready():
	# --- DEV MODE TEST TERRAIN INJECTION ---
	if GameManager.dev_mode and (not PantheonRunManager.available_player_terrain_cards or PantheonRunManager.available_player_terrain_cards.size() == 0):
		var pools = preload("res://scripts/data/terrain_pools.gd")
		var test_terrains = pools.PLAYER_TERRAIN_POOL.duplicate()
		test_terrains.shuffle()
		available_terrains.clear()
		for i in range(min(4, test_terrains.size())):
			available_terrains.append(test_terrains[i])
	else:
		available_terrains = PantheonRunManager.available_player_terrain_cards.duplicate()
	# Get available terrains for this run
	selected_terrains.clear()
	_populate_card_hbox()
	_update_selected_vbox()
	confirm_btn.disabled = true
	error_label.text = ""
	confirm_btn.pressed.connect(_on_confirm_pressed)
	cancel_btn.pressed.connect(_on_cancel_pressed)

func _populate_card_hbox():
	for child in card_hbox.get_children():
		child.queue_free()
	for terrain in available_terrains:
		var card = card_scene.instantiate()
		card.custom_minimum_size = Vector2(240, 300)
		card.set_terrain(terrain)
		card.set_selected(false)
		card.connect("gui_input", Callable(self, "_on_card_gui_input").bind(terrain, card))
		card_hbox.add_child(card)

func _on_card_gui_input(event: InputEvent, terrain: Resource, card):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if terrain in selected_terrains:
			selected_terrains.erase(terrain)
			card.set_selected(false)
		elif selected_terrains.size() < 3:
			selected_terrains.append(terrain)
			card.set_selected(true)
		# Optionally, show error if trying to select more than 3
		if selected_terrains.size() > 3:
			error_label.text = "You can only select 3 terrain cards."
		else:
			error_label.text = ""
		_update_selected_vbox()
		confirm_btn.disabled = (selected_terrains.size() != 3)

func _update_selected_vbox():
	for child in selected_vbox.get_children():
		child.queue_free()
	for terrain in selected_terrains:
		var card = card_scene.instantiate()
		card.call_deferred("set_terrain", terrain)
		card.call_deferred("set_selected", false) 
		card.modulate = Color(1, 1, 1, 0.8)  # Optional: faded to show unclickable
		selected_vbox.add_child(card)

func _on_confirm_pressed():
	if selected_terrains.size() == 3:
		PantheonRunManager.player_terrain_cards = selected_terrains.duplicate()
		hide() # Or queue_free(), or emit a custom signal to notify parent
	else:
		error_label.text = "Please select exactly 3 terrain cards."

func _on_cancel_pressed():
	hide() # Or queue_free(), or notify parent via signal

# Optional: utility for clearing children of a container in Godot 4.4
func clear():
	for child in self.get_children():
		child.queue_free()
