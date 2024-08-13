extends Control

# Parameters for the room instance
@export var notification_interval = 5.0  # Base time interval in seconds for the notification to show up
@export var notification_interval_randomness = 2.0  # Random factor to add variability
@export var notification_reward = 50  # Reward when clicking the notification
@export var clicker_reward = 10  # Reward when clicking the Clicker button
@export var energy_type = "Fossil Fuels"


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

# Function to handle the Notification button press
func _on_Notification_pressed():
	get_parent().get_parent().get_parent().update_money(notification_reward)
	notification_button.visible = false  # Hide the notification again
	notification_time_target = notification_interval + randf() * notification_interval_randomness

# Update the room every frame
func _process(delta):
	notification_timer += delta
	if notification_timer >= notification_interval:
		notification_button.visible = true
		notification_timer = 0.0  # Reset the timer

