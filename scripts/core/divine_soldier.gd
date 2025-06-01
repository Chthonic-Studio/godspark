extends Node
class_name DivineSoldier

@export var data: DivineSoldierData
var current_hp: int
var current_stats: Dictionary
var void_corruption: int
var is_echo: bool = false

func _ready():
	current_hp = data.max_hp
	current_stats = data.base_stats.duplicate()
	void_corruption = data.void_corruption

func apply_void_corruption(amount: int):
	void_corruption += amount
	# Call affliction/trait logic when thresholds are crossed

func take_damage(amount: int):
	current_hp = max(current_hp - amount, 0)
	if current_hp == 0:
		die()

func die():
	queue_free() # Remove from scene
	emit_signal("died", self)
	# Handle permadeath, echo logic externally
