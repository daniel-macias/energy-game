extends Control

signal game_scene_loaded

func _ready():
	# Notify GameManager that the game scene has fully loaded
	emit_signal("game_scene_loaded")
