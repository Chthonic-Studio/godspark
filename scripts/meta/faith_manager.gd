extends Node

var faith: int = 0

func add_faith(amount: int):
	faith += amount

func spend_faith(amount: int) -> bool:
	if faith >= amount:
		faith -= amount
		return true
	return false

# Unlocks, meta-progression, and upgrades can be managed here
