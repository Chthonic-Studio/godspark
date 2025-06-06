extends CardEffect
class_name OnRevealDraw

enum DrawSource { PLAYER, ENEMY }
enum DrawOrder { TOP, BOTTOM, RANDOM }

@export var draw_count: int = 1
@export var draw_source: DrawSource = DrawSource.PLAYER
@export var draw_order: DrawOrder = DrawOrder.TOP

func is_ongoing() -> bool:
	return false

func execute(card: CardData, context: Dictionary) -> void:
	# context: { "combat_manager": CombatManager, ... }
	var cm = context.get("combat_manager")
	var deck_mgr = null
	if draw_source == DrawSource.PLAYER:
		deck_mgr = DeckManager
	elif draw_source == DrawSource.ENEMY:
		deck_mgr = cm.enemy_deck_manager if cm else null
	if not deck_mgr:
		return

	for i in draw_count:
		var drawn_card = null
		if draw_order == DrawOrder.TOP:
			if deck_mgr.draw_pile.is_empty():
				deck_mgr.reshuffle_discard_into_draw()
			if deck_mgr.draw_pile.is_empty():
				break
			drawn_card = deck_mgr.draw_pile.back()
			deck_mgr.draw_pile.remove_at(deck_mgr.draw_pile.size() - 1)
		elif draw_order == DrawOrder.BOTTOM:
			if deck_mgr.draw_pile.is_empty():
				deck_mgr.reshuffle_discard_into_draw()
			if deck_mgr.draw_pile.is_empty():
				break
			drawn_card = deck_mgr.draw_pile.front()
			deck_mgr.draw_pile.remove_at(0)
		elif draw_order == DrawOrder.RANDOM:
			if deck_mgr.draw_pile.is_empty():
				deck_mgr.reshuffle_discard_into_draw()
			if deck_mgr.draw_pile.is_empty():
				break
			var idx = randi() % deck_mgr.draw_pile.size()
			drawn_card = deck_mgr.draw_pile[idx]
			deck_mgr.draw_pile.remove_at(idx)
		if drawn_card:
			deck_mgr.hand.append(drawn_card)

func get_preview_text(card: CardData) -> String:
	var who = "your" if draw_source == DrawSource.PLAYER else "enemy's"
	var where = "top" if draw_order == DrawOrder.TOP else ("bottom" if draw_order == DrawOrder.BOTTOM else "random")
	return "On Reveal: Draw %d card(s) from the %s of %s deck." % [draw_count, where, who]
