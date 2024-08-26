extends Node

@onready var start_menu = $StartMenu
@onready var game = $Game
@onready var results_menu = $Results
@onready var canvas_layer = $Game/CanvasLayer

@onready var startsInLabel = $Game/CanvasLayer/StartsIn
@onready var gameTimeLabel = $Game/CanvasLayer/GameTimer

@onready var game_timer = Timer.new()
@onready var start_timer = Timer.new()
@onready var transition_timer = Timer.new()

var score = 0
var countdown_time := 3
var game_time := 15

# Called when the node enters the scene tree for the first time.
func _ready():
	var return_button = $Results/Panel/ReturnToEnergyManager
	return_button.pressed.connect(_on_return_button_pressed)
	
	var start_button = $StartMenu/Panel/StartGame
	start_button.pressed.connect(_on_StartGame_pressed)
	
	start_timer.one_shot = true
	start_timer.wait_time = 1.0  # Countdown
	start_timer.timeout.connect(on_countdown_tick)
	add_child(start_timer)

	game_timer.one_shot = true
	game_timer.wait_time = 1.0
	game_timer.timeout.connect(on_game_tick)
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
	start_countdown()  # Start the countdown timer

func start_countdown():
	startsInLabel.visible = true
	startsInLabel.text = "Inicia en " + str(countdown_time) + "..."
	start_timer.start()

func on_countdown_tick():
	countdown_time -= 1
	if countdown_time > 0:
		startsInLabel.text = "Inicia en " + str(countdown_time) + "..."
		start_timer.start()  # Continue countdown
	else:
		startsInLabel.text = "Go!"
		start_timer.stop()
		# Wait for 1 second before starting the game
		await get_tree().create_timer(1).timeout
		startsInLabel.visible = false
		start_game()

func start_game():
	game.visible = true
	game_time = 15  # Reset game time
	score = 0  # Reset score
	update_game_timer()  # Update timer label for display
	spawn_trash()  # Start spawning trash
	game_timer.start()  # Start game ticking every second

func on_game_tick():
	game_time -= 1
	update_game_timer()  # Update the timer label
	if game_time > 0:
		game_timer.start()  # Continue game ticking
	else:
		on_game_finished()

func update_game_timer():
	gameTimeLabel.text = str(game_time)


func on_start_countdown_finished():
	# Start the actual game
	game.visible = true
	spawn_trash()  # Function to start spawning trash
	game_timer.start()  # Start the 15-second game timer

func on_game_finished():
	game_timer.stop()
	game.visible = false
	startsInLabel.text = "Terminado!"
	startsInLabel.visible = true
	transition_timer.start()  # Start transition to results after a brief pause

func show_results():
	startsInLabel.visible = false
	results_menu.visible = true
	#display_results()


func spawn_trash():
	# Function to spawn trash continuously
	# Use Random intervals and speeds to spawn trash objects
	pass
