extends Control

# This script should be attached to your PantheonSelectionScene root node.

@onready var pantheon_grid = $PantheonGrid
@onready var confirm_panel = $ConfirmPanel
@onready var confirm_art = $ConfirmPanel/PantheonArt
@onready var confirm_name = $ConfirmPanel/PantheonName
@onready var confirm_button = $ConfirmPanel/ConfirmButton
@onready var cancel_button = $ConfirmPanel/CancelButton

@onready var greek_button = $PantheonGrid/GreekPantheon
@onready var iroquois_button = $PantheonGrid/IroquoisPantheon
@onready var kalevala_button = $PantheonGrid/KalevalaPantheon
@onready var norse_button = $PantheonGrid/NorsePantheon
@onready var polynesian_button = $PantheonGrid/PolynesianPantheon
@onready var zoroastrian_button = $PantheonGrid/ZoroastrianPantheon
@onready var egyptian_button = $PantheonGrid/EgyptianPantheon
@onready var inca_button = $PantheonGrid/IncaPantheon
@onready var mesopotamian_button = $PantheonGrid/MesopotamianPantheon
@onready var shinto_button = $PantheonGrid/ShintoPantheon
@onready var aztec_button = $PantheonGrid/AztecPantheon
@onready var hindu_button = $PantheonGrid/HinduPantheon
@onready var yoruba_button = $PantheonGrid/YorubaPantheon
@onready var maya_button = $PantheonGrid/MayaPantheon
@onready var chinese_button = $PantheonGrid/ChinesePantheon
@onready var celtic_button = $PantheonGrid/CelticPantheon

var selected_pantheon : String = ""

func _ready():
	confirm_panel.visible = false
	_setup_pantheon_buttons()
	confirm_button.pressed.connect(_on_ConfirmButton_pressed)
	cancel_button.pressed.connect(_on_CancelButton_pressed)

func _setup_pantheon_buttons():
	# List of all button nodes and their pantheon names
	var pantheon_buttons = {
		"GREEK": greek_button,
		"IROQUOIS": iroquois_button,
		"KALEVALA": kalevala_button,
		"NORSE": norse_button,
		"POLYNESIAN": polynesian_button,
		"ZOROASTRIAN": zoroastrian_button,
		"EGYPTIAN": egyptian_button,
		"INCA": inca_button,
		"MESOPOTAMIAN": mesopotamian_button,
		"SHINTO": shinto_button,
		"AZTEC": aztec_button,
		"HINDU": hindu_button,
		"YORUBA": yoruba_button,
		"MAYA": maya_button,
		"CHINESE": chinese_button,
		"CELTIC": celtic_button
	}
	var liberated = PantheonRunManager.liberated_pantheons if PantheonRunManager.has_method("liberated_pantheons") else []
	for pantheon_name in pantheon_buttons:
		var btn = pantheon_buttons[pantheon_name]
		# Disconnect old signals to avoid duplicates (good practice for reloads)
		if btn.pressed.is_connected(_on_pantheon_button_pressed):
			btn.pressed.disconnect(_on_pantheon_button_pressed)
		btn.pressed.connect(_on_pantheon_button_pressed.bind(pantheon_name))
		# Check if available
		if pantheon_name in liberated:
			btn.disabled = true
			# Add green tint overlay (or modulate)
			_apply_green_tint(btn)
		else:
			btn.disabled = false
			_remove_tint(btn)

func _apply_green_tint(btn: Button):
	# Modulate the button (works for TextureButton)
	btn.modulate = Color(0.6, 1, 0.6, 1)

func _remove_tint(btn: Button):
	btn.modulate = Color(1, 1, 1, 1)

func _on_pantheon_button_pressed(pantheon_name):
	selected_pantheon = pantheon_name
	confirm_name.text = pantheon_name.capitalize()
	# Optionally set confirm_art.texture here
	confirm_panel.visible = true

func _on_ConfirmButton_pressed():
	PantheonRunManager.select_pantheon(selected_pantheon)
	get_tree().change_scene_to_file("res://scenes/pantheon_map.tscn")

func _on_CancelButton_pressed():
	confirm_panel.visible = false
