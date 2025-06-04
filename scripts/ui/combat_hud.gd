extends Control

@export var combat_manager: NodePath
@onready var divinity_label = $DivinityLabel
@onready var end_turn_btn = $EndTurnButton
@onready var turn_info_label: Label = $TurnInfoLabel

func _ready():
	update_divinity()
	var cm = get_node(combat_manager)
	end_turn_btn.pressed.connect(_on_end_turn_pressed)
	cm.divinity_changed.connect(update_divinity)
	cm.phase_changed.connect(update_turn_info)
	cm.turn_changed.connect(update_turn_info)
	update_turn_info()

func update_divinity():
	var cm = get_node(combat_manager)
	divinity_label.text = "Divinity: %d" % cm.divinity

func _on_end_turn_pressed():
	get_node(combat_manager).end_player_turn()
	update_turn_info()

func update_turn_info():
	var cm = get_node(combat_manager)
	turn_info_label.text = "Turn %d - %s" % [cm.turn, cm.phase]
	end_turn_btn.disabled = cm.phase != "PlayerTurn"

func set_enabled(enabled: bool):
	end_turn_btn.disabled = not enabled
