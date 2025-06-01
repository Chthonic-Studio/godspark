extends Node

var thresholds: Dictionary = {
	10: "Despairing Zealot",
	20: "Fanatical Crusader",
	# etc.
}

func check_thresholds(soldier: DivineSoldier):
	for level in thresholds.keys():
		if soldier.void_corruption >= level:
			apply_affliction(soldier, thresholds[level])

func apply_affliction(soldier: DivineSoldier, affliction: String):
	# Give affliction, apply penalties/traits, trigger temporary/permanent changes
	pass

func handle_void_touched(soldier: DivineSoldier):
	# Apply permanent traits if corruption is extreme
	pass
