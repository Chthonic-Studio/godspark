extends Control

# Exports for flexibility in the editor
@export var terrain_card_button_scene: PackedScene
@export var terrain_data_list: Array[Resource] # Assign all available TerrainData resources in the editor

@onready var terrain_grid = $TerrainCardGrid
@onready var selected_panel = $SelectedTerrainsPanel
@onready var confirm_button = $ConfirmButton
@onready var error_label = $ErrorLabel

var selected_terrains: Array[Resource] = []

func _ready():
	# Populate terrain selection grid
	for terrain in terrain_data_list:
		var btn = terrain_card_button_scene.instantiate()
		btn.set_terrain(terrain)
		btn.pressed.connect(_on_terrain_card_pressed.bind(terrain))
		terrain_grid.add_child(btn)
	confirm_button.pressed.connect(_on_confirm_button_pressed)
	_update_selected_panel()

func _on_terrain_card_pressed(terrain):
	if terrain in selected_terrains:
		selected_terrains.erase(terrain)
	else:
		if selected_terrains.size() >= 3:
			error_label.text = "You can select up to 3 terrain cards."
			return
		selected_terrains.append(terrain)
	error_label.text = ""
	_update_selected_panel()

func _update_selected_panel():
	for child in selected_panel.get_children():
		child.queue_free()
	for terrain in selected_terrains:
		var btn = terrain_card_button_scene.instantiate()
		btn.set_terrain(terrain)
		btn.disabled = true
		selected_panel.add_child(btn)

func _on_confirm_button_pressed():
	if selected_terrains.size() != 3:
		error_label.text = "Select exactly 3 terrain cards."
		return
	PantheonRunManager.player_terrain_cards = selected_terrains.duplicate()
	# Proceed to next scene (e.g., pantheon selection)
	get_tree().change_scene_to_file("res://scenes/pantheon_selection_scene.tscn")
