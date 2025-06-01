extends Node
class_name ZoneGenerator

func generate_zone(pantheon: String, difficulty: int) -> Array[Dictionary]:
	var zone_nodes = []
	# Create a list of encounter/event/boss nodes with growing challenge
	# For example:
	for i in range(4 + difficulty):
		var node = {
			"type": "combat" if randi() % 2 == 0 else "event",
			"enemies": [], # Fill with enemy data
			"terrain": null # Will be set at battle start
		}
		zone_nodes.append(node)
	return zone_nodes
