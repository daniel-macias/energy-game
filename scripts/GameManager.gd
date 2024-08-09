extends Control

# Game variables
var happiness = 100  # 0 to 100
var tourists = 0  # 0 to infinity
var wattage = 100  # 0 to 100
var cleanliness = 100  # 0 to 100
var money = 1000
var cost = 0

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
@onready var city_button = $VBoxContainer/HBoxContainer/City

func _ready():
	load_game()
	set_process(true)  # Enable _process() to make updates over time

# Update functions
func update_happiness(value):
	happiness = clamp(happiness + value, 0, 100)
	update_happiness_image()
	update_tourists_based_on_happiness()

func update_cleanliness(value):
	cleanliness = clamp(cleanliness + value, 0, 100)
	cleanliness_bar.value = cleanliness
	update_happiness_based_on_cleanliness()

func update_tourists(value):
	tourists = max(tourists + value, 0)
	tourists_label.text = "Tourists: " + str(tourists)

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

# Influence functions
func update_happiness_based_on_cleanliness():
	if cleanliness < 50:
		update_happiness(-1 * cleanliness_to_happiness_multiplier)
	else:
		update_happiness(1 * cleanliness_to_happiness_multiplier)

func update_tourists_based_on_happiness():
	if happiness > 50:
		update_tourists(int(happiness / 10 * happiness_to_tourists_multiplier))
	else:
		update_tourists(-int((100 - happiness) / 10 * happiness_to_tourists_multiplier))

# Process function to handle updates over time
func _process(delta):
	update_cleanliness(-0.1 * delta)  # Decrease cleanliness over time
	update_wattage(-0.05 * delta)  # Decrease wattage slowly over time

# Save and Load functions
func save_game():
	var save_data = {
		"happiness": happiness,
		"tourists": tourists,
		"wattage": wattage,
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
