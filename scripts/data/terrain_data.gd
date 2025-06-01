extends Resource
class_name TerrainData

enum TERRAIN_OWNER_TYPES { PLAYER, VOID, GREAT_VOID, GREEK_PANTHEON, NORSE_PANTHEON, EGYPTIAN_PANTHEON, 
CELTIC_PANTHEON, SHINTO_PANTHEON, HINDU_PANTHEON, CHINESE_PANTHEON, MESOPOTAMIAN_PANTHEON,
AZTEC_PANTHEON, MAYAN_PANTHEON, INCAN_PANTHEON, YORUBA_PANTHEON, ZOROASTRIAN_PANTHEON,
POLYNESIAN_PANTHEON, KALEVALA_PANTHEON, IROQUOIS_PANTHEON }

@export var id: String
@export var name: String
@export var effect_description: String
@export var triggers: Array[Dictionary] # e.g., on_enter, on_end_turn, etc.
@export var owner_type: TERRAIN_OWNER_TYPES # "Player", "Void", "Pantheon"
@export var art: Texture2D
