extends CardEffect
class_name OnRevealModifierEffect

const EffectEnums = preload("res://scripts/effects/effect_enums.gd")
const EffectUtils = preload("res://scripts/effects/effect_utils.gd")

@export var power_modifier: int = 0
@export var health_modifier: int = 0

@export var affected_locations: Array[EffectEnums.Location] = [EffectEnums.Location.ANY]
@export var target_side: EffectEnums.Side = EffectEnums.Side.ALLY

@export var target_rows_allies: Array[EffectEnums.Row] = [EffectEnums.Row.BOTH]
@export var target_rows_enemies: Array[EffectEnums.Row] = [EffectEnums.Row.BOTH]

@export var exclude_self: bool = true

@export var target_self_only: bool = false # Only modify the card holding the effect if true

@export var target_type: EffectEnums.TargetType = EffectEnums.TargetType.ALL
@export var threshold: int = 0
@export var stat_type: EffectEnums.Stat = EffectEnums.Stat.POWER
@export var only_in_location: bool = true

func is_ongoing() -> bool:
	return false

func execute(card: CardData, context: Dictionary) -> void:
	var targets = []
	if target_self_only:
		# Only target the card holding this effect (played card)
		if context.has("card_instance"):
			targets = [context["card_instance"]]
		elif context.has("card"): # fallback for consistency
			targets = [context["card"]]
	else:
		# Use normal targeting logic
		var board = context.get("board")
		var location = context.get("location")
		var side = context.get("side")
		var card_instance = context.get("card") if context.has("card") else {}
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
	# Apply stat changes
	for t in targets:
		var inst = t if typeof(t) == TYPE_DICTIONARY else t
		if typeof(inst) == TYPE_DICTIONARY and inst.has("card"): # for EffectUtils targets
			inst = inst["card"]
		if power_modifier != 0:
			if inst.has("current_hp"): # assuming only units with HP get power
				inst["card_data"].power += power_modifier
		if health_modifier != 0 and inst.has("current_hp"):
			inst["current_hp"] += health_modifier
			inst["card_data"].health += health_modifier # update base as well if needed

func get_preview_text(card: CardData) -> String:
	if target_self_only:
		return "On Reveal: This card gets %+d Power, %+d Health." % [power_modifier, health_modifier]
	else:
		return "On Reveal: Affected targets get %+d Power, %+d Health." % [power_modifier, health_modifier]
