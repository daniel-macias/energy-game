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
var skill_states = {}  # Dictionary to store skill states

var selected_skill_node: SkillNode = null
var current_tree: Control = null 

#Skill Tree Panel References
@onready var skill_panel = get_node("/root/Control/TreeContainer")
@onready var energy_tree_title = get_node("/root/Control/TreeContainer/VBoxContainer/TopBar/Title Lable")
@onready var title_label = get_node("/root/Control/TreeContainer/VBoxContainer/Menu/TechInfo/TechTitle")
@onready var description_label = get_node("/root/Control/TreeContainer/VBoxContainer/Menu/TechInfo/TechDesc")
@onready var price_label = get_node("/root/Control/TreeContainer/VBoxContainer/Menu/TechInfo/TechPrice")
@onready var invest_button = get_node("/root/Control/TreeContainer/VBoxContainer/Menu/TechInfo/Investigar")
@onready var tech_image = get_node("/root/Control/TreeContainer/VBoxContainer/Menu/TechInfo/TextureRect")
@onready var tree_exit = get_node("/root/Control/TreeContainer/VBoxContainer/TopBar/ExitButton")

#Tech Trees
@onready var fossilTree = get_node("/root/Control/TreeContainer/VBoxContainer/Menu/FossilTree")
@onready var hydroTree = get_node("/root/Control/TreeContainer/VBoxContainer/Menu/HydroTree")
@onready var windTree = get_node("/root/Control/TreeContainer/VBoxContainer/Menu/WindTree")
@onready var solarTree = get_node("/root/Control/TreeContainer/VBoxContainer/Menu/SolarTree")
@onready var geoTree = get_node("/root/Control/TreeContainer/VBoxContainer/Menu/GeoTree")
@onready var nuclearTree = get_node("/root/Control/TreeContainer/VBoxContainer/Menu/NuclearTree")

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
@onready var happiness_rect = get_node("/root/Control/VBoxContainer/HBoxContainer/Happiness")
@onready var tourists_label = get_node("/root/Control/VBoxContainer/HBoxContainer/Tourists")
@onready var wattage_bar = get_node("/root/Control/VBoxContainer/HBoxContainer/Wattage")
@onready var cleanliness_bar = get_node("/root/Control/VBoxContainer/HBoxContainer/Cleanliness")
@onready var money_label = get_node("/root/Control/VBoxContainer/HBoxContainer/Money")
@onready var cost_label = get_node("/root/Control/VBoxContainer/HBoxContainer/Cost")

#Panel Node References
@onready var energy_panel = get_node("/root/Control/PanelContainer")
@onready var energy_title = get_node("/root/Control/PanelContainer/VBoxContainer/TopBar/EnergyType")
@onready var exit_button = get_node("/root/Control/PanelContainer/VBoxContainer/TopBar/ExitButton")
@onready var plant_amount_label = get_node("/root/Control/PanelContainer/VBoxContainer/Menu/VBoxContainer/PlantAmount")
@onready var create_plant_button = get_node("/root/Control/PanelContainer/VBoxContainer/Menu/VBoxContainer/CreatePlant")
@onready var remove_plant_button = get_node("/root/Control/PanelContainer/VBoxContainer/Menu/VBoxContainer/DeletePlant")
@onready var open_tech_tree_button = get_node("/root/Control/PanelContainer/VBoxContainer/Menu/VBoxContainer3/OpenTechTree")

func _ready():
	load_game()
	set_process(true)  # Enable _process() to make updates over time
	
	 # Initially hide the energy panel
	energy_panel.visible = false
	hide_tech_trees()
	
	# Connect the exit button to close the panel
	exit_button.pressed.connect(hide_energy_panel)
	tree_exit.pressed.connect(_on_TreeExitButton_pressed)
	open_tech_tree_button.pressed.connect(_on_OpenTechTreeButton_pressed)
	
	create_plant_button.pressed.connect(_on_CreatePlantButton_pressed)
	remove_plant_button.pressed.connect(_on_RemovePlantButton_pressed)
	
	rooms = [
		get_node("/root/Control/VBoxContainer/GridContainer/Control"),
		get_node("/root/Control/VBoxContainer/GridContainer/Control2"),
		get_node("/root/Control/VBoxContainer/GridContainer/Control3"),
		get_node("/root/Control/VBoxContainer/GridContainer/Control4"),
		get_node("/root/Control/VBoxContainer/GridContainer/Control5"),
		get_node("/root/Control/VBoxContainer/GridContainer/Control6")
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
	
# Clear the sidebar (tech info) when switching trees or nothing is selected
func clear_sidebar():
	title_label.text = ""
	description_label.text = ""
	price_label.text = ""
	invest_button.disabled = true
	#tech_image.texture = null

# Show the appropriate tech tree and hide the main panel
func _on_OpenTechTreeButton_pressed():
	var energy_type = energy_title.text
	
	# Hide the main panel and show the TreeContainer
	hide_main_panel()
	show_tree_container()
	clear_sidebar()  # Clear sidebar when switching to a new tree
	
	# Update the tree title
	energy_tree_title.text = energy_type + " Tree"
	
	match energy_type:
		"Fossil Fuel":
			switch_tree(fossilTree)
		"Hydro":
			switch_tree(hydroTree)
		"Wind":
			switch_tree(windTree)
		"Solar":
			switch_tree(solarTree)
		"Geo":
			switch_tree(geoTree)
		"Nuclear":
			switch_tree(nuclearTree)

# Switch between tech trees
func switch_tree(tree: Control):
	if current_tree:
		current_tree.visible = false
	tree.visible = true
	current_tree = tree

# Hide the main panel and show the tech tree container
func hide_main_panel():
	energy_panel.visible = false
	
func show_tree_container():
	# Deselect the previous skill (if any)
	if selected_skill_node != null:
		selected_skill_node.deselect()
	skill_panel.visible = true

# Hide the tech tree and bring back the main panel
func _on_TreeExitButton_pressed():
	hide_tech_trees()
	show_main_panel()
	hide_tree_container()
	
func hide_tree_container():
	skill_panel.visible = false

# Hide all tech trees
func hide_tech_trees():
	fossilTree.visible = false
	hydroTree.visible = false
	windTree.visible = false
	solarTree.visible = false
	geoTree.visible = false
	nuclearTree.visible = false# Hide all tech trees

func show_main_panel():
	energy_panel.visible = true

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

# Update the skill panel with the selected skill details
func update_skill_panel(title: String, description: String, price: int, effects: Array, skill_node: SkillNode):
	title_label.text = title
	description_label.text = description
	price_label.text = str(price) + " Gold"
	invest_button.disabled = money < price  # Disable if not enough money

	# Deselect the previous skill (if any)
	if selected_skill_node != null:
		selected_skill_node.deselect()
		pass
		
	selected_skill_node = skill_node
	selected_skill_node.select()
	
		# Disconnect any previous signal connection
	if invest_button.is_connected("pressed", Callable(self, "on_invest_button_pressed")):
		invest_button.disconnect("pressed", Callable(self, "on_invest_button_pressed"))
		
	# Connect the Invest button to the skill's activate function
	invest_button.connect("pressed", Callable(self, "on_invest_button_pressed"))
	# Display or log the effects for debugging or visualization
	for effect in effects:
		print("Effect Type: %s, Value: %f" % [effect["type"], effect["value"]])
		

func on_invest_button_pressed():
	if selected_skill_node:
		selected_skill_node.activate_skill()  # Activate the selected skill

func apply_skill_effect(effect_type: String, effect_value: float):
	pass
	#match effect_type:
		#"money_multiplier":
			#money_multiplier += effect_value
		#"tourist_multiplier":
			#tourist_multiplier += effect_value
		# Add other effects here

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
