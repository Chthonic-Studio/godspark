extends CardEffect
@export var damage: int = 5

func _init():
	effect_name = "On Reveal: Damage"
	description = "On reveal: Deals %d direct damage to enemy commander health." % damage

func execute(card: CardData, context: Dictionary) -> void:
	if context.has("target_commander"):
		var target_commander = context["target_commander"]
		CombatManager.deal_commander_damage(target_commander, damage)
