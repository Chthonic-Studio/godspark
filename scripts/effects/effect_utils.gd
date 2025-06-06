extends Node

const EffectEnums = preload("res://scripts/effects/effect_enums.gd")

# Top-level helper: gets the correct stat
static func _get_stat(card_data, stat_type: String) -> int:
	if stat_type == "power":
		if card_data.has_method("get_power"):
			return card_data.get_power()
		elif "power" in card_data:
			return card_data.power
		return 0
	else:
		if "health" in card_data:
			return card_data.health
		return 0

# Modular targeting function for both ongoing and on-reveal effects
static func get_targets(
	board_manager,
	location,
	side,
	affected_locations,
	target_side,
	target_rows,
	target_type,
	threshold,
	stat_type,
	only_in_location,
	exclude_self := false,
	self_card_instance := {}
) -> Array:
	var results = []

	# 1. Which locations to check?
	var all_locations = []
	if "locations" in board_manager:
		all_locations = board_manager.locations
	else:
		all_locations = ["left", "middle", "right"]

	var locations_to_check = []
	if only_in_location and location != null:
		locations_to_check = [location]
	else:
		locations_to_check = all_locations.duplicate()

	# Filter by affected_locations (if not ANY)
	if affected_locations.size() > 0 and not affected_locations.has(EffectEnums.Location.ANY):
		var loc_names = []
		for loc_enum in affected_locations:
			loc_names.append(EffectEnums.Location.keys()[loc_enum].to_lower())
		var new_locs = []
		for loc in locations_to_check:
			if loc in loc_names:
				new_locs.append(loc)
		locations_to_check = new_locs

	# 2. Which sides to check?
	var check_sides = []
	if target_side == EffectEnums.Side.ALLY:
		check_sides = [side]
	elif target_side == EffectEnums.Side.ENEMY:
		check_sides = [("enemy" if side == "player" else "player")]
	else:
		check_sides = [side, ("enemy" if side == "player" else "player")]

	# 3. Find all matching card instances
	for loc in locations_to_check:
		for check_side in check_sides:
			var row_arr = target_rows
			if typeof(board_manager) == TYPE_OBJECT:
				if check_side != side and "target_rows_enemies" in board_manager:
					row_arr = board_manager.target_rows_enemies
				elif check_side == side and "target_rows_allies" in board_manager:
					row_arr = board_manager.target_rows_allies
			for idx in range(4):
				var in_row = (
					EffectEnums.Row.BOTH in row_arr or
					(idx < 2 and EffectEnums.Row.FRONT in row_arr) or
					(idx >= 2 and EffectEnums.Row.BACK in row_arr)
				)
				if not in_row:
					continue
				var card_instance = board_manager.board[loc][check_side][idx]
				if card_instance:
					if exclude_self and self_card_instance and card_instance == self_card_instance:
						continue
					results.append({
						"card": card_instance,
						"location": loc,
						"side": check_side,
						"slot": idx
					})

	# 4. Stat-based filtering
	if target_type == EffectEnums.TargetType.ALL:
		return results

	# Find highest/lowest (power/health)
	if target_type in [EffectEnums.TargetType.HIGHEST_POWER, EffectEnums.TargetType.LOWEST_POWER, EffectEnums.TargetType.HIGHEST_HEALTH, EffectEnums.TargetType.LOWEST_HEALTH]:
		var best_value = null
		var best_targets = []
		for r in results:
			var card_data = r["card"].get("card_data", null)
			if not card_data:
				continue
			var val = _get_stat(card_data, stat_type)
			if best_value == null or (
				(target_type in [EffectEnums.TargetType.HIGHEST_POWER, EffectEnums.TargetType.HIGHEST_HEALTH] and val > best_value) or
				(target_type in [EffectEnums.TargetType.LOWEST_POWER, EffectEnums.TargetType.LOWEST_HEALTH] and val < best_value)
			):
				best_value = val
				best_targets = [r]
			elif val == best_value:
				best_targets.append(r)
		return best_targets

	if target_type in [EffectEnums.TargetType.ABOVE_POWER_THRESHOLD, EffectEnums.TargetType.BELOW_POWER_THRESHOLD, EffectEnums.TargetType.ABOVE_HEALTH_THRESHOLD, EffectEnums.TargetType.BELOW_HEALTH_THRESHOLD]:
		var filtered = []
		for r in results:
			var card_data = r["card"].get("card_data", null)
			if not card_data:
				continue
			var val = _get_stat(card_data, stat_type)
			if (
				(target_type == EffectEnums.TargetType.ABOVE_POWER_THRESHOLD and val > threshold) or
				(target_type == EffectEnums.TargetType.BELOW_POWER_THRESHOLD and val < threshold) or
				(target_type == EffectEnums.TargetType.ABOVE_HEALTH_THRESHOLD and val > threshold) or
				(target_type == EffectEnums.TargetType.BELOW_HEALTH_THRESHOLD and val < threshold)
			):
				filtered.append(r)
		return filtered

	return []
