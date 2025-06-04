extends Control

func _ready():
	var fade_overlay = $FadeOverlay
	if fade_overlay:
		fade_overlay.modulate.a = 0.0
	var gos = $GameOverScreen if has_node("GameOverScreen") else null
	if gos:
		gos.modulate.a = 1.0
