extends Control
class_name CardUI

@export var card_data: Resource # CardData (legacy, but keep for now)
var card_instance: Dictionary = {}
var is_selected: bool = false
var is_hovered: bool = false

signal card_selected(card_ui)
signal card_play_attempt(card_ui)
signal card_cancelled(card_ui)

func _ready():
	update_card_visuals()
	connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	connect("mouse_exited", Callable(self, "_on_mouse_exited"))

# New: Accept either instance or CardData for legacy compatibility
func set_card_instance(instance: Dictionary):
	card_instance = instance
	card_data = card_instance.get("card_data", null)
	update_card_visuals()

func set_card_data(data: Resource):
	card_data = data
	card_instance = {}
	update_card_visuals()

func update_card_visuals():
	# Use card_instance if present, else fallback to card_data
	var cd = card_instance.get("card_data", null) if card_instance else card_data
	if not cd:
		return
	$NameLabel.text = cd.name
	$CostLabel.text = str(cd.cost)
	$PowerLabel.text = str(cd.power) if cd.power != 0 else ""
	$HealthLabel.text = str(cd.health) if cd.health != 0 else ""
	$Art.texture = cd.art if cd.art else null
	$EffectLabel.text = cd.description
	$HealthLabel.visible = cd.type != "Spell"
	$PowerLabel.visible = cd.type != "Spell"
	# Optional: show instance-specific values here (e.g., current_hp, corruption)
	if card_instance and card_instance.has("current_hp"):
		$HealthLabel.text = str(card_instance.current_hp)

	# --- Corruption visual indicator ---
	# Hide all by default
	var corruption_control = $CorruptionControl if has_node("CorruptionControl") else null
	if corruption_control:
		for i in range(1, 5):
			var node_name = "Corruption%d" % i
			if corruption_control.has_node(node_name):
				corruption_control.get_node(node_name).visible = false

		# Only show for Divine Soldiers
		if card_instance and card_instance.has("type") and card_instance.type == "DivineSoldier":
			var corruption = card_instance.get("void_corruption", 0)
			for i in range(1, min(corruption, 4) + 1):
				var node_name = "Corruption%d" % i
				if corruption_control.has_node(node_name):
					corruption_control.get_node(node_name).visible = true

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		emit_signal("card_selected", self)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		if is_selected:
			emit_signal("card_cancelled", self)
			is_selected = false
			$HighlightOverlay.visible = false
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if is_selected:
			emit_signal("card_cancelled", self)
			is_selected = false
			$HighlightOverlay.visible = false

func get_drag_data(_pos):
	var drag_preview = duplicate()
	return drag_preview

func can_drop_data(_pos, data):
	return true

func drop_data(_pos, data):
	emit_signal("card_play_attempt", self)

func _on_mouse_entered():
	is_hovered = true
	$HighlightOverlay.visible = true

func _on_mouse_exited():
	is_hovered = false
	if not is_selected:
		$HighlightOverlay.visible = false
		
