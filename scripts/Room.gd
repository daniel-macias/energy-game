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

#these are the default indexes the plants provide without modifications
@export var contaminationIndex = 1.0;
@export var happinessIndex = 1.0;
@export var wattageIndex = 1.0;

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

# To track the time for notifications
var notification_timer = 0.0
var notification_time_target = 0.0


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

# Function to handle the Clicker button press
func _on_Clicker_pressed():
	GameManager.update_money(clicker_reward)


func _on_RoomButton_pressed():
	 # Call the main scene's function to show the energy panel with this room's energy type
	print("Plant amount: ", plant_amount)
	GameManager.show_energy_panel(energy_type)
	GameManager.update_panel(plant_amount, plant_cost, remove_plant_refund, id)
	GameManager.update_animal_info(animal_name,animal_species,animal_scientific,animal_info)

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
		GameManager.update_money(-plant_cost)
		plant_cost += cost_increase_per_plant  # Increase the cost after purchasing
		GameManager.update_panel(plant_amount, plant_cost, remove_plant_refund, id)
	print("Creating plant, current after ", plant_amount)
	
func remove_plant():
	if plant_amount > 0:
		plant_amount -= 1
		GameManager.update_money(remove_plant_refund)
		plant_cost -= cost_increase_per_plant  # Optional: Decrease the cost after selling
		GameManager.update_panel(plant_amount, plant_cost, remove_plant_refund, id)

