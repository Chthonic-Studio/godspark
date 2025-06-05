extends Control

# - Call `open_deck_editor(deck_instances)` to show the UI with the current deck.

@export var card_ui_scene: PackedScene

@onready var deck_grid = $VBoxContainer/HBoxContainer/DeckVBox/DeckGrid
@onready var type_counts_hbox = $VBoxContainer/HBoxContainer/TypeCountsHBox/TypeCounterVbox
@onready var error_label = $VBoxContainer/ErrorLabel
@onready var collection_grid = $VBoxContainer/CollectionVBox/CollectionScroll/CollectionGrid
@onready var fallen_grid = $VBoxContainer/HBoxContainer/TypeCountsHBox/FallenVBox/FallenScroll/FallenGrid
@onready var confirm_btn = $ButtonsHBox/ConfirmButton
@onready var cancel_btn = $ButtonsHBox/CancelButton
@onready var divine_soldier_count = $VBoxContainer/HBoxContainer/TypeCountsHBox/TypeCounterVbox/DivineSoldierCount
@onready var levy_count = $VBoxContainer/HBoxContainer/TypeCountsHBox/TypeCounterVbox/LevyCount
@onready var spell_count = $VBoxContainer/HBoxContainer/TypeCountsHBox/TypeCounterVbox/SpellCount

# Deck constraints (modular, easy to tweak)
const DECK_SIZE := 14
const TYPE_LIMITS := {
	"DivineSoldier": { "min": 3, "max": 5 },
	"Levy": { "min": 6, "max": 10 },
	"Spell": { "min": 1, "max": 3 }
}

var editing_deck: Array = [] # Array of card instance dictionaries (cloned for editing)
var initial_deck: Array = []
var collection: Array = [] # All available card instances (from PlayerCollectionManager)
var fallen_soldiers: Array = [] # Card instances of dead Divine Soldiers (from PantheonRunManager.dead_soldiers)

func _ready():
	confirm_btn.pressed.connect(_on_confirm_pressed)
	cancel_btn.pressed.connect(_on_cancel_pressed)
	error_label.visible = false

func open_deck_editor(current_deck: Array):
	initial_deck = current_deck.duplicate(true)
	editing_deck = current_deck.duplicate(true)
	collection = PlayerCollectionManager.owned_cards.duplicate(true)
	fallen_soldiers = PlayerCollectionManager.get_fallen_soldiers(PantheonRunManager.dead_soldiers)
	_refresh_ui()
	show()

func _refresh_ui():
	_update_deck_grid()
	_update_collection_grid()
	_update_fallen_grid()
	_update_type_counts()
	_validate_and_update_errors()

func _update_deck_grid():
	for child in deck_grid.get_children():
		child.queue_free()
	for idx in range(DECK_SIZE):
		var card_ui = null
		if idx < editing_deck.size():
			card_ui = card_ui_scene.instantiate()
			card_ui.set_card_data(editing_deck[idx]["card_data"])
			card_ui.connect("gui_input", Callable(self, "_on_deck_card_input").bind(idx))
		else:
			card_ui = Panel.new()
			card_ui.custom_minimum_size = Vector2(120, 150)
		deck_grid.add_child(card_ui)

func _update_collection_grid():
	for child in collection_grid.get_children():
		child.queue_free()
	var in_deck_ids = editing_deck.map(func(e): return e["instance_id"])
	for inst in collection:
		if in_deck_ids.has(inst["instance_id"]):
			continue # Already in deck
		# Skip fallen soldiers
		if inst["type"] == "DivineSoldier" and PantheonRunManager.dead_soldiers.has(inst["instance_id"]):
			continue
		var card_ui = card_ui_scene.instantiate()
		card_ui.set_card_data(inst["card_data"])
		card_ui.connect("gui_input", Callable(self, "_on_collection_card_input").bind(inst))
		collection_grid.add_child(card_ui)

func _update_fallen_grid():
	for child in fallen_grid.get_children():
		child.queue_free()
	for inst in fallen_soldiers:
		var card_ui = card_ui_scene.instantiate()
		card_ui.set_card_data(inst["card_data"])
		card_ui.modulate = Color(0.5, 0.5, 0.5, 0.7)
		fallen_grid.add_child(card_ui)

func _update_type_counts():
	var counts = { "DivineSoldier": 0, "Levy": 0, "Spell": 0 }
	for inst in editing_deck:
		if inst["type"] in counts:
			counts[inst["type"]] += 1
	divine_soldier_count.text = "Divine Soldiers: %d" % counts["DivineSoldier"]
	levy_count.text = "Levies: %d" % counts["Levy"]
	spell_count.text = "Spells: %d" % counts["Spell"]

func _validate_and_update_errors():
	var result = _validate_deck(editing_deck)
	error_label.visible = not result["valid"]
	error_label.text = result["error"]
	confirm_btn.disabled = not result["valid"]

func _validate_deck(deck: Array) -> Dictionary:
	var counts = { "DivineSoldier": 0, "Levy": 0, "Spell": 0 }
	var seen_soldiers := {}
	for inst in deck:
		var t = inst.get("type", "Levy")
		if t in counts:
			counts[t] += 1
		if t == "DivineSoldier":
			if seen_soldiers.has(inst["base_id"]):
				return { "valid": false, "error": "Divine Soldier %s is unique and already in deck." % inst.get("custom_name", ""), "type_counts": counts, "deck_size": deck.size() }
			seen_soldiers[inst["base_id"]] = true
	if deck.size() != DECK_SIZE:
		return { "valid": false, "error": "Deck must have exactly %d cards." % DECK_SIZE, "type_counts": counts, "deck_size": deck.size() }
	for k in counts:
		if counts[k] < TYPE_LIMITS[k]["min"]:
			return { "valid": false, "error": "Not enough %ss." % k, "type_counts": counts, "deck_size": deck.size() }
		if counts[k] > TYPE_LIMITS[k]["max"]:
			return { "valid": false, "error": "Too many %ss." % k, "type_counts": counts, "deck_size": deck.size() }
	return { "valid": true, "error": "", "type_counts": counts, "deck_size": deck.size() }

# --- Input Handlers ---

func _on_collection_card_input(event: InputEvent, inst: Dictionary):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_try_add_card_to_deck(inst)

func _on_deck_card_input(event: InputEvent, idx: int):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if idx < editing_deck.size():
			_try_remove_card_from_deck(idx)

func _try_add_card_to_deck(inst: Dictionary):
	# Check constraints
	if editing_deck.size() >= DECK_SIZE:
		_show_error("Deck is full!")
		return
	# Type limit
	var counts = { "DivineSoldier": 0, "Levy": 0, "Spell": 0 }
	for c in editing_deck:
		if c["type"] in counts:
			counts[c["type"]] += 1
	if counts[inst["type"]] >= TYPE_LIMITS[inst["type"]]["max"]:
		_show_error("Too many %ss in deck." % inst["type"])
		return
	# Unique Divine Soldier check
	if inst["type"] == "DivineSoldier":
		for c in editing_deck:
			if c["base_id"] == inst["base_id"]:
				_show_error("Each Divine Soldier is unique in the deck.")
				return
	editing_deck.append(inst)
	_refresh_ui()

func _try_remove_card_from_deck(idx: int):
	if idx >= editing_deck.size():
		return
	editing_deck.remove_at(idx)
	_refresh_ui()

func _show_error(msg: String):
	error_label.text = msg
	error_label.visible = true

# --- Button Handlers ---

func _on_confirm_pressed():
	PantheonRunManager.player_deck = editing_deck.duplicate(true)
	hide()

func _on_cancel_pressed():
	hide() # Discard changes
