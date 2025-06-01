extends CardEffect
@export var hp_loss: int = 2
@export var draw_amount: int = 1

func execute(card: CardData, context: Dictionary) -> void:
	if context["owner"] == "player":
		context["combat_manager"].player_health -= hp_loss
		DeckManager.draw_cards(draw_amount)
