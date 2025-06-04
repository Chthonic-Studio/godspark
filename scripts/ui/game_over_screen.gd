extends Control

signal confirmed

@onready var title_label = $Panel/TitleLabel
@onready var turns_label = $Panel/TurnsLabel
@onready var pantheon_label = $Panel/PantheonLabel
@onready var fallen_label = $Panel/FallenLabel
@onready var fallen_list_vbox = $Panel/FallenListVBox
@onready var confirm_button = $Panel/ConfirmButton

# Call this to set up the screen before showing
func setup(result: String, turns: int, void_pantheon: String, fallen_soldiers: Array[String]):
	# Set text values
	title_label.text = result.capitalize() + "!"
	turns_label.text = "Turns: %d" % turns
	pantheon_label.text = "VS %s" % void_pantheon
	fallen_label.text = "Fallen Units"
	
	for child in fallen_list_vbox.get_children():
		child.queue_free()
	
	if fallen_soldiers.is_empty():
		var no_fallen = Label.new()
		no_fallen.text = "None!"
		fallen_list_vbox.add_child(no_fallen)
	else:
		for name in fallen_soldiers:
			var l = Label.new()
			l.text = name
			fallen_list_vbox.add_child(l)
	
	# Hide all at start
	title_label.visible = false
	turns_label.visible = false
	pantheon_label.visible = false
	fallen_label.visible = false
	for node in fallen_list_vbox.get_children():
		node.visible = false
	confirm_button.visible = false

	# Center this popup
	anchor_left = 0.5
	anchor_top = 0.5
	anchor_right = 0.5
	anchor_bottom = 0.5
	offset_left = -350
	offset_top = -250
	offset_right = 350
	offset_bottom = 250

	# Set scale and transparency for pop-in
	scale = Vector2(0.7, 0.7)
	modulate.a = 0

func play_reveal_animation():
	# Tween scale and alpha in
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1, 1), 1.5)
	tween.parallel().tween_property(self, "modulate:a", 1.0, 1.5)
	await tween.finished

	# Progressive label reveal (as before)
	await get_tree().create_timer(0.1).timeout
	title_label.visible = true
	await get_tree().create_timer(0.1).timeout
	pantheon_label.visible = true
	await get_tree().create_timer(0.1).timeout
	turns_label.visible = true
	await get_tree().create_timer(0.1).timeout
	fallen_label.visible = true
	for node in fallen_list_vbox.get_children():
		await get_tree().create_timer(0.1).timeout
		node.visible = true
	await get_tree().create_timer(0.2).timeout
	confirm_button.visible = true

func _ready():
	confirm_button.pressed.connect(_on_confirm_pressed)

func _on_confirm_pressed():
	# Parallel fade: self -> transparent, CombatScene/FadeOverlay -> black
	var fade_overlay = get_parent().get_node("FadeOverlay")
	if fade_overlay:
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.0, 2.0)
		tween.parallel().tween_property(fade_overlay, "modulate:a", 1.0, 2.0)
		await tween.finished
	emit_signal("confirmed")

# Utility: call before showing a new screen to reset alpha values
static func reset_fade_state(combat_scene: Node):
	var fade_overlay = combat_scene.get_node("FadeOverlay")
	if fade_overlay:
		fade_overlay.modulate.a = 0.0
	var gos = combat_scene.get_node_or_null("GameOverScreen") # or pass the instance
	if gos:
		gos.modulate.a = 1.0
