extends Control
# Static variable to prevent duplicate initialization
static var is_initialized = false

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

# Image paths for happiness states
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

# Node references - initialize as null
var selected_skill_node: SkillNode = null
var current_tree: Control = null 
var line_update_timer: Timer = null
var skill_panel: Control = null
var energy_tree_title: Label = null
var title_label: Label = null
var description_label: Label = null
var price_label: Label = null
var invest_button: Button = null
var tech_image: TextureRect = null
var tree_exit: TextureButton = null

# Tech Trees - initialize as null
var fossilTree: Control = null
var hydroTree: Control = null
var windTree: Control = null
var solarTree: Control = null
var geoTree: Control = null
var nuclearTree: Control = null

# Other UI Elements - initialize as null
var happiness_rect: TextureRect = null
var tourists_label: Label = null
var wattage_bar: TextureProgressBar = null
var cleanliness_bar: TextureProgressBar = null
var money_label: Label = null
var cost_label: Label = null

# Panel and Button Nodes - initialize as null
var energy_panel: Control = null
var energy_title: Label = null
var exit_button: TextureButton = null
var plant_amount_label: Label = null
var create_plant_button: Button = null
var remove_plant_button: Button = null
var open_tech_tree_button: Button = null

# Initialize the game logic and nodes only when the game scene is active
func initialize_game_logic():
	# Initialize the nodes manually
	skill_panel = get_node("/root/Control/TreeContainer")
	energy_tree_title = get_node("/root/Control/TreeContainer/VBoxContainer/TopBar/Title Lable")
	title_label = get_node("/root/Control/TreeContainer/VBoxContainer/Menu/TechInfo/TechTitle")
	description_label = get_node("/root/Control/TreeContainer/VBoxContainer/Menu/TechInfo/TechDesc")
	price_label = get_node("/root/Control/TreeContainer/VBoxContainer/Menu/TechInfo/TechPrice")
	invest_button = get_node("/root/Control/TreeContainer/VBoxContainer/Menu/TechInfo/Investigar")
	tech_image = get_node("/root/Control/TreeContainer/VBoxContainer/Menu/TechInfo/TextureRect")
	tree_exit = get_node("/root/Control/TreeContainer/VBoxContainer/TopBar/ExitButton")

	# Tech Trees
	fossilTree = get_node("/root/Control/TreeContainer/VBoxContainer/Menu/FossilTree")
	hydroTree = get_node("/root/Control/TreeContainer/VBoxContainer/Menu/HydroTree")
	windTree = get_node("/root/Control/TreeContainer/VBoxContainer/Menu/WindTree")
	solarTree = get_node("/root/Control/TreeContainer/VBoxContainer/Menu/SolarTree")
	geoTree = get_node("/root/Control/TreeContainer/VBoxContainer/Menu/GeoTree")
	nuclearTree = get_node("/root/Control/TreeContainer/VBoxContainer/Menu/NuclearTree")

	# Other UI Elements
	happiness_rect = get_node("/root/Control/VBoxContainer/HBoxContainer/Happiness")
	tourists_label = get_node("/root/Control/VBoxContainer/HBoxContainer/Tourists")
	wattage_bar = get_node("/root/Control/VBoxContainer/HBoxContainer/Wattage")
	cleanliness_bar = get_node("/root/Control/VBoxContainer/HBoxContainer/Cleanliness")
	money_label = get_node("/root/Control/VBoxContainer/HBoxContainer/Money")
	cost_label = get_node("/root/Control/VBoxContainer/HBoxContainer/Cost")

	# Panel and Button Nodes
	energy_panel = get_node("/root/Control/PanelContainer")
	energy_title = get_node("/root/Control/PanelContainer/VBoxContainer/TopBar/EnergyType")
	exit_button = get_node("/root/Control/PanelContainer/VBoxContainer/TopBar/ExitButton")
	plant_amount_label = get_node("/root/Control/PanelContainer/VBoxContainer/Menu/VBoxContainer/PlantAmount")
	create_plant_button = get_node("/root/Control/PanelContainer/VBoxContainer/Menu/VBoxContainer/CreatePlant")
	remove_plant_button = get_node("/root/Control/PanelContainer/VBoxContainer/Menu/VBoxContainer/DeletePlant")
	open_tech_tree_button = get_node("/root/Control/PanelContainer/VBoxContainer/Menu/VBoxContainer3/OpenTechTree")


	# Set the process function to true to start updating every frame
	set_process(true)
	
	# Initially hide the energy panel
	energy_panel.visible = false
	hide_tech_trees()

	# Connect buttons to their respective functions
	exit_button.pressed.connect(hide_energy_panel)
	tree_exit.pressed.connect(_on_TreeExitButton_pressed)
	open_tech_tree_button.pressed.connect(_on_OpenTechTreeButton_pressed)
	
	create_plant_button.pressed.connect(_on_CreatePlantButton_pressed)
	remove_plant_button.pressed.connect(_on_RemovePlantButton_pressed)
	
	# Initialize rooms (assumed setup for room nodes)
	rooms = [
		get_node("/root/Control/VBoxContainer/GridContainer/Control"),
		get_node("/root/Control/VBoxContainer/GridContainer/Control2"),
		get_node("/root/Control/VBoxContainer/GridContainer/Control3"),
		get_node("/root/Control/VBoxContainer/GridContainer/Control4"),
		get_node("/root/Control/VBoxContainer/GridContainer/Control5"),
		get_node("/root/Control/VBoxContainer/GridContainer/Control6")
	]
	

	
	# Log for debugging
	print("Game logic initialized.")

func disable_game_logic():
	# Disconnect signals to prevent errors or unexpected behavior in other scenes
	exit_button.pressed.disconnect(hide_energy_panel)
	tree_exit.pressed.disconnect(_on_TreeExitButton_pressed)
	open_tech_tree_button.pressed.disconnect(_on_OpenTechTreeButton_pressed)
	
	create_plant_button.pressed.disconnect(_on_CreatePlantButton_pressed)
	remove_plant_button.pressed.disconnect(_on_RemovePlantButton_pressed)
	
	# Stop the process loop
	set_process(false)

	# Hide or reset panels and UI elements to a default state
	energy_panel.visible = false
	hide_tech_trees()

	print("Game logic disabled.")

func _ready():
	# Check if we are in the game scene
	set_process(false)
	if not is_initialized:
		is_initialized = true
		print(get_tree().current_scene.name)
		if get_tree().current_scene.name != "MainMenu":
			initialize_game_logic()
		else:
			print("disable")
			set_process(false)
			#disable_game_logic()
	else:
		print("GM already initialized")

func _on_CreatePlantButton_pressed():
	var room = get_selected_room()
	if room:
		room.create_plant()

func _on_RemovePlantButton_pressed():
	var room = get_selected_room()
	if room:
		room.remove_plant()

func update_panel(plant_amount, plant_cost, remove_plant_refund, id):
	print("updating panel")
	currently_selected_room = id
	print(plant_amount)
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
	energy_tree_title.text = energy_type + " - Tecnologías"
	
	match energy_type:
		"Central de Combustibles Fósiles":
			switch_tree(fossilTree)
		"Central Hydroeléctrica":
			switch_tree(hydroTree)
		"Central Eólica":
			switch_tree(windTree)
		"Central Solar":
			switch_tree(solarTree)
		"Central Geotérmica":
			switch_tree(geoTree)
		"Central Nuclear":
			switch_tree(nuclearTree)
			
	call_deferred("force_update_lines")

# Switch between tech trees
func switch_tree(tree: Control):
	if current_tree:
		current_tree.visible = false
	tree.visible = true
	current_tree = tree
	
	# Ensure the tree is fully visible before updating the lines
	#call_deferred("force_update_lines", tree)

func force_update_lines():
	# Get all skill nodes in the tree, including children, grandchildren, etc.
	update_skill_lines_recursive(self)
	print("DSA")

# Recursively updates all SkillNode children
func update_skill_lines_recursive(node):
	if node is SkillNode:
		node._update_lines()  # Update the lines for the current skill
	for child in node.get_children():
		update_skill_lines_recursive(child)  # Recursively apply to all children

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
	print("Applying: ", effect_type , "value: " , effect_value)
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
		"cost": cost,
		"skills":[]
	}
	
	# Save the state of all skills
	for skill in get_all_skills():
		save_data["skills"].append(skill.save_state())
	
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
			
			# Load the state of all skills
			var skills_data = save_data.get("skills", [])
			var all_skills = get_all_skills()

			for i in range(skills_data.size()):
				all_skills[i].load_state(skills_data[i])
		
		file.close()

func get_all_skills():
	# Return a list of all SkillNodes in the scene
	# Modify this based on how skills are structured in your game
	var skills = []
	# Assuming skills are children of a container or grid in the scene
	for skill in $SkillContainer.get_children():
		if skill is SkillNode:
			skills.append(skill)
	return skills
