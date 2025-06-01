extends CardEffect
@export var amount: int = 1

func execute(card: CardData, context: Dictionary) -> void:
	if context["owner"] == "player":
		DeckManager.draw_cards(amount)
	elif context["owner"] == "enemy" and context.has("enemy_deck_manager"):
		context["enemy_deck_manager"].draw_cards(amount)
