extends CardEffect
@export var damage: int = 3

func _init():
	effect_name = "OnRevealDamageNext"

func execute(card: CardData, context: Dictionary) -> void:
	var board = context["board"]
	var location = context["location"]
	var opponent = "enemy" if context["owner"] == "player" else "player"
	var key = "%s_%s" % [location, opponent]
	board.pending_on_play_damage[key] = damage
