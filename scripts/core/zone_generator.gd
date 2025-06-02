extends Node
class_name ZoneGenerator

const TerrainPool = preload("res://scripts/data/terrain_pools.gd")

func get_random_from_array(arr: Array) -> Resource:
	if arr.is_empty():
		return null
	return arr[randi() % arr.size()]

func generate_zone(pantheon: String, difficulty: int, player_terrains: Array) -> Array[Dictionary]:
	var zone_nodes = []
	for i in range(4 + difficulty):
		var node_type = "combat" if randi() % 2 == 0 else "event"
		var node = {
			"type": node_type,
			"enemies": [],
			"terrain": null
		}
		if node_type == "combat":
			var terrain_assignments = {
				"left": get_random_from_array(TerrainPool.VOID_TERRAIN_POOL),
				"middle": get_random_from_array(TerrainPool.PANTHEON_TERRAIN_POOLS.get(pantheon, [])),
				"right": get_random_from_array(player_terrains)
			}
			node["terrain"] = terrain_assignments
		zone_nodes.append(node)
	return zone_nodes
