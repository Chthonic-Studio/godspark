extends CardEffect
class_name OngoingModifierEffect

const EffectEnums = preload("res://scripts/effects/effect_enums.gd")
const EffectUtils = preload("res://scripts/effects/effect_utils.gd")

enum BuffMode { STATIC, CONSTANT }

@export var power_modifier: int = 0
@export var health_modifier: int = 0

@export var affected_locations: Array[EffectEnums.Location] = [EffectEnums.Location.ANY]
@export var target_side: EffectEnums.Side = EffectEnums.Side.ALLY

@export var target_rows_allies: Array[EffectEnums.Row] = [EffectEnums.Row.BOTH]
@export var target_rows_enemies: Array[EffectEnums.Row] = [EffectEnums.Row.BOTH]

@export var buff_mode: BuffMode = BuffMode.STATIC

@export var exclude_self: bool = true

@export var target_self_only: bool = false # <--- NEW: Only affect the host card if true

@export var require_self_in_location: bool = false
@export var trigger_locations: Array[EffectEnums.Location] = [EffectEnums.Location.ANY]
@export var effect_frequency_turns: int = 1 # 1 = every turn, 2 = every 2 turns, etc.

@export var target_type: EffectEnums.TargetType = EffectEnums.TargetType.ALL
@export var threshold: int = 0
@export var stat_type: EffectEnums.Stat = EffectEnums.Stat.POWER
@export var only_in_location: bool = true

var turn_counter: int = 0

func _init():
	effect_name = "Ongoing Modifier (Buff/Debuff)"
	description = _generate_description()

func is_ongoing() -> bool:
	return true

func get_preview_text(card: CardData) -> String:
	return _generate_description()

# Main: Called by BoardManager.resolve_ongoing_effects() every turn
func apply_ongoing_buff(context: Dictionary) -> void:
	if buff_mode == BuffMode.STATIC:
		return # Aura/static: handled in calculate_power, do NOT apply per turn!

	# Frequency gating
	turn_counter += 1
	if effect_frequency_turns > 1 and (turn_counter % effect_frequency_turns) != 0:
		return

	var targets = []
	if target_self_only:
		# Only target the card holding this effect
		if context.has("card"):
			targets = [context["card"]]
	else:
		# Use modular targeting system
		var board = context.get("board")
		var location = context.get("location")
		var side = context.get("side")
		var card_instance = context.get("card")
		var row_arr = target_rows_allies if target_side == EffectEnums.Side.ALLY else target_rows_enemies
		targets = EffectUtils.get_targets(
			board, location, side,
			affected_locations,
			target_side,
			row_arr,
			target_type,
			threshold,
			stat_type,
			only_in_location,
			exclude_self,
			card_instance
		)
	# Apply modifiers
	for t in targets:
		var inst = t if typeof(t) == TYPE_DICTIONARY else t
		if typeof(inst) == TYPE_DICTIONARY and inst.has("card"): # for EffectUtils targets
			inst = inst["card"]
		if power_modifier != 0:
			if not inst.has("temp_buffs"):
				inst["temp_buffs"] = []
			inst["temp_buffs"].append({
				"stat": "power",
				"amount": power_modifier,
				"turns_left": effect_frequency_turns if effect_frequency_turns > 1 else -1
			})
		if health_modifier != 0 and inst.has("current_hp"):
			inst["current_hp"] += health_modifier
			# Optionally handle removal if current_hp <= 0

func should_trigger(turn: int) -> bool:
	if effect_frequency_turns <= 1:
		return true
	return (turn % effect_frequency_turns) == 0

# (Description code unchanged)
func _generate_description() -> String:
	var stat_parts = []
	if power_modifier != 0:
		stat_parts.append("Power %+d" % power_modifier)
	if health_modifier != 0:
		stat_parts.append("Health %+d" % health_modifier)
	var stat_str = " and ".join(stat_parts)
	var freq_str = ""
	if effect_frequency_turns > 1:
		freq_str = " (every %d turns)" % effect_frequency_turns

	var ally_rows = []
	for row in target_rows_allies:
		ally_rows.append(EffectEnums.Row.keys()[row].capitalize())
	var ally_row_str = ", ".join(ally_rows)

	var enemy_rows = []
	for row in target_rows_enemies:
		enemy_rows.append(EffectEnums.Row.keys()[row].capitalize())
	var enemy_row_str = ", ".join(enemy_rows)

	var loc_names = []
	for loc in affected_locations:
		loc_names.append(EffectEnums.Location.keys()[loc].capitalize())
	var loc_str = ", ".join(loc_names)

	var target_str = ""
	if target_self_only:
		target_str = "this card only"
	elif target_side == EffectEnums.Side.ALLY:
		target_str = "allies in rows [%s]" % ally_row_str
	elif target_side == EffectEnums.Side.ENEMY:
		target_str = "enemies in rows [%s]" % enemy_row_str
	else:
		target_str = "allies in [%s] and enemies in [%s]" % [ally_row_str, enemy_row_str]

	if require_self_in_location:
		var trigger_names = []
		for loc in trigger_locations:
			trigger_names.append(EffectEnums.Location.keys()[loc].capitalize())
		return "Ongoing: While this card is in [%s], %s at [%s] gain %s%s." % [
			", ".join(trigger_names),
			target_str,
			loc_str,
			stat_str,
			freq_str
		]
	else:
		return "Ongoing: %s at [%s] gain %s%s." % [
			target_str,
			loc_str,
			stat_str,
			freq_str
		]
