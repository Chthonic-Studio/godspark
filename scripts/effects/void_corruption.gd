extends CardEffect
class_name VoidCorruptionEffect

const EffectEnums = preload("res://scripts/effects/effect_enums.gd")
const EffectUtils = preload("res://scripts/effects/effect_utils.gd")
const CardData = preload("res://scripts/data/card_data.gd")

# --- Inspector variables ---

@export var corruption_amount: int = 1
@export var ongoing: bool = false # Instead of 'is_ongoing'
@export var affected_locations: Array[EffectEnums.Location] = [EffectEnums.Location.ANY]
@export var target_side: EffectEnums.Side = EffectEnums.Side.ENEMY # Typically, corrupts enemy, but you can set to ALLY for self/ally sabotage

@export var target_rows_allies: Array[EffectEnums.Row] = [EffectEnums.Row.BOTH]
@export var target_rows_enemies: Array[EffectEnums.Row] = [EffectEnums.Row.BOTH]

@export var target_type: EffectEnums.TargetType = EffectEnums.TargetType.ALL # ALL, RANDOM, HIGHEST_POWER, etc.
@export var threshold: int = 0 # Used for above/below threshold
@export var stat_type: EffectEnums.Stat = EffectEnums.Stat.POWER
@export var only_in_location: bool = true
@export var exclude_self: bool = true
@export var selection_count: int = 1 # Used for random/highest/lowest, etc.

@export var target_self_only: bool = false # If true, only the card holding the effect

# --- Ongoing frequency (for modular ongoing logic) ---
@export var effect_frequency_turns: int = 1 # 1 = every turn, 2 = every 2 turns, etc.

var turn_counter: int = 0

# --- Effect type hooks ---

func is_ongoing() -> bool:
	return ongoing

# --- Main effect trigger (On Reveal or per turn for ongoing) ---
func execute(card: CardData, context: Dictionary) -> void:
	_apply_void_corruption(context)

# --- Ongoing effect hook (called by BoardManager.resolve_ongoing_effects) ---
func apply_ongoing_buff(context: Dictionary) -> void:
	turn_counter += 1
	if effect_frequency_turns > 1 and (turn_counter % effect_frequency_turns) != 0:
		return
	_apply_void_corruption(context)

# --- Core logic, shared by both modes ---
func _apply_void_corruption(context: Dictionary) -> void:
	var targets = []
	if target_self_only:
		if context.has("card"):
			targets = [context["card"]]
	else:
		var board = context.get("board")
		var location = context.get("location")
		var side = context.get("side")
		var card_instance = context.get("card") if context.has("card") else null
		var row_arr = target_rows_allies if target_side == EffectEnums.Side.ALLY else target_rows_enemies

		# Use utility targeting logic (as in other modular scripts)
		targets = EffectUtils.get_targets(
			board,
			location,
			side,
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

		# If targeting random or selection_count, trim result
		if (target_type == EffectEnums.TargetType.ALL or targets.size() <= selection_count):
			pass # keep all
		else:
			targets.shuffle()
			targets = targets.slice(0, selection_count)

	# Apply void corruption only to Divine Soldiers
	for t in targets:
		var inst = t if typeof(t) == TYPE_DICTIONARY else t
		if typeof(inst) == TYPE_DICTIONARY and inst.has("card"):
			inst = inst["card"]
		# Divine Soldier check (by type string or enum)
		if inst.has("type"):
			var is_divine = false
			if typeof(inst.type) == TYPE_STRING:
				is_divine = inst.type == "DivineSoldier"
			elif typeof(inst.type) == TYPE_INT and CardData.CardType.has("DIVINE_SOLDIER"):
				is_divine = inst.type == CardData.CardType.DIVINE_SOLDIER
			if is_divine:
				inst["void_corruption"] = inst.get("void_corruption", 0) + corruption_amount

# --- Preview text for UI ---
func get_preview_text(card: CardData) -> String:
	var freq = "each turn" if is_ongoing else "on reveal"
	var who = ""
	if target_self_only:
		who = "this card"
	else:
		match target_type:
			EffectEnums.TargetType.ALL:
				who = "all Divine Soldiers"
			EffectEnums.TargetType.HIGHEST_POWER:
				who = "the highest power Divine Soldier"
			EffectEnums.TargetType.LOWEST_POWER:
				who = "the lowest power Divine Soldier"
			EffectEnums.TargetType.ABOVE_POWER_THRESHOLD:
				who = "Divine Soldiers above %d power" % threshold
			EffectEnums.TargetType.BELOW_POWER_THRESHOLD:
				who = "Divine Soldiers below %d power" % threshold
			EffectEnums.TargetType.HIGHEST_HEALTH:
				who = "the highest health Divine Soldier"
			EffectEnums.TargetType.LOWEST_HEALTH:
				who = "the lowest health Divine Soldier"
			EffectEnums.TargetType.ABOVE_HEALTH_THRESHOLD:
				who = "Divine Soldiers above %d health" % threshold
			EffectEnums.TargetType.BELOW_HEALTH_THRESHOLD:
				who = "Divine Soldiers below %d health" % threshold
			_:
				who = "target Divine Soldier(s)"
	return "Deal %d Void Corruption to %s %s." % [corruption_amount, who, freq]

# --- How to use ---
# 1. Attach this script to a CardEffect resource.
# 2. Set inspector variables: amount, is_ongoing, targeting, etc.
# 3. Add effect to card's effects array (in CardData).
# 4. For ongoing: BoardManager will call apply_ongoing_buff(); for on reveal: execute() will be called.
