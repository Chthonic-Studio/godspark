extends Node
class_name ZoneGenerator

# Place this on CombatScene as a node: Handles terrain assignment for combat

# Returns a terrain assignment dictionary for the current combat node:
# { "left": TerrainData (void), "middle": TerrainData (pantheon), "right": TerrainData (player) }
func get_combat_terrain_assignment(node_terrain: Dictionary, player_terrain: Resource) -> Dictionary:
	return {
		"left": node_terrain.get("void"),
		"middle": node_terrain.get("pantheon"),
		"right": player_terrain
	}
