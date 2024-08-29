extends Node

@onready var start_menu = $StartMenu
@onready var game = $Game
@onready var results_menu = $Results
@onready var canvas_layer = $Game/CanvasLayer

@onready var startsInLabel = $Game/CanvasLayer/StartsIn
@onready var gameTimeLabel = $Game/CanvasLayer/GameTimer

@onready var trashEliminatedLabel = $Results/Panel/trashEliminated
@onready var friendsHurtLabel = $Results/Panel/friendsHurt
@onready var finalScoreLabel = $Results/Panel/finalScore

@onready var player = $Game/Player

@onready var game_timer = Timer.new()
@onready var start_timer = Timer.new()
@onready var transition_timer = Timer.new()

@export var trash_scene = preload("res://scenes/trash.tscn")
@export var friend_scene = preload("res://scenes/friend.tscn")
@export var bullet_scene = preload("res://scenes/bullet.tscn")

var score = 0
var countdown_time := 3
var game_time := 20
var game_active := false
var total_trash := 0

@onready var start_nodes = [$Game/StartNode0, $Game/StartNode1, $Game/StartNode2, $Game/StartNode3]
@onready var end_nodes = [$Game/EndNode0, $Game/EndNode1, $Game/EndNode2, $Game/EndNode3]

# Called when the node enters the scene tree for the first time.
func _ready():
	var return_button = $Results/Panel/ReturnToEnergyManager
	return_button.pressed.connect(_on_return_button_pressed)
	
	var return_button_main_menu = $StartMenu/Panel/ReturnToEnergyManager
	return_button_main_menu.pressed.connect(_on_return_button_pressed)
	
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
	canvas_layer.visible = true
	startsInLabel.text = "Inicia en " + str(countdown_time) + "..."
	start_timer.start()

func on_countdown_tick():
	countdown_time -= 1
	print(countdown_time)
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
	total_trash = 0
	GameManager.trash_shot = 0
	GameManager.friend_shot = 0
	game_active = true 
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
	print(game_time)


func on_start_countdown_finished():
	# Start the actual game
	game.visible = true
	#spawn_trash()  # Function to start spawning trash
	game_timer.start()  # Start the 15-second game timer

func on_game_finished():
	game_active = false
	game_timer.stop()
	game.visible = false
	startsInLabel.text = "Terminado!"
	startsInLabel.visible = true
	transition_timer.start()  # Start transition to results after a brief pause

func show_results():
	startsInLabel.visible = false
	results_menu.visible = true
	canvas_layer.visible = false
	trashEliminatedLabel.text = str(GameManager.trash_shot)
	friendsHurtLabel.text = str(GameManager.friend_shot)
	
	var totalShot = GameManager.trash_shot + GameManager.friend_shot
	var awarded = 0

	if totalShot != 0:
		var currentCleanliness = GameManager.cleanliness
		awarded = (100 - currentCleanliness) * (float(GameManager.trash_shot) / float(totalShot))
		GameManager.set_cleanliness(currentCleanliness + awarded)
	
	#display_results()


func spawn_trash():
	if not game_active:  # Stop spawning if the game is not active
		return
	# Spawns trash at random start nodes
	total_trash += 1
	var random_start_index = randi() % start_nodes.size()
	var random_end_index = randi() % end_nodes.size()
	var start_node = start_nodes[random_start_index]
	var end_node = end_nodes[random_end_index]
	
	var instance = null

	# Randomly choose between spawning trash or friend
	if randf() < 0.7:  # 70% chance to spawn trash, adjust this probability as needed
		instance = trash_scene.instantiate()
	else:
		instance = friend_scene.instantiate()
	add_child(instance)
	
	# Set the position to the start node's position
	instance.global_position = start_node.global_position
	
	# Set the target position for the trash to the end node
	instance.target_position = end_node.global_position

	# Continue spawning trash after a short delay
	await get_tree().create_timer(randf_range(0.5, 1.5)).timeout
	spawn_trash()

func shoot_bullet(target_position: Vector2):
	var bullet_instance = bullet_scene.instantiate()  # No need to cast
	
	if bullet_instance != null:
		print("Bullet instance created successfully")
		add_child(bullet_instance)

		# Ensure player exists before using its global position
		if player != null:
			bullet_instance.global_position = player.global_position
		else:
			print("Player is not initialized!")

		# Set bullet's direction towards the target position
		if bullet_instance.has_method("set_direction"):
			var direction = (target_position - bullet_instance.global_position).normalized()
			bullet_instance.call("set_direction", direction)  # Safely set direction using method
		else:
			print("Bullet instance does not have set_direction method!")
		# Rotate the player to face the direction of the target
		player.look_at(target_position)
	else:
		print("Failed to create bullet instance")

# Detect input to shoot a bullet
func _input(event):
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if game_active:
			# Get the global position where the player tapped/clicked
			var target_position = event.position
			shoot_bullet(target_position)
