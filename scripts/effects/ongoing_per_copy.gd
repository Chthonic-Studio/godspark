extends CardEffect
class_name OngoingPerCopyEffect

const EffectEnums = preload("res://scripts/effects/effect_enums.gd")

@export var power_modifier_per_copy: int = 0
@export var health_modifier_per_copy: int = 0

@export var affect_all_allies: bool = true # If false, only this card gets buff
@export var only_in_own_location: bool = false # If true, only counts copies in same location as this card

@export var reduce_commander_damage_per_copy: int = 0 # If > 0, reduces commander damage (player HP loss) per copy

@export var effect_duration_turns: int = -1 # -1 = permanent, otherwise effect lasts X turns

# Optional: more "per copy" toggles could be added here

# --- Internal state ---
var active_turns: int = 0

func _init():
	effect_name = "Ongoing: Per-Copy Modifier"
	description = _generate_description()

func is_ongoing() -> bool:
	return true

func should_trigger(turn: int) -> bool:
	if effect_duration_turns < 0:
		return true
	return active_turns < effect_duration_turns

# Called by BoardManager in ongoing effect context
func apply_ongoing_buff(context: Dictionary) -> void:
	# context: { "board": BoardManager, "location": String, "side": String, "slot_idx": int, "card": card_instance }
	var board = context.get("board")
	var location = context.get("location")
	var side = context.get("side")
	var slot_idx = context.get("slot_idx")
	var card_instance = context.get("card")
	var card_data = card_instance.get("card_data", null)
	if not card_data:
		return

	var card_id = card_data.id
	var locations_to_check = []
	if only_in_own_location:
		locations_to_check = [location]
	else:
		locations_to_check = board.locations

	var copy_count = 0
	for loc in locations_to_check:
		for idx in range(4):
			var ci = board.board[loc][side][idx]
			if ci and ci.get("card_data", null) and ci["card_data"].id == card_id:
				copy_count += 1

	# Apply stat buffs per copy
	if affect_all_allies:
		for loc in locations_to_check:
			for idx in range(4):
				var ally = board.board[loc][side][idx]
				if ally:
					# Add temp_buffs for power (permanent for duration)
					if power_modifier_per_copy != 0:
						if not ally.has("temp_buffs"):
							ally["temp_buffs"] = []
						ally["temp_buffs"].append({
							"stat": "power",
							"amount": power_modifier_per_copy * copy_count,
							"turns_left": effect_duration_turns
						})
					if health_modifier_per_copy != 0:
						if ally.has("current_hp"):
							ally["current_hp"] += health_modifier_per_copy * copy_count
						var cd = ally.get("card_data", null)
						if cd and cd.has_property("health"):
							cd.health += health_modifier_per_copy * copy_count
	else:
		# Only this card gets buff
		if power_modifier_per_copy != 0:
			if not card_instance.has("temp_buffs"):
				card_instance["temp_buffs"] = []
			card_instance["temp_buffs"].append({
				"stat": "power",
				"amount": power_modifier_per_copy * copy_count,
				"turns_left": effect_duration_turns
			})
		if health_modifier_per_copy != 0:
			if card_instance.has("current_hp"):
				card_instance["current_hp"] += health_modifier_per_copy * copy_count
			if card_data and card_data.has_property("health"):
				card_data.health += health_modifier_per_copy * copy_count

	# Track turns if duration is set
	if effect_duration_turns > 0:
		active_turns += 1

# Optional: override BoardManager or CombatManager to apply reduce_commander_damage_per_copy when dealing commander damage

func get_commander_damage_reduction(board, side, card_id) -> int:
	# Used from CombatManager when reducing player HP
	var copy_count = 0
	for loc in board.locations:
		for idx in range(4):
			var ci = board.board[loc][side][idx]
			if ci and ci.get("card_data", null) and ci["card_data"].id == card_id:
				copy_count += 1
	return reduce_commander_damage_per_copy * copy_count

func _generate_description() -> String:
	var text = "Ongoing: For each copy of this card in play"
	if only_in_own_location:
		text += " (in the same location)"
	text += ", "
	if affect_all_allies:
		text += "allies"
	else:
		text += "this card"
	if power_modifier_per_copy != 0:
		text += " gain %+d Power" % power_modifier_per_copy
	if health_modifier_per_copy != 0:
		text += " gain %+d Health" % health_modifier_per_copy
	if reduce_commander_damage_per_copy > 0:
		text += ". Commander takes %d less damage per copy" % reduce_commander_damage_per_copy
	if effect_duration_turns > 0:
		text += " (lasts %d turns)" % effect_duration_turns
	return text + "."

func get_preview_text(card: CardData) -> String:
	return _generate_description()
