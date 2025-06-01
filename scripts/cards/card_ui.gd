extends Control
class_name CardUI

# What you need to know (and do) when instancing and wiring CardUI:
# 1. Card Data Connection:
#    - Each CardUI instance must have its CardData resource assigned (e.g., via set_card_data(card_data)).
#    - Call update_card_visuals() after assignment to sync UI.
# 2. Signals:
#    - Use signals (card_selected, card_play_attempt, card_cancelled) to communicate with hand/board/input managers.
#    - Connect signals on instancing, e.g.:
#        card_ui.card_play_attempt.connect(_on_card_play_attempt)
# 3. Drag-and-Drop & Click-to-Play:
#    - Drag-and-drop: CardUI implements get_drag_data(), can_drop_data(), drop_data().
#    - Click-to-select: CardUI emits card_selected on left-click, and highlights itself.
#    - Second click on a valid board slot (or drag drop) attempts to play the card.
#    - Cancel with ESC or RMB (emits card_cancelled).
# 4. Receivers:
#    - Board slot/location containers must implement can_drop_data() and drop_data() for drag-and-drop.
#    - For click-to-play, highlight valid slots and listen for user input.
# 5. Performance:
#    - Use Godot containers (GridContainer, HBoxContainer) for hand/board UI.
#    - Remove unused CardUI nodes with queue_free().
# 6. Consistency:
#    - Keep all game logic out of CardUI; handle it in managers (DeckManager, CombatManager, BoardManager).
# 7. Visual Feedback:
#    - Use HighlightOverlay for selection/hover states.
# 8. Extensibility:
#    - CardUI is used for hand, board, and deck displays. Add context flags if needed for special behaviors.

@export var card_data: Resource # CardData
var is_selected: bool = false
var is_hovered: bool = false

# Signals for drag-and-drop and click logic
signal card_selected(card_ui)
signal card_play_attempt(card_ui)
signal card_cancelled(card_ui)

func _ready():
	update_card_visuals()
	connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	connect("mouse_exited", Callable(self, "_on_mouse_exited"))

func set_card_data(data: Resource):
	card_data = data
	update_card_visuals()

func update_card_visuals():
	if not card_data:
		return
	$NameLabel.text = card_data.name
	$CostLabel.text = str(card_data.cost)
	$PowerLabel.text = str(card_data.power) if card_data.power != 0 else ""
	$HealthLabel.text = str(card_data.health) if card_data.health != 0 else ""
	$Art.texture = card_data.art if card_data.art else null
	$EffectLabel.text = card_data.description
	# Hide Power/Health for Spell cards
	$HealthLabel.visible = card_data.type != "Spell"
	$PowerLabel.visible = card_data.type != "Spell"
	# Additional tag/effect icons can be added here

# Drag-and-drop
func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		emit_signal("card_selected", self)
		# is_selected = true
		# $HighlightOverlay.visible = true
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

# Drag and drop
func get_drag_data(_pos):
	var drag_preview = duplicate()
	return drag_preview

func can_drop_data(_pos, data):
	return true # You can add logic to prevent illegal drops

func drop_data(_pos, data):
	emit_signal("card_play_attempt", self)

# Optional: Mouse hover feedback
func _on_mouse_entered():
	is_hovered = true
	$HighlightOverlay.visible = true

func _on_mouse_exited():
	is_hovered = false
	if not is_selected:
		$HighlightOverlay.visible = false
		
		
