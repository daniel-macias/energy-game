extends Control

@onready var play_button = $Play
@onready var tutorial_button = $VBoxContainer/Tutorial
@onready var options_button = $Options
@onready var debug_label = $VBoxContainer/Debug
@onready var animated_sprite = $AnimatedSprite2D
@onready var hasSaveFile = false

@export var newGameTexture: Texture2D
@export var continueGameTexture: Texture2D

@export var tutorialPics: Array[Texture2D]
@onready var tutorialPanel = $TutorialScreen
@onready var currentTutorialPic = $TutorialScreen/CurrentPic
@onready var tutorialNext = $TutorialScreen/Next
@onready var tutorialBack = $TutorialScreen/Back
@onready var tutorialStartGame = $TutorialScreen/IniciarJuegoTut

@onready var splash_container = $Splash
@onready var splash_0 = $Splash/Gob
@onready var splash_1 = $Splash/Pobe

var tutorial_index = 0

func _ready():
	# Hide both images initial
	splash_container.visible = true
	splash_0.modulate.a = 0
	splash_1.modulate.a = 0
	
	tutorialNext.pressed.connect(handle_next_slide)
	tutorialBack.pressed.connect(handle_back_slide)
	
	# Start the splash screen sequence
	show_splash_sequence()
	
	# Check if a save file exists
	if FileAccess.file_exists("user://save_game.dat"):
		hasSaveFile = true
		play_button.texture_normal = continueGameTexture
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
		hasSaveFile = false
		play_button.texture_normal = newGameTexture
		debug_label.text = "No save found"

	# Connect button signals
	if hasSaveFile:
		play_button.pressed.connect(_on_play_button_pressed)
	else:
		play_button.pressed.connect(display_tutorial)
	#play_button.pressed.connect(_on_play_button_pressed)
	tutorialStartGame.pressed.connect(_on_play_button_pressed)

	
	# Center and scale the animated sprite
	center_and_scale_sprite()
	animated_sprite.play("default")
	
	# Create a new Environment

	#get_viewport().world_2d = world_env


	
	

func show_splash_sequence():
	# Create a tween programmatically
	var tween = get_tree().create_tween()
	
	# Fade in Gob
	tween.tween_property(splash_0, "modulate:a", 1.0, 1.0)
	
	# Wait 3 seconds, then fade out
	tween.tween_property(splash_0, "modulate:a", 0.0, 1.0).set_delay(3.0)
	
	# After Gob fades out, fade in Pobe
	tween.tween_callback(Callable(self, "_show_pobe"))
	
func _show_pobe():
	var tween = get_tree().create_tween()
	
	# Fade in Pobe
	tween.tween_property(splash_1, "modulate:a", 1.0, 1.0)
	
	# Wait 3 seconds, then fade out
	tween.tween_property(splash_1, "modulate:a", 0.0, 1.0).set_delay(3.0)
	
	# After Pobe fades out, hide the splash container
	tween.tween_callback(Callable(self, "_hide_splash"))

func _hide_splash():
	splash_container.visible = false


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


func display_tutorial():
	tutorialPanel.visible = true
	

func handle_next_slide():
	if tutorial_index < 15:
		tutorial_index += 1
		currentTutorialPic.texture = tutorialPics[tutorial_index]
		tutorialNext.text = "Siguiente"
		tutorialNext.disabled = false
		tutorialBack.disabled = false
		tutorialStartGame.visible = false
		if tutorial_index == 15:
			tutorialStartGame.visible = true
			tutorialNext.disabled = true
		
	

func handle_back_slide():
	if tutorial_index > 0:
		tutorial_index -= 1
		currentTutorialPic.texture = tutorialPics[tutorial_index]
		tutorialBack.text = "Anterior"
		tutorialBack.disabled = false
		tutorialNext.disabled = false
		tutorialStartGame.visible = false
		if tutorial_index == 0:
			tutorialBack.disabled = true

func center_and_scale_sprite():
	# Get the viewport size (screen size)
	var viewport_size = get_viewport_rect().size
	
	# Center the sprite
	animated_sprite.position = viewport_size / 2
	
