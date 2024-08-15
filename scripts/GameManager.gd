extends Control

# Game variables
var happiness = 100  # 0 to 100
var tourists = 0  # 0 to infinity
var wattage = 100  # 0 to 100 (current wattage usage as a percentage of capacity)
var wattage_capacity = 1000  # Max wattage capacity (can be increased with upgrades)
var cleanliness = 100  # 0 to 100
var money = 10000
var cost = 0
var rooms = []
var currently_selected_room = -1  # -1 means no room is currently selected

# Image paths
var happiness_images = [
	"res://sprites/happy0.png",
	"res://sprites/happy1.png",
	"res://sprites/happy2.png",
	"res://sprites/happy3.png",
	"res://sprites/happy4.png"
]

# Multipliers for balancing
@export var cleanliness_to_happiness_multiplier = 1.0
@export var happiness_to_tourists_multiplier = 1.0
@export var tourists_to_wattage_multiplier = 1.0

# Node references
@onready var happiness_rect = $VBoxContainer/HBoxContainer/Happiness
@onready var tourists_label = $VBoxContainer/HBoxContainer/Tourists
@onready var wattage_bar = $VBoxContainer/HBoxContainer/Wattage
@onready var cleanliness_bar = $VBoxContainer/HBoxContainer/Cleanliness
@onready var money_label = $VBoxContainer/HBoxContainer/Money
@onready var cost_label = $VBoxContainer/HBoxContainer/Cost

#Panel Node References
@onready var energy_panel = $PanelContainer
@onready var energy_title = $PanelContainer/VBoxContainer/TopBar/EnergyType
@onready var exit_button = $PanelContainer/VBoxContainer/TopBar/ExitButton
@onready var plant_amount_label = $PanelContainer/VBoxContainer/Menu/VBoxContainer/PlantAmount
@onready var create_plant_button = $PanelContainer/VBoxContainer/Menu/VBoxContainer/CreatePlant
@onready var remove_plant_button = $PanelContainer/VBoxContainer/Menu/VBoxContainer/DeletePlant

func _ready():
	load_game()
	set_process(true)  # Enable _process() to make updates over time
	
	 # Initially hide the energy panel
	energy_panel.visible = false
	
	# Connect the exit button to close the panel
	exit_button.pressed.connect(hide_energy_panel)
	
	create_plant_button.pressed.connect(_on_CreatePlantButton_pressed)
	remove_plant_button.pressed.connect(_on_RemovePlantButton_pressed)
	
	rooms = [
		$VBoxContainer/GridContainer/Control,
		$VBoxContainer/GridContainer/Control2,
		$VBoxContainer/GridContainer/Control3,
		$VBoxContainer/GridContainer/Control4,
		$VBoxContainer/GridContainer/Control5,
		$VBoxContainer/GridContainer/Control6
	]

func _on_CreatePlantButton_pressed():
	var room = get_selected_room()
	if room:
		room.create_plant()

func _on_RemovePlantButton_pressed():
	var room = get_selected_room()
	if room:
		room.remove_plant()

func update_panel(plant_amount, plant_cost, remove_plant_refund, id):
	currently_selected_room = id
	plant_amount_label.text = str(plant_amount)
	create_plant_button.text = str(plant_cost) + " Gold"
	remove_plant_button.text = str(remove_plant_refund) + " Gold"

func get_selected_room():
	# Logic to get the currently selected room based on the UI, e.g., a variable tracking the active room
	# Placeholder: returns the first room for example purposes
	return rooms[currently_selected_room]

func show_energy_panel(energy_type):
	energy_title.text = energy_type
	energy_panel.visible = true

func hide_energy_panel():
	energy_panel.visible = false
	

# Update functions
func update_happiness(value):
	happiness = clamp(happiness + value, 0, 100)
	update_happiness_image()

func update_cleanliness(value):
	cleanliness = clamp(cleanliness + value, 0, 100)
	cleanliness_bar.value = cleanliness
	calculate_happiness_based_on_cleanliness()

func update_tourists(value):
	tourists = max(tourists + value, 0)
	tourists_label.text = "Tourists: " + str(tourists)
	calculate_wattage_usage()

func update_wattage(value):
	wattage = clamp(wattage + value, 0, 100)
	wattage_bar.value = wattage

func update_money(value):
	money = max(money + value, 0)
	money_label.text = "Money: " + str(money)

func update_cost(value):
	cost = max(cost + value, 0)
	cost_label.text = "Cost: " + str(cost)

# Update happiness image based on the current happiness value
func update_happiness_image():
	var index = int(happiness / 25.0)  # Divide by 25 to get an index from 0 to 4
	happiness_rect.texture = load(happiness_images[index])

# Influence functions using Lerp
func calculate_happiness_based_on_cleanliness():
	var cleanliness_factor = cleanliness / 100.0  # Normalize cleanliness to 0-1
	var adjustment = lerp(-1.0, 1.0, cleanliness_factor)  # Gradual adjustment based on cleanliness
	update_happiness(adjustment * cleanliness_to_happiness_multiplier)

func calculate_tourists_based_on_happiness():
	var happiness_factor = happiness / 100.0  # Normalize happiness to 0-1
	var adjustment = lerp(-1.0, 1.0, happiness_factor)  # Gradual adjustment based on happiness
	
	if adjustment < 0:  # If happiness is low, decrease tourists
		update_tourists(int(adjustment * 5 * happiness_to_tourists_multiplier))
	else:  # If happiness is high, increase tourists
		update_tourists(int(adjustment * happiness_to_tourists_multiplier))

	
# Calculate wattage usage based on tourists with Lerp
func calculate_wattage_usage():
	var required_wattage = tourists * tourists_to_wattage_multiplier
	wattage = clamp(wattage_capacity - required_wattage, 0, wattage_capacity) / wattage_capacity * 100
	update_wattage(0)

	var wattage_factor = wattage / 100.0  # Normalize wattage to 0-1
	var happiness_adjustment = lerp(-1.0, 1.0, wattage_factor)  # Gradual adjustment based on wattage
	update_happiness(happiness_adjustment * cleanliness_to_happiness_multiplier)

# New function to calculate cleanliness based on other factors
func calculate_cleanliness_factors():
	# Placeholder for future logic
	pass

# Process function to handle updates over time
func _process(delta):
	update_cleanliness(-0.1 * delta)  # Decrease cleanliness over time
	update_wattage(-0.05 * delta)  # Decrease wattage slowly over time

	calculate_happiness_based_on_cleanliness()
	calculate_tourists_based_on_happiness()
	calculate_wattage_usage()
	calculate_cleanliness_factors()

# Save and Load functions
func save_game():
	var save_data = {
		"happiness": happiness,
		"tourists": tourists,
		"wattage": wattage,
		"wattage_capacity": wattage_capacity,
		"cleanliness": cleanliness,
		"money": money,
		"cost": cost
	}
	
	var file = FileAccess.open("user://save_game.dat", FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))
	file.close()

func load_game():
	if FileAccess.file_exists("user://save_game.dat"):
		var file = FileAccess.open("user://save_game.dat", FileAccess.READ)
		
		var json = JSON.new()
		var result = json.parse(file.get_as_text())
		
		if result.error == OK:
			var save_data = result.result
			
			happiness = save_data.get("happiness", 100)
			tourists = save_data.get("tourists", 0)
			wattage = save_data.get("wattage", 100)
			wattage_capacity = save_data.get("wattage_capacity", 100)
			cleanliness = save_data.get("cleanliness", 100)
			money = save_data.get("money", 1000)
			cost = save_data.get("cost", 0)

			update_happiness_image()
			update_tourists(0)
			update_wattage(0)
			update_cleanliness(0)
			update_money(0)
			update_cost(0)
		
		file.close()
