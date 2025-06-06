extends CardEffect
class_name DivineEnergyModifierEffect

# Determines which side is affected
enum EnergyTarget { PLAYER, ENEMY }
# Determines whether the bonus is permanent (every turn) or temporary (next turn only)
enum BonusType { TEMPORARY, PERMANENT }

@export var energy_amount: int = 1
@export var energy_target: EnergyTarget = EnergyTarget.PLAYER
@export var bonus_type: BonusType = BonusType.TEMPORARY

func is_ongoing() -> bool:
	return bonus_type == BonusType.PERMANENT

# Called on On Reveal (when card is played)
func execute(card: CardData, context: Dictionary) -> void:
	var combat_manager = context.get("combat_manager", null)
	if not combat_manager:
		return
	
	match bonus_type:
		BonusType.TEMPORARY:
			_apply_temporary_energy_bonus(combat_manager)
		BonusType.PERMANENT:
			_apply_permanent_energy_bonus(combat_manager)

func _apply_temporary_energy_bonus(combat_manager):
	# Store the bonus for the next turn only, then clear it after it's used
	# We'll use a variable on the CombatManager for this; initialize if missing
	if not combat_manager.has_meta("temp_divinity_bonus"):
		combat_manager.set_meta("temp_divinity_bonus", {"player": 0, "enemy": 0})
	var key = "player" if energy_target == EnergyTarget.PLAYER else "enemy"
	var bonus_dict = combat_manager.get_meta("temp_divinity_bonus")
	bonus_dict[key] += energy_amount
	combat_manager.set_meta("temp_divinity_bonus", bonus_dict)

func _apply_permanent_energy_bonus(combat_manager):
	# Store the permanent gain in a variable; increase each turn in resolve_turn
	if not combat_manager.has_meta("permanent_divinity_bonus"):
		combat_manager.set_meta("permanent_divinity_bonus", {"player": 0, "enemy": 0})
	var key = "player" if energy_target == EnergyTarget.PLAYER else "enemy"
	var bonus_dict = combat_manager.get_meta("permanent_divinity_bonus")
	bonus_dict[key] += energy_amount
	combat_manager.set_meta("permanent_divinity_bonus", bonus_dict)

func get_preview_text(card: CardData) -> String:
	var who = "You" if energy_target == EnergyTarget.PLAYER else "the enemy"
	match bonus_type:
		BonusType.PERMANENT:
			return "On Reveal: %s gain %+d Divinity at the start of every turn for the rest of combat." % [who, energy_amount]
		BonusType.TEMPORARY:
			return "On Reveal: %s gain %+d Divinity next turn only." % [who, energy_amount]
	return ""
