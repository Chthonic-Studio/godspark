extends Resource
class_name CardEffect
@export var effect_name: String = ""
@export var description: String = ""

# Called when the effect is triggered.
# Arguments: card (CardData), context (Dictionary with relevant data: board state, owner, target, location, etc.)
func execute(card: CardData, context: Dictionary) -> void:
	pass # To be implemented by child classes

# Utility: Override in children if effect is ongoing or conditional
func is_ongoing() -> bool:
	return false

# Utility: For UI previewing
func get_preview_text(card: CardData) -> String:
	return description
