extends Control

@onready var play_button = $Play
@onready var tutorial_button = $VBoxContainer/Tutorial
@onready var options_button = $Options
@onready var debug_label = $VBoxContainer/Debug
@onready var animated_sprite = $AnimatedSprite2D
@onready var hasSaveFile = false



func _ready():
	# Check if a save file exists
	if FileAccess.file_exists("user://save_game.dat"):
		#play_button.text = "Continue Game"
		#TODO: CHANGE ICON
		hasSaveFile = true
		# Load the save file and display some of its contents in the debug label
		var file = FileAccess.open("user://save_game.dat", FileAccess.READ)
		var result = JSON.parse_string(file.get_as_text())
		file.close()

		if result:
			var save_data = result
			# Display relevant information from the save file
			var happiness = save_data.get("happiness", 100)
			var money = save_data.get("money", 1000)
			var tourists = save_data.get("tourists", 0)

			# Update the debug label with the save data
			debug_label.text = "Save Found!\nHappiness: %s\nMoney: %s\nTourists: %s".format([happiness, money, tourists])
		else:
			debug_label.text = "Save file is corrupted."
		
	else:
		#play_button.text = "Start Game"
		hasSaveFile = false
		debug_label.text = "No save found"

	# Connect button signals
	play_button.pressed.connect(_on_play_button_pressed)
	tutorial_button.pressed.connect(_on_tutorial_button_pressed)
	options_button.pressed.connect(_on_options_button_pressed)
	
	# Center and scale the animated sprite
	center_and_scale_sprite()
	animated_sprite.play("default")
	
	# Create a new Environment

	#get_viewport().world_2d = world_env


	

func _on_play_button_pressed():
	# Load the game scene
	var game_scene = load("res://scenes/game.tscn").instantiate()
	
	# Connect to the `game_scene_loaded` signal regardless of whether it's a new game or a continued game
	game_scene.connect("game_scene_loaded", _on_game_scene_loaded)
	
	# Add the scene to the tree and switch to it
	get_tree().root.add_child(game_scene)
	get_tree().set_current_scene(game_scene)
	self.visible = false

func _on_game_scene_loaded():
	if hasSaveFile:
		GameManager.initialize_game_logic()
		GameManager.load_game()
	else:
		GameManager.initialize_game_logic()  # Start a fresh game

func _on_tutorial_button_pressed():
	get_tree().change_scene("res://scenes/tutorial.tscn")

func _on_options_button_pressed():
	get_tree().change_scene("res://scenes/options.tscn")

func center_and_scale_sprite():
	# Get the viewport size (screen size)
	var viewport_size = get_viewport_rect().size
	
	# Center the sprite
	animated_sprite.position = viewport_size / 2
	
	# Optionally scale the sprite
	#animated_sprite.scale = Vector2(2, 2)  # Example: double the size of the sprite
