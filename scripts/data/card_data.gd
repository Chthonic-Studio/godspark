extends Resource
class_name CardData

enum CardType { DIVINE_SOLDIER, LEVY, SPELL }
enum Pantheon {
	THE_DREAMING_MAW, THE_INFINITE_MESSENGER, THE_PRIMAL_ROIL, THE_DIMENSIONAL_WEAVE, THE_BLACK_FERTILITY, THE_PALE_SIGN,
	THE_ABYSSAL_STALKER, THE_TIME_ECHOING_SPIRES, THE_WEAVER_CHASM, THE_FORMLESS_VEIL, THE_SLUMBERING_ABYSS, THE_CORRUPTED_TWINS,
	THE_FROST_HARBRINGER, THE_DUALITY_OF_DESOLATION, THE_BLIGHTED_BLOOM, THE_ELDEST_PUTRESENCE,
	GREEK_PANTHEON, NORSE_PANTHEON, EGYPTIAN_PANTHEON, CELTIC_PANTHEON, SHINTO_PANTHEON, HINDU_PANTHEON, CHINESE_PANTHEON,
	MESOPOTAMIAN_PANTHEON, AZTEC_PANTHEON, MAYAN_PANTHEON, INCAN_PANTHEON, YORUBA_PANTHEON, ZOROASTRIAN_PANTHEON,
	POLYNESIAN_PANTHEON, KALEVALA_PANTHEON, IROQUOIS_PANTHEON
}

@export var id: String
@export var name: String
@export var description: String
@export var type: CardType
@export var cost: int
@export var pantheon: Pantheon
@export var effects: Array[CardEffect] 
@export var tags: Array[String]
@export var requirements: Dictionary

@export var power: int = 0
@export var health: int = 0
@export var art: Texture2D

func get_power():
	var total = power
	if has_meta("temp_buffs"):
		for buff in get_meta("temp_buffs"):
			if buff.get("stat", "") == "power":
				total += buff.get("amount", 0)
	return total
