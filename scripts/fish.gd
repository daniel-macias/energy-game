extends Node

@onready var start_menu = $StartMenu
@onready var game = $Game
@onready var results_menu = $Results

@onready var game_timer = Timer.new()
@onready var start_timer = Timer.new()
@onready var transition_timer = Timer.new()

var score = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	var return_button = $Results/Panel/ReturnToEnergyManager
	return_button.pressed.connect(_on_return_button_pressed)
	
	start_timer.one_shot = true
	start_timer.wait_time = 3.0  # Countdown
	start_timer.timeout.connect(on_start_countdown_finished)
	add_child(start_timer)

	game_timer.one_shot = true
	game_timer.wait_time = 15.0  # Game duration
	game_timer.timeout.connect(on_game_finished)
	add_child(game_timer)

	transition_timer.one_shot = true
	transition_timer.wait_time = 3.0  # Transition to results
	transition_timer.timeout.connect(show_results)
	add_child(transition_timer)

	# Initially hide the game and results
	game.visible = false
	results_menu.visible = false

func _on_return_button_pressed():
	GameManager.unpauseMainGame()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_StartGame_pressed():
	start_menu.visible = false
	start_timer.start()  # Start the countdown timer

func on_start_countdown_finished():
	# Start the actual game
	game.visible = true
	spawn_trash()  # Function to start spawning trash
	game_timer.start()  # Start the 15-second game timer

func on_game_finished():
	# Stop the game, then transition to the results screen
	game.visible = false
	transition_timer.start()

func show_results():
	results_menu.visible = true
	#display_results()  # Show the player’s score, etc.
	
func spawn_trash():
	# Function to spawn trash continuously
	# Use Random intervals and speeds to spawn trash objects
	pass
