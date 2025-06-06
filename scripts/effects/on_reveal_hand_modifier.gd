extends CardEffect
class_name OnRevealHandModifier

const EffectEnums = preload("res://scripts/effects/effect_enums.gd")

enum HandTarget { PLAYER, ENEMY }
enum SelectMode { ALL, X_RANDOM, X_HIGHEST }

# --- Inspector variables ---
@export var power_modifier: int = 0
@export var health_modifier: int = 0
@export var cost_modifier: int = 0

@export var hand_target: HandTarget = HandTarget.PLAYER
@export var select_mode: SelectMode = SelectMode.ALL
@export var selection_count: int = 1 # Used if not ALL
@export var highest_stat_type: EffectEnums.Stat = EffectEnums.Stat.POWER # Used if X_HIGHEST

@export var target_self_only: bool = false # If true, only modify the card holding the effect

func is_ongoing() -> bool:
	return false

func execute(card: CardData, context: Dictionary) -> void:
	# --- Get hand reference ---
	var hand_manager = context.get("hand_manager", null)
	var enemy_deck_manager = context.get("enemy_deck_manager", null)
	var target_hand: Array = []

	if hand_target == HandTarget.PLAYER and hand_manager:
		target_hand = DeckManager.hand
	elif hand_target == HandTarget.ENEMY and enemy_deck_manager:
		target_hand = enemy_deck_manager.hand

	if target_hand.is_empty():
		return

	var targets = []

	if target_self_only:
		# Only affect the card holding this effect if it's in hand
		var card_instance = context.get("card_instance", null)
		if card_instance and target_hand.has(card_instance):
			targets = [card_instance]
		else:
			# If not found in hand, do nothing
			return
	else:
		# --- Selection logic ---
		if select_mode == SelectMode.ALL:
			targets = target_hand.duplicate()
		elif select_mode == SelectMode.X_RANDOM:
			var indices = []
			for i in range(target_hand.size()):
				indices.append(i)
			indices.shuffle()
			for i in range(min(selection_count, target_hand.size())):
				targets.append(target_hand[indices[i]])
		elif select_mode == SelectMode.X_HIGHEST:
			targets = target_hand.duplicate()
			match highest_stat_type:
				EffectEnums.Stat.POWER:
					targets.sort_custom(func(a, b): return _get_card_power(b) - _get_card_power(a))
				EffectEnums.Stat.HEALTH:
					targets.sort_custom(func(a, b): return _get_card_health(b) - _get_card_health(a))
				_:
					targets.sort_custom(func(a, b): return _get_card_cost(b) - _get_card_cost(a))
			targets = targets.slice(0, selection_count)
	
	# --- Apply modifiers ---
	for card_inst in targets:
		var cd = card_inst.get("card_data", null)
		if not cd:
			continue
		if power_modifier != 0:
			cd.power += power_modifier
		if health_modifier != 0:
			cd.health += health_modifier
			if card_inst.has("current_hp"):
				card_inst["current_hp"] += health_modifier
		if cost_modifier != 0:
			cd.cost = max(0, cd.cost + cost_modifier)
			
	if hand_manager and hand_target == HandTarget.PLAYER:
		hand_manager.refresh_hand()

# --- Helper functions for sorting ---
func _get_card_power(card_inst: Dictionary) -> int:
	var cd = card_inst.get("card_data", null)
	return cd.power if cd else 0

func _get_card_health(card_inst: Dictionary) -> int:
	var cd = card_inst.get("card_data", null)
	return cd.health if cd else 0

func _get_card_cost(card_inst: Dictionary) -> int:
	var cd = card_inst.get("card_data", null)
	return cd.cost if cd else 0

func get_preview_text(card: CardData) -> String:
	if target_self_only:
		var what = []
		if power_modifier != 0:
			what.append("Power %+d" % power_modifier)
		if health_modifier != 0:
			what.append("Health %+d" % health_modifier)
		if cost_modifier != 0:
			what.append("Cost %+d" % cost_modifier)
		var what_str = ", ".join(what)
		return "On Reveal: This card in hand gets %s." % what_str
	else:
		var who = "your hand" if hand_target == HandTarget.PLAYER else "the enemy hand"
		var what = []
		if power_modifier != 0:
			what.append("Power %+d" % power_modifier)
		if health_modifier != 0:
			what.append("Health %+d" % health_modifier)
		if cost_modifier != 0:
			what.append("Cost %+d" % cost_modifier)
		var what_str = ", ".join(what)
		var how = ""
		match select_mode:
			SelectMode.ALL:
				how = "all cards in"
			SelectMode.X_RANDOM:
				how = "%d random card(s) in" % selection_count
			SelectMode.X_HIGHEST:
				var stat = ["Power", "Health", "Cost"][int(highest_stat_type)]
				how = "%d highest-%s card(s) in" % [selection_count, stat]
		return "On Reveal: %s %s %s." % [how, who, what_str]
