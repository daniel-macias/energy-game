extends Control
# Static variable to prevent duplicate initialization
static var is_initialized = false

# Game variables
var happiness = 100  # 0 to 100
var tourists = 0  # 0 to infinity
var wattage = 100  # 0 to 100 (current wattage usage as a percentage of capacity)
var wattage_capacity = 1000  # Max wattage capacity (can be increased with upgrades)
var cleanliness = 50  # 0 to 100
var money = 40000
var attractiveness = 10
#var contaminationCapacity = 0
var rooms = []
var currently_selected_room = -1  # -1 means no room is currently selected
var skill_states = {}  # Dictionary to store skill states

var main_game_scene: Node = null

# Image paths for happiness states
var happiness_images = [
	"res://sprites/ui/happy_0.png",
	"res://sprites/ui/happy_1.png",
	"res://sprites/ui/happy_2.png",
	"res://sprites/ui/happy_3.png",
	"res://sprites/ui/happy_4.png"
]

var empty_tech := "res://sprites/ui/tech_empty.png"

# Multipliers for balancing
@export var cleanliness_to_happiness_multiplier = 4.0
@export var happiness_to_tourists_multiplier = 10.0
@export var tourists_to_wattage_multiplier = 10.0
@export var wattage_to_happiness_multiplier = 2.0


@export var money_per_tourist: float = 1.0  # Money generated per tourist per minute
@export var update_interval: float = 1.0  # Interval for updating money (in seconds)
var total_money_generated: float = 0.0

var money_generated_last_minute: float = 0.0  # To track money generated over the last minute
var minute_timer: float = 0.0  # Timer to track the last minute for averaging

# Node references - initialize as null
var selected_skill_node: SkillNode = null
var current_tree: Control = null 
var line_update_timer: Timer = null
var skill_panel: Control = null
var energy_tree_title: Label = null
var title_label: Label = null
var description_label: RichTextLabel = null
var price_label: Label = null
var invest_button: Button = null
var tech_image: TextureRect = null
var tree_exit: TextureButton = null
var open_dec_button: Button = null;

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
var CC_label: Label = null

# Panel and Button Nodes - initialize as null
var energy_panel: Control = null
var energy_title: Label = null
var exit_button: TextureButton = null
var plant_amount_label: Label = null
var create_plant_button: Button = null
var remove_plant_button: Button = null
var open_tech_tree_button: Button = null

var bajo_cap : Label = null
var sobre_cap : Label = null
var energ_total : Label = null
var cont_cap : Label = null
var cont_total : Label = null
var cont_x_planta : Label = null
var energ_x_planta : Label = null

var panel_cover : Panel = null

var tech_container : PanelContainer = null
var tech_exit : TextureButton = null
var tech_title : Label = null
var tech_info : Label = null

var animal_container : PanelContainer = null
var exit_animal : TextureButton = null
var animal_pic : TextureRect = null
var animal_name : Label = null
var animal_species : Label = null
var animal_scientific : Label = null
var animal_info : Label = null

var energy_panel_animal_pic : TextureRect = null
var open_animal_info_button : Button = null

var fish_button : TextureButton = null

var main_game_root : Control = null

#Custom Dialog
var custom_dialog : PanelContainer = null
var custom_dialog_title : Label = null
var custom_dialog_desc : Label = null
var custom_dialog_exit : TextureButton = null

var avg_money_label : Label = null

#Fish game var
var trash_shot := 0
var friend_shot := 0

@onready var auto_save_timer = Timer.new()
# Initialize the game logic and nodes only when the game scene is active
func initialize_game_logic():
	# Initialize the nodes manually
	main_game_root = get_node("/root/Control")
	
	skill_panel = get_node("/root/Control/TreeContainer")
	energy_tree_title = get_node("/root/Control/TreeContainer/VBoxContainer/TopColor/TopBar/Title Lable")
	title_label = get_node("/root/Control/TreeContainer/VBoxContainer/Menu/TechInfo/TechTitle")
	description_label = get_node("/root/Control/TreeContainer/VBoxContainer/Menu/TechInfo/TechDesc")
	price_label = get_node("/root/Control/TreeContainer/VBoxContainer/Menu/TechInfo/TechPrice")
	invest_button = get_node("/root/Control/TreeContainer/VBoxContainer/Menu/TechInfo/Investigar")
	tech_image = get_node("/root/Control/TreeContainer/VBoxContainer/Menu/TechInfo/TextureRect")
	tree_exit = get_node("/root/Control/TreeContainer/VBoxContainer/TopColor/TopBar/ExitButton")
	open_dec_button = get_node("/root/Control/TreeContainer/VBoxContainer/Menu/TechInfo/Info")

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
	CC_label = get_node("/root/Control/VBoxContainer/HBoxContainer/Cost")

	# Panel and Button Nodes
	energy_panel = get_node("/root/Control/PanelContainer")
	energy_title = get_node("/root/Control/PanelContainer/VBoxContainer/TopColor/TopBar/EnergyType")
	exit_button = get_node("/root/Control/PanelContainer/VBoxContainer/TopColor/TopBar/ExitButton")
	plant_amount_label = get_node("/root/Control/PanelContainer/VBoxContainer/Menu/VBoxContainer/PlantAmount")
	create_plant_button = get_node("/root/Control/PanelContainer/VBoxContainer/Menu/VBoxContainer/DataContainer/CreatePlant")
	remove_plant_button = get_node("/root/Control/PanelContainer/VBoxContainer/Menu/VBoxContainer/DataContainer2/DeletePlant")
	open_tech_tree_button = get_node("/root/Control/PanelContainer/VBoxContainer/Menu/VBoxContainer3/OpenTechTree")

	panel_cover = get_node("/root/Control/PanelCover")
	#Tech Info Nodes
	tech_container = get_node("/root/Control/InfoAboutTech")
	tech_exit = get_node("/root/Control/InfoAboutTech/VBoxContainer/Panel/TopBar/ExitButton")
	tech_title = get_node("/root/Control/InfoAboutTech/VBoxContainer/Panel/TopBar/Title")
	tech_info = get_node("/root/Control/InfoAboutTech/VBoxContainer/InfoText")
	
	#Animal Info Nodes
	animal_container = get_node("/root/Control/AnimalInfo")
	exit_animal = get_node("/root/Control/AnimalInfo/VBoxContainer/Panel/TopBar/ExitButton")
	animal_pic = get_node("/root/Control/AnimalInfo/VBoxContainer/HBoxContainer/VBoxContainer/TextureRect")
	animal_name = get_node("/root/Control/AnimalInfo/VBoxContainer/HBoxContainer/VBoxContainer/Name")
	animal_species = get_node("/root/Control/AnimalInfo/VBoxContainer/HBoxContainer/VBoxContainer/Species")
	animal_scientific = get_node("/root/Control/AnimalInfo/VBoxContainer/HBoxContainer/VBoxContainer/Scientific")
	animal_info = get_node("/root/Control/AnimalInfo/VBoxContainer/HBoxContainer/InfoText")
	
	energy_panel_animal_pic = get_node("/root/Control/PanelContainer/VBoxContainer/Menu/VBoxContainer3/AnimalPic")
	open_animal_info_button = get_node("/root/Control/PanelContainer/VBoxContainer/Menu/VBoxContainer3/OpenAnimalInfo")
	
	fish_button = get_node("/root/Control/VBoxContainer/HBoxContainer/GoToFish")
	# Set the process function to true to start updating every frame
	set_process(true)
	
	#Custom Dialog
	custom_dialog = get_node("/root/Control/CustomDialog")
	custom_dialog_title = get_node("/root/Control/CustomDialog/VBoxContainer/Panel/TopBar/Title")
	custom_dialog_desc = get_node("/root/Control/CustomDialog/VBoxContainer/InfoText")
	custom_dialog_exit = get_node("/root/Control/CustomDialog/VBoxContainer/Panel/TopBar/ExitButton")
	
	#other panel info
	bajo_cap = get_node("/root/Control/PanelContainer/VBoxContainer/Menu/VBoxContainer2/BajoCap")
	sobre_cap = get_node("/root/Control/PanelContainer/VBoxContainer/Menu/VBoxContainer2/SobreCap")
	energ_total = get_node("/root/Control/PanelContainer/VBoxContainer/Menu/VBoxContainer2/HBoxContainer3/EnergTotal")
	cont_cap = get_node("/root/Control/PanelContainer/VBoxContainer/Menu/VBoxContainer2/HBoxContainer/ContCap")
	cont_total = get_node("/root/Control/PanelContainer/VBoxContainer/Menu/VBoxContainer2/HBoxContainer2/ContTotal")
	cont_x_planta = get_node("/root/Control/PanelContainer/VBoxContainer/Menu/VBoxContainer/HBoxContainer3/ContXPlanta")
	energ_x_planta = get_node("/root/Control/PanelContainer/VBoxContainer/Menu/VBoxContainer/HBoxContainer4/EnergXPlanta")
	
	avg_money_label = get_node("/root/Control/VBoxContainer/HBoxContainer/IncomeAvg")
	
	# Initially hide the energy panel
	#energy_panel.visible = false
	#hide_tech_trees()

	# Connect buttons to their respective functions
	exit_button.pressed.connect(hide_energy_panel)
	tree_exit.pressed.connect(_on_TreeExitButton_pressed)
	open_tech_tree_button.pressed.connect(_on_OpenTechTreeButton_pressed)
	
	create_plant_button.pressed.connect(_on_CreatePlantButton_pressed)
	remove_plant_button.pressed.connect(_on_RemovePlantButton_pressed)
	
	open_animal_info_button.pressed.connect(on_open_animal_window_pressed)
	exit_animal.pressed.connect(close_animal_window)
	
	open_dec_button.pressed.connect(on_open_skill_window_pressed)
	tech_exit.pressed.connect(close_skill_window)
	
	fish_button.pressed.connect(goToFishGame)
	
	custom_dialog_exit.pressed.connect(close_custom_dialog)
	
	# Initialize rooms (assumed setup for room nodes)
	rooms = [
		get_node("/root/Control/VBoxContainer/GridContainer/Control"),
		get_node("/root/Control/VBoxContainer/GridContainer/Control2"),
		get_node("/root/Control/VBoxContainer/GridContainer/Control3"),
		get_node("/root/Control/VBoxContainer/GridContainer/Control4"),
		get_node("/root/Control/VBoxContainer/GridContainer/Control5"),
		get_node("/root/Control/VBoxContainer/GridContainer/Control6")
	]
	

	add_child(auto_save_timer)
	auto_save_timer.wait_time = 120  # 2 minutes
	auto_save_timer.autostart = true
	auto_save_timer.one_shot = false
	auto_save_timer.timeout.connect(_on_auto_save_timer_timeout)
	auto_save_timer.start()
	# Log for debugging
	print("Game logic initialized.")

func _on_auto_save_timer_timeout():
	print("Auto-saving game...")
	save_game()  # Call your save_game function

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
	print(get_tree().current_scene.name)
	var scene = get_tree().current_scene.name
	print(scene)
	set_process(false)
	if not is_initialized:
		is_initialized = true
		print(get_tree().current_scene.name)
		if get_tree().current_scene.name != "MainMenu" && get_tree().current_scene.name != "Fish":
			initialize_game_logic()
		else:
			print("disable")
			set_process(false)
			#disable_game_logic()
	else:
		print("GM already initialized")

func close_custom_dialog():
	custom_dialog.visible = false
	panel_cover.visible = false

func open_custom_dialog(title, desc):
	custom_dialog.visible = true
	panel_cover.visible = true
	custom_dialog_title.text = title
	custom_dialog_desc.text = desc

func _on_CreatePlantButton_pressed():
	var room = get_selected_room()
	if room:
		room.create_plant()
		save_game()

func _on_RemovePlantButton_pressed():
	var room = get_selected_room()
	if room:
		room.remove_plant()
		save_game()

func update_panel(plant_amount, plant_cost, remove_plant_refund, id, CC, contaminationI, wattageI):
	print("updating panel")
	currently_selected_room = id
	print(plant_amount)
	plant_amount_label.text = str(plant_amount)
	create_plant_button.text = "- $ " + str(plant_cost)
	remove_plant_button.text =  "+ $ " +str(remove_plant_refund)
	
	cont_cap.text = str(CC)
	cont_total.text = str(int(contaminationI * 100 * plant_amount))
	energ_total.text = str(int(wattageI * 1000 * plant_amount))
	energ_x_planta.text = str(int(wattageI * 1000))
	cont_x_planta.text = str(int(contaminationI * 100))
	if CC > contaminationI * 100 * plant_amount:
		bajo_cap.visible = true
		sobre_cap.visible = false
	else:
		bajo_cap.visible = false
		sobre_cap.visible = true
	
	

func update_animal_info(name, species, scientific, info, animal_portrait):
	animal_info.text = info
	animal_name.text = name
	animal_species.text = species
	animal_scientific.text = scientific
	animal_pic.texture = animal_portrait
	energy_panel_animal_pic.texture = animal_portrait

func update_skill_info(name,info):
	tech_title.text = name
	tech_info.text = info
	

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
	open_dec_button.disabled = true
	tech_image.texture = load(empty_tech)

# Show the appropriate tech tree and hide the main panel
func _on_OpenTechTreeButton_pressed():
	var energy_type = energy_title.text
	
	# Hide the main panel and show the TreeContainer
	hide_main_panel()
	show_tree_container()
	clear_sidebar()  # Clear sidebar when switching to a new tree
	
	# Update the tree title
	energy_tree_title.text = energy_type + " - Tecnologías"
	
	#No tech selected
	description_label.text = "Selecione una tecnología para ver detalles"
	
	match energy_type:
		"Central de Combustibles Fósiles":
			switch_tree(fossilTree)
		"Central Hidroeléctrica":
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
	update_skill_lines_recursive(skill_panel)
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

func set_cleanliness(value):
	cleanliness = value
	cleanliness_bar.value = value

func contaminate(contamination_value: float):
	var whole = - contamination_value / 10000
	# Decrease cleanliness based on the contamination value
	cleanliness = clamp(cleanliness - whole, 0, 100)
	cleanliness_bar.value = cleanliness
	#calculate_happiness_based_on_cleanliness()

func update_cleanliness(contamination_value):
	if contamination_value < 0:  # Active contamination, cleanliness decreases
		cleanliness = clamp(cleanliness + contamination_value, 0, 100)
	elif contamination_value > 0:  # No contamination or low contamination, cleanliness improves
		var cleanliness_recovery_rate = contamination_value * 0.1  # The lower the contamination, the better the recovery
		cleanliness = clamp(cleanliness + cleanliness_recovery_rate, 0, 100)

	cleanliness_bar.value = cleanliness
	calculate_happiness_based_on_cleanliness()

func update_tourists(value):
	tourists = value
	tourists_label.text = "Turistas: " + str(int(tourists))
	calculate_wattage_usage()

func update_wattage(value):
	#wattage = clamp(wattage + value, 0, 100)
	wattage_bar.value = wattage

func update_money(value):
	money = max(money + value, 0)
	money_label.text = "$ " + str(int(money))
	for room in rooms:
		if room.unlock_price > money:
			room.unlock_btn.disabled = true
		else:
			room.unlock_btn.disabled = false

#func update_CC(value):
#	contaminationCapacity = max(contaminationCapacity + value, 0)
#	CC_label.text = "Capacidad: " + str(contaminationCapacity)

# Update happiness image based on the current happiness value
func update_happiness_image():
	var index = int(happiness / 25.0)  # Divide by 25 to get an index from 0 to 4
	happiness_rect.texture = load(happiness_images[index])

# Influence functions using Lerp
func calculate_happiness_based_on_cleanliness():
	var cleanliness_factor = cleanliness / 100.0  # Normalize cleanliness to 0-1
	var adjustment = lerp(-1.0, 1.0, cleanliness_factor)  # Gradual adjustment based on cleanliness
	update_happiness(adjustment * cleanliness_to_happiness_multiplier)

func calculate_tourists():

	var base_tourists = 50  # This is a base number of tourists you might start with.
	var cleanliness_factor = cleanliness / 100.0  # Convert cleanliness to a factor between 0 and 1.
	
	# Calculate tourists based on cleanliness and attractiveness
	var newTourismNumber = base_tourists * cleanliness_factor * attractiveness
	
	# Ensure you don't go below 0 tourists
	newTourismNumber = max(newTourismNumber, 0)
	
	# Update the number of tourists
	update_tourists(newTourismNumber)

	
# Calculate wattage usage based on tourists with Lerp
func calculate_wattage_usage():
	var wattage_use_by_tourists = tourists * tourists_to_wattage_multiplier
	wattage = clamp(wattage_capacity - wattage_use_by_tourists, 0, wattage_capacity) / wattage_capacity * 100
	
	update_wattage(wattage)
	#TODO: Update bar

	var wattage_factor = wattage / 100.0  # Normalize wattage to 0-1
	var happiness_adjustment = lerp(-1.0, 1.0, wattage_factor)  # Gradual adjustment based on wattage
	update_happiness(happiness_adjustment * wattage_to_happiness_multiplier)

# New function to calculate cleanliness based on other factors
func calculate_cleanliness_factors():
	# Placeholder for future logic
	pass



func _process(delta):
	var total_contamination = 0.0
	var total_wattage = 0.0
	var total_happiness = 0.0
	
	minute_timer += delta
	if minute_timer >= 60.0:  # Every minute
		minute_timer = 0.0
		calculate_avg_money_per_minute()  # Calculate the average money per minute

	if update_interval > 0.0:
		generate_money(delta)
	
	for room in rooms:
		var num_plants = room.plant_amount
		
		if num_plants > 0:
			# Apply room-specific contamination and wattage effects
			var room_total_contamination = room.contaminationIndex * num_plants * 100  # Calculate total contamination per room
			total_contamination += room_total_contamination

			# Check if the room's total contamination exceeds its capacity
			if room_total_contamination > room.contaminationCapacity:
				# Apply the excess contamination to cleanliness
				contaminate(-(room_total_contamination - room.contaminationCapacity))
			
			wattage_capacity  = room.wattageIndex * num_plants * 1000
			
			total_happiness += room.happinessIndex * num_plants * delta
			# Handle room notification timers or other specific room logic
			room.notification_timer -= delta
			if room.notification_timer <= 0:
				trigger_notification(room)
				room.notification_timer = room.notification_interval  # Reset the timer for next notification

	# Apply contamination effect (e.g., decreasing cleanliness)
	#update_cleanliness(-total_contamination)
	
	# Apply wattage effect (e.g., modifying wattage capacity)
	#update_wattage(total_wattage)

	# Adjust happiness globally based on room effects
	#adjust_happiness(total_happiness) NOT EXISTENT
	
	# Now apply the global updates based on the combined effects
	calculate_happiness_based_on_cleanliness()
	calculate_tourists()
	#calculate_wattage_usage()  # Could use total_wattage in the calculation
	calculate_cleanliness_factors()

func trigger_notification(room):
	room.notification_button.visible = true
	if not room.animation_player_bag.is_playing():
		room.animation_player_bag.play("bag_appears")

func generate_money(delta):
	# Calculate money generated during this interval
	var money_generated = (tourists * money_per_tourist) * (delta / 60.0)  # delta is divided by 60 to normalize per minute
	total_money_generated += money_generated
	money_generated_last_minute += money_generated

	# Update the player's money
	update_money(money_generated)

func calculate_avg_money_per_minute():
	var avg_money_per_minute = money_generated_last_minute
	money_generated_last_minute = 0.0  # Reset for the next minute
	
	# Display or store avg_money_per_minute as needed
	update_avg_money_display(avg_money_per_minute)

func update_avg_money_display(avg_money_per_minute):
	# Assuming you have a label or UI element to display the average money per minute
	avg_money_label.text = "$ p/m: " + str(int(avg_money_per_minute))


# Update the skill panel with the selected skill details
func update_skill_panel(title: String, description: String, price: int, effects: Array, skill_node: SkillNode):
	title_label.text = title
	description_label.text = description
	price_label.text = "$ " + str(price) 
	invest_button.disabled = money < price  # Disable if not enough money
	tech_image.texture = skill_node.texture_normal  

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
	description_label.clear()
	for effect in effects:
		var effect_type = effect["type"]
		var effect_value = effect["value"]
	
		var display_text = ""
		var color = Color(1, 1, 1)  # Default color (white)
	
		# Translate effect types to Spanish
		match effect_type:
			"wattage_multiplier":
				display_text = "Energía: +%0.1f%%" % [effect_value * 100]
				color = Color(0.07, 0.4, 0)  # Green for positive impact
		
			"happiness_multiplier":
				display_text = "Capacidad de Contaminación: +%0.1f%%" % [effect_value * 100]
				color = Color(0.07, 0.4, 0)  # Green for positive impact
		
			"money_multiplier":
				display_text = "Dinero: +%0.1f%%" % [effect_value * 100]
				color = Color(0.07, 0.4, 0)  # Green for positive impact
		
			"contamination_multiplier":
				display_text = "Contaminación: +%0.1f%%" % [effect_value * 100]
				color = Color(1, 0, 0)  # Red for negative impact (more contamination is bad)
		
			"room_buy_price_mult":
				display_text = "Precio de Planta: +%0.1f%%" % [effect_value * 100]
				color = Color(1, 0, 0)  # Red for negative impact (higher prices are bad)
		
			"room_refund_price_mult":
				display_text = "Reembolso de Planta: %0.1f%%" % [effect_value * 100]
				color = Color(0.07, 0.4, 0) if effect_value > 0 else Color(1, 0, 0)  # Green for higher refunds, red for lower refunds
			
			"room_notification_value":
				display_text = "Dinero de recompensa: +%0.1f%%" % [effect_value * 100]
				color = Color(0.07, 0.4, 0)  # Green for positive impact
			
			"room_notification_frequency":
				display_text = "Frecuencia de recompensa: +%0.1f%%" % [effect_value * 100]
				color = Color(0.07, 0.4, 0)  # Green for positive impact
				
			"room_clicker":
				display_text = "Dinero al presionar trabajador: +%0.1f%%" % [effect_value * 100]
				color = Color(0.07, 0.4, 0)  # Green for positive impact
		# Add text with the appropriate color
		description_label.push_color(color)
		description_label.add_text(display_text + "\n")
		description_label.pop()  # Reset color

func on_invest_button_pressed():
	if selected_skill_node:
		selected_skill_node.activate_skill()  # Activate the selected skill
		save_game()
		

func on_open_animal_window_pressed():
	panel_cover.visible = true
	animal_container.visible = true

func close_animal_window():
	panel_cover.visible = false
	animal_container.visible = false

func on_open_skill_window_pressed():
	panel_cover.visible = true
	tech_container.visible = true

func close_skill_window():
	panel_cover.visible = false
	tech_container.visible = false

func apply_skill_effect(effect_type: String, effect_value: float, roomId: int, level: int):
	print("Applying: ", effect_type , "value: " , effect_value)

	var room = rooms[roomId]
	match effect_type:
		"money_multiplier":
			# Increase the clicker reward by the percentage, applying the skill level.
			room.clicker_reward *= (1 + (effect_value * level))
			
		"wattage_multiplier":
			room.wattageIndex *= (1 + (effect_value * level))

		"contamination_multiplier":
			# Increase or decrease contamination index by the percentage.
			room.contaminationIndex *= (1 + (effect_value * level))

		"happiness_multiplier":
			# Increase or decrease happiness index by the percentage.
			room.happinessIndex *= (1 + (effect_value * level))
			room.contaminationCapacity *= (1 + (effect_value * level))
			attractiveness *= (1 + (effect_value * level))
		
		"room_notification_value":
			# Increase the reward when clicking notifications.
			room.notification_reward *= (1 + (effect_value * level))
		
		"room_notification_frequency":
			# Placeholder for now as it depends on notification system.
			room.notification_interval *= (1 + ((-1) * effect_value * level))
		
		"room_clicker":
			# Increase the clicker reward by the percentage.
			room.clicker_reward *= (1 + (effect_value * level))

		"room_buy_price_mult":
			# Increase the plant cost by the percentage.
			room.plant_cost *= (1 + (effect_value * level))
		
		"room_refund_price_mult":
			# Increase the refund amount by the percentage.
			room.remove_plant_refund *= (1 + (effect_value * level))

# Save and Load functions
func save_game():
	print("Saving...")
	var save_data = {
		"happiness": happiness,
		"tourists": tourists,
		"wattage": wattage,
		"wattage_capacity": wattage_capacity,
		"cleanliness": cleanliness,
		"money": money,
		#"contaminationCapacity": contaminationCapacity,
		"roomsUnlocked":[rooms[0].unlocked,
		rooms[1].unlocked,
		rooms[2].unlocked,
		rooms[3].unlocked,
		rooms[4].unlocked,
		rooms[5].unlocked],
		"roomAmount":[rooms[0].plant_amount,
		rooms[1].plant_amount,
		rooms[2].plant_amount,
		rooms[3].plant_amount,
		rooms[4].plant_amount, 
		rooms[5].plant_amount],
		"skills":[]
	}
	
	# Save the state of all skills
	for skill in get_all_skills():
		save_data["skills"].append(skill.save_state())
	
	var file = FileAccess.open("user://save_game.dat", FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))
	file.close()
	print("Saved!")

func load_game():
	print("Loading...")
	if FileAccess.file_exists("user://save_game.dat"):
		var file = FileAccess.open("user://save_game.dat", FileAccess.READ)
		
		var result = JSON.parse_string(file.get_as_text())
		
		if result:
			var save_data = result
			
			happiness = save_data.get("happiness", 100)
			tourists = save_data.get("tourists", 0)
			wattage = save_data.get("wattage", 100)
			wattage_capacity = save_data.get("wattage_capacity", 100)
			cleanliness = save_data.get("cleanliness", 100)
			money = save_data.get("money", 1000)

			update_happiness_image()
			update_tourists(tourists)
			update_wattage(wattage)

			#Load room amount
			var roomsTemp = save_data.get("roomAmount", [])
			var roomsUnlocked = save_data.get("roomsUnlocked", [])
			rooms[0].plant_amount = roomsTemp[0]
			rooms[0].unlocked = roomsUnlocked[0]
			rooms[1].plant_amount = roomsTemp[1]
			rooms[1].unlocked = roomsUnlocked[1]
			rooms[2].plant_amount = roomsTemp[2]
			rooms[2].unlocked = roomsUnlocked[2]
			rooms[3].plant_amount = roomsTemp[3]
			rooms[3].unlocked = roomsUnlocked[3]
			rooms[4].plant_amount = roomsTemp[4]
			rooms[4].unlocked = roomsUnlocked[4]
			rooms[5].plant_amount = roomsTemp[5]
			rooms[5].unlocked = roomsUnlocked[5]
			
			for room in GameManager.rooms:
				room.update_room_state()
			
			
			# Load the state of all skills
			var skills_data = save_data.get("skills", [])
			var all_skills = get_all_skills()
			
			print(all_skills)
			for i in range(all_skills.size()):
				print("Button Values")
				print("Room ID " + str(all_skills[i].roomId))
				print("Skill ID " + str(all_skills[i].skillId))
				print("Loaded Values")
				print("Room ID " + str(skills_data[i].roomId))
				print("Skill ID " + str(skills_data[i].skillId))
				
				
			for i in range(skills_data.size()):
				all_skills[i].load_state(skills_data[i])
		
		file.close()

func goToFishGame():
	# Pause the GameManager by setting process mode
	var main_game_scene = get_tree().current_scene
	
	self.set_process(false)
	self.set_physics_process(false)
	
	# Switch to the fish game scene
	var fish_scene = load("res://scenes/fish.tscn").instantiate()
	get_tree().root.add_child(fish_scene)
	get_tree().set_current_scene(fish_scene)
	print("Switched to fish game")
	main_game_root.visible = false

# Unpause the GameManager by setting process mode back to true
func unpauseMainGame():
	self.set_process(true)
	self.set_physics_process(true)
	main_game_root.visible = true
	# Remove the fish game scene from the tree
	var current_scene = get_tree().current_scene
	
	# Ensure the current scene is the fish game scene and remove it
	if current_scene.name == "Fish":
		current_scene.queue_free()  # Remove the fish game scene from the tree
	
	# Load and switch back to the main game scene
	if main_game_scene == null:
		get_tree().set_current_scene(main_game_scene)
	
	print("Switched back to main game and unpaused")


func get_all_skills():
	# Return a list of all SkillNodes in all tech trees
	var skills = []
	
	# Array of all the tech trees in the scene
	var tech_trees = [
		nuclearTree,
		geoTree,
		solarTree,
		windTree,
		hydroTree,
		fossilTree
	]
	
	# Loop through each tech tree
	for tree in tech_trees:
		# Call the recursive function to collect all SkillNodes within the tree
		collect_skill_nodes(tree, skills)
	
	return skills
# Helper function to recursively collect SkillNodes from a tree
func collect_skill_nodes(node, skills):
	# If the node is a SkillNode, add it to the list
	if node is SkillNode:
		skills.append(node)
	
	# Recursively check all children of the node
	#TODO: FIX
	for child in node.get_children():
		collect_skill_nodes(child, skills)

func _notification(what):
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT && get_tree().current_scene && get_tree().current_scene.name != "Fish" && get_tree().current_scene.name != "MainMenu":
		save_game()  # Save the game before quitting
		#get_tree().quit()
