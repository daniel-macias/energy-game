extends Control

@onready var play_button = $VBoxContainer/Play
@onready var tutorial_button = $VBoxContainer/Tutorial
@onready var options_button = $VBoxContainer/Options
@onready var debug_label = $VBoxContainer/Debug

func _ready():
	# Check if a save file exists
	if FileAccess.file_exists("user://save_game.dat"):
		play_button.text = "Continue Game"
		
		# Load the save file and display some of its contents in the debug label
		var file = FileAccess.open("user://save_game.dat", FileAccess.READ)
		var json = JSON.new()
		var result = json.parse(file.get_as_text())
		file.close()

		if result.error == OK:
			var save_data = result.result
			# Display relevant information from the save file
			var happiness = save_data.get("happiness", 100)
			var money = save_data.get("money", 1000)
			var tourists = save_data.get("tourists", 0)

			# Update the debug label with the save data
			debug_label.text = "Save Found!\nHappiness: %s\nMoney: %s\nTourists: %s".format([happiness, money, tourists])
		else:
			debug_label.text = "Save file is corrupted."
		
	else:
		play_button.text = "Start Game"
		debug_label.text = "No save found"

	# Connect button signals
	play_button.pressed.connect(_on_play_button_pressed)
	tutorial_button.pressed.connect(_on_tutorial_button_pressed)
	options_button.pressed.connect(_on_options_button_pressed)

func _on_play_button_pressed():
	if play_button.text == "Continue Game":
		GameManager.load_game()
	else:
		GameManager.initialize_game_logic()  # Start a fresh game
	# Transition to the game scene
	get_tree().change_scene("res://scenes/game.tscn")

func _on_tutorial_button_pressed():
	get_tree().change_scene("res://scenes/tutorial.tscn")

func _on_options_button_pressed():
	get_tree().change_scene("res://scenes/options.tscn")
