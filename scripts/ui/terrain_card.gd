extends Control

@onready var art = $Art
@onready var name_label = $NameLabel
@onready var effect_label = $EffectLabel
@onready var highlight_overlay = $CardBG/HighlightOverlay

@export var terrain_data: Resource

var is_selected: bool = false
var _pending_terrain: Resource = null

func _ready():
	if _pending_terrain != null:
		set_terrain(_pending_terrain)

func set_terrain(terrain: Resource):
	# If not ready, store and run later
	if name_label == null:
		_pending_terrain = terrain
		return

	terrain_data = terrain
	_pending_terrain = null

	name_label.text = terrain_data.name
	effect_label.text = terrain_data.effect_description if terrain_data.effect_description != null else "Placeholder Text for Terrain"
	if terrain_data.art != null:
		art.texture = terrain_data.art

func set_selected(selected: bool):
	if highlight_overlay:
		highlight_overlay.visible = selected
