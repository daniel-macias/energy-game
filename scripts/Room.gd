extends Control

# Parameters for the room instance
@export var notification_interval = 30.0  # Base time interval in seconds for the notification to show up
@export var notification_interval_randomness = 10.0  # Random factor to add variability
@export var notification_reward = 50  # Reward when clicking the notification
@export var clicker_reward = 10  # Reward when clicking the Clicker button
@export var energy_type = "Fossil Fuels"
@export var plant_amount = 0
@export var plant_cost = 500  # Initial cost to create a plant
@export var remove_plant_refund = 300  # Amount refunded when a plant is removed
@export var cost_increase_per_plant = 100  # How much the cost increases per plant
@export var id = -1
@export var unlocked = true
@export var unlock_price = 10000
@export var shorhand = "energ"

#these are the default indexes the plants provide without modifications
@export var contaminationIndex = 1.0;
@export var happinessIndex = 1.0;
@export var wattageIndex = 1.0;
@export var contaminationCapacity = 1000;


@export var costIndex = 1.0; #maybe

#animal info
@export var animal_name = "A"
@export var animal_species = "B"
@export var animal_scientific = "C"
@export var animal_info = "D"

# Node references
@onready var notification_button = $Notification
@onready var clicker_button = $Clicker
@onready var room_button = $Computer
@onready var background = $TextureRect
@onready var dark_panel = $DarkPanel

@onready var animation_player = $AnimationPlayer
@onready var animation_player_animal = $AnimationPlayerAnimal
@onready var animation_player_bag = $AnimationPlayerBag

@onready var lock_panel = $LockPanel
@onready var shorthand_label = $LockPanel/Shorthand
@onready var unlock_btn = $LockPanel/UnlockBtn

# To track the time for notifications
var notification_timer = 0.0
var notification_time_target = 0.0

@export var background_0: Texture2D
@export var background_1: Texture2D
@export var background_2: Texture2D
@export var background_3: Texture2D
@export var background_4: Texture2D
@export var background_5: Texture2D

@export var animal_portraits : Array[Texture2D]
@export var animal_bodies : Array[Texture2D]
@export var computer_on : Texture2D
@export var computer_off : Texture2D

func _ready():
	# Hide the notification button at the start
	notification_button.visible = false
	# Randomize the initial notification timer
	notification_time_target = notification_interval + randf() * notification_interval_randomness
	# Connect signals using the updated Godot 4 syntax
	notification_button.pressed.connect(_on_Notification_pressed)
	clicker_button.pressed.connect(_on_Clicker_pressed)
	set_process(true)
	
	room_button.pressed.connect(_on_RoomButton_pressed)
	change_background()
	clicker_button.texture_normal = animal_bodies[id]
	
	unlock_btn.pressed.connect(on_unlock_btn)
	
	update_room_state()
	
func on_unlock_btn():
	if GameManager.money >= unlock_price:
		unlocked = true
		GameManager.update_money(-unlock_price)
		lock_panel.visible = false
	else:
		print("Not enough money to unlock")

func change_background():
	match id:
		0:
			background.texture = background_0
		1:
			background.texture = background_1
		2:
			background.texture = background_2
		3:
			background.texture = background_3
		4:
			background.texture = background_4
		5:
			background.texture = background_5

func update_room_state():
	if unlocked:
		lock_panel.visible = false
	else:
		lock_panel.visible = true
		shorthand_label.text = shorhand
		unlock_btn.text = "$ " + str(unlock_price)
		
	
	if plant_amount > 0:
		dark_panel.visible = false  # Hide the dark panel
		clicker_button.visible = true
		room_button.texture_normal = computer_on
		animation_player.play("ComputerOn")
		animation_player_animal.play("animal_scale")
		#animation_player.play("room_active")  # Play an animation to show room is active
	else:
		dark_panel.visible = true  # Show the dark panel
		clicker_button.visible = false
		room_button.texture_normal = computer_off
		animation_player.stop()
		animation_player_animal.stop()
		#animation_player.stop()  # Stop any running animations

# Function to handle the Clicker button press
func _on_Clicker_pressed():
	GameManager.update_money(clicker_reward)


func _on_RoomButton_pressed():
	 # Call the main scene's function to show the energy panel with this room's energy type
	print("Plant amount: ", plant_amount)
	GameManager.show_energy_panel(energy_type)
	GameManager.update_panel(plant_amount, plant_cost, remove_plant_refund, id, contaminationCapacity, contaminationIndex, wattageIndex)
	GameManager.update_animal_info(animal_name,animal_species,animal_scientific,animal_info,animal_portraits[id])

# Function to handle the Notification button press
func _on_Notification_pressed():
	GameManager.update_money(notification_reward)
	notification_button.visible = false  # Hide the notification again
	notification_time_target = notification_interval + randf() * notification_interval_randomness

func reset_notification_timer():
	notification_timer = 0.0
	notification_time_target = notification_interval + randf() * notification_interval_randomness


func create_plant():
	print("Creating plant, current before ", plant_amount)
	if GameManager.money >= plant_cost:
		plant_amount += 1
		update_room_state()
		GameManager.update_money(-plant_cost)
		plant_cost += cost_increase_per_plant  # Increase the cost after purchasing
		GameManager.update_panel(plant_amount, plant_cost, remove_plant_refund, id, contaminationCapacity, contaminationIndex, wattageIndex)
	print("Creating plant, current after ", plant_amount)
	
func remove_plant():
	var total_plants = 0
	
	# Count the total number of plants across all rooms
	for room in GameManager.rooms:
		total_plants += room.plant_amount
	
	if total_plants <= 1:
		print("Cannot remove the last plant.")
		GameManager.open_custom_dialog("¡No dejes al pueblo sin energía!","No puedes quitar la última planta")
		return  # Prevent removal of the last plant
	
	if plant_amount > 0:
		plant_amount -= 1
		update_room_state()
		GameManager.update_money(remove_plant_refund)
		plant_cost -= cost_increase_per_plant 
		GameManager.update_panel(plant_amount, plant_cost, remove_plant_refund, id, contaminationCapacity, contaminationIndex, wattageIndex)

