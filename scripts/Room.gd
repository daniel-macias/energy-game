extends Control

# Parameters for the room instance
@export var notification_interval = 5.0  # Base time interval in seconds for the notification to show up
@export var notification_interval_randomness = 2.0  # Random factor to add variability
@export var notification_reward = 50  # Reward when clicking the notification
@export var clicker_reward = 10  # Reward when clicking the Clicker button
@export var energy_type = "Fossil Fuels"
@export var plant_amount = 0
@export var plant_cost = 500  # Initial cost to create a plant
@export var remove_plant_refund = 300  # Amount refunded when a plant is removed
@export var cost_increase_per_plant = 100  # How much the cost increases per plant
@export var id = -1


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
	get_parent().get_parent().get_parent().update_money(clicker_reward)

func _on_RoomButton_pressed():
	 # Call the main scene's function to show the energy panel with this room's energy type
	
	get_parent().get_parent().get_parent().show_energy_panel(energy_type)
	get_parent().get_parent().get_parent().update_panel(plant_amount, plant_cost, remove_plant_refund, id)

# Function to handle the Notification button press
func _on_Notification_pressed():
	get_parent().get_parent().get_parent().update_money(notification_reward)
	notification_button.visible = false  # Hide the notification again
	notification_time_target = notification_interval + randf() * notification_interval_randomness
	
func create_plant():
	if get_parent().get_parent().get_parent().money >= plant_cost:
		plant_amount += 1
		get_parent().get_parent().get_parent().update_money(-plant_cost)
		plant_cost += cost_increase_per_plant  # Increase the cost after purchasing
		get_parent().get_parent().get_parent().update_panel(plant_amount, plant_cost, remove_plant_refund, id)

func remove_plant():
	if plant_amount > 0:
		plant_amount -= 1
		get_parent().get_parent().get_parent().update_money(remove_plant_refund)
		plant_cost -= cost_increase_per_plant  # Optional: Decrease the cost after selling
		get_parent().get_parent().get_parent().update_panel(plant_amount, plant_cost, remove_plant_refund, id)

# Update the room every frame
func _process(delta):
	notification_timer += delta
	if notification_timer >= notification_interval:
		notification_button.visible = true
		notification_timer = 0.0  # Reset the timer

