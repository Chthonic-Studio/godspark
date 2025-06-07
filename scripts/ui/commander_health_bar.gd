extends TextureProgressBar

@export var is_player: bool = true
@export var health_label_path: NodePath
@export var fade_duration: float = 0.5

var prev_health: int = 100
var target_health: int = 100
var shake_tween: Tween = null
var flash_tween: Tween = null

# Call this at scene ready
func _ready():
	print("Commander health bar _ready: ", self.name)
	self.visible = false
	modulate.a = 0.0
	if not health_label_path.is_empty():
		print("Health label:", get_node_or_null(health_label_path))
		get_node(health_label_path).text = str(value)
	prev_health = value
	target_health = value

# Animate fade-in
func fade_in():
	print("Commander health bar fade_in: ", self.name)
	self.visible = true
	self.show()
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, fade_duration)

# Animate fade-out (used when dying)
func fade_out():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_duration)
	await tween.finished
	self.visible = false

# Call to update the value (from CombatManager)
func set_health(new_health: int):
	target_health = max(new_health, 0)
	if target_health < prev_health:
		shake()
	# Animate bar
	var tween = create_tween()
	tween.tween_property(self, "value", target_health, 0.4)
	# Update label as the bar animates
	tween.tween_callback(Callable(self, "_update_health_label"))
	prev_health = target_health
	if not health_label_path.is_empty():
		get_node(health_label_path).text = str(target_health)
	if target_health == 0:
		await shake()
		await flash_and_disappear()

# Shake/vibrate the bar for 1 second
func shake():
	if shake_tween:
		shake_tween.kill()
	var shake_amount = 10
	var shake_time = 1.0
	var orig_pos = position
	shake_tween = create_tween()
	for i in range(10):
		shake_tween.tween_property(self, "position", orig_pos + Vector2(randi()%shake_amount - shake_amount/2, 0), shake_time/20)
		shake_tween.tween_property(self, "position", orig_pos, shake_time/20)
	await get_tree().create_timer(shake_time).timeout
	position = orig_pos

# Flash red 3 times, then fade out
func flash_and_disappear():
	if flash_tween:
		flash_tween.kill()
	var flash_color = Color(1,0.2,0.2,1)
	var orig_mod = modulate
	flash_tween = create_tween()
	for i in range(3):
		flash_tween.tween_property(self, "modulate", flash_color, 0.1)
		flash_tween.tween_property(self, "modulate", orig_mod, 0.1)
	await flash_tween.finished
	await fade_out()

func _update_health_label():
	if not health_label_path.is_empty():
		get_node(health_label_path).text = str(int(value))

# Utility: Show/hide instantly
func show_bar():
	self.visible = true
func hide_bar():
	self.visible = false
