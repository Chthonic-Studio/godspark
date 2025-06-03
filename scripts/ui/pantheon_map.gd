extends Control

# This script should be attached to your PantheonMapScene root node.

@onready var pantheon_bg = $PantheonBG
@onready var pantheon_name_label = $PantheonName
@onready var node_container = $NodeContainer
@onready var abandon_btn = $MenuPanel/AbandonRunButton
@onready var edit_deck_btn = $MenuPanel/EditDeckButton

@onready var abandon_confirm = $AbandonConfirmDialog
@onready var abandon_message = $AbandonMessageWindow
@onready var fade_overlay = $FadeOverlay

@export var node_icon_available: Texture2D
@export var node_icon_cleared: Texture2D
@export var node_icon_locked: Texture2D

@onready var node_buttons := [
	$NodeContainer/NodeButton,
	$NodeContainer/NodeButton2,
	$NodeContainer/NodeButton3,
	$NodeContainer/NodeButton4,
	$NodeContainer/NodeButton5,
]

var current_node_buttons = []

func _ready():
	for i in range(node_buttons.size()):
		node_buttons[i].pressed.connect(_on_NodeButton_pressed.bind(i))
	_setup_pantheon_display()
	_setup_nodes()

	abandon_btn.pressed.connect(_on_AbandonRunButton_pressed)
	edit_deck_btn.pressed.connect(_on_EditDeckButton_pressed)
	abandon_confirm.confirmed.connect(_on_abandon_confirmed)
	

func _setup_pantheon_display():
	pantheon_name_label.text = PantheonRunManager.current_pantheon.capitalize()
	# Optionally set BG art here if available

func _setup_nodes():
	var nodes = PantheonRunManager.current_node_terrains
	var unlocked_idx = PantheonRunManager.current_node_index
	for i in range(node_buttons.size()):
		var node_btn = node_buttons[i]
		if i < nodes.size():
			if i < unlocked_idx:
				node_btn.texture_normal = node_icon_cleared
				node_btn.disabled = true
				node_btn.modulate = Color(1, 1, 1, 1)
			elif i == unlocked_idx:
				node_btn.texture_normal = node_icon_available
				node_btn.disabled = false
				node_btn.modulate = Color(1, 1, 1, 1)
			else:
				node_btn.texture_normal = node_icon_locked
				node_btn.disabled = true
				node_btn.modulate = Color(0.5, 0.5, 0.5, 1)
			node_btn.visible = true
		else:
			node_btn.visible = false

func _on_NodeButton_pressed(idx):
	if idx > PantheonRunManager.current_node_index:
		return # Not unlocked yet
	# Prompt for terrain shuffle/selection (implement this UI as needed)
	var player_terrains = PantheonRunManager.player_terrain_cards
	player_terrains.shuffle()
	if player_terrains.size() > 0:
		var selected_terrain = player_terrains[0]
		PantheonRunManager.set_player_terrain_for_current_combat(selected_terrain)
	else:
		print("No player terrain cards assigned yet.")
	# Set up terrain assignment for combat scene (optional: use a global holder or let CombatManager fetch via PantheonRunManager)
	get_tree().change_scene_to_file("res://scenes/combat_scene.tscn")

func _on_AbandonRunButton_pressed():
	abandon_confirm.dialog_text = "Are you sure you want to abandon this run? This universe will be lost."
	abandon_confirm.popup_centered()

func _on_abandon_confirmed():
	# Show abandon message and fade out
	# Fade everything else
	fade_overlay.visible = true
	fade_overlay.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(fade_overlay, "modulate:a", 0.85, 0.8)
	tween.tween_callback(Callable(self, "_after_fade_abandon"))
	tween.play()

func _after_fade_abandon():
	await get_tree().create_timer(5.0).timeout
	PantheonRunManager.abandon_run()
	# Reset overlay and windows
	fade_overlay.visible = false
	abandon_message.hide()
	get_tree().change_scene_to_file("res://scenes/pantheon_selection_scene.tscn")

func _on_EditDeckButton_pressed():
	print("Deck editing not yet implemented.")
