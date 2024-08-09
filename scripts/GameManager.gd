extends Control

var happiness = 100
var tourists = 0
var wattage = 100
var cleanliness = 100
var money = 1000
var cost = 0

func _ready():
	load_game()

func update_happiness(value):
	happiness += value
	$Happiness.text = "Happiness: " + str(happiness)

func update_tourists(value):
	tourists += value
	$Tourists.text = "Tourists: " + str(tourists)

func update_money(value):
	money += value
	$Money.text = "Money: " + str(money)

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
	file.store_string(JSON.stringify(save_data))  # Use JSON.stringify to convert the dictionary to a JSON string
	file.close()

func load_game():
	if FileAccess.file_exists("user://save_game.dat"):
		var file = FileAccess.open("user://save_game.dat", FileAccess.READ)
		
		var json = JSON.new()  # Create an instance of the JSON class
		var result = json.parse(file.get_as_text())
		
		if result.error == OK:
			print("Error: There was an error loading!");
			var save_data = result.result  # Access the parsed dictionary

			happiness = save_data.get("happiness", 100)
			tourists = save_data.get("tourists", 0)
			wattage = save_data.get("wattage", 100)
			cleanliness = save_data.get("cleanliness", 100)
			money = save_data.get("money", 1000)
			cost = save_data.get("cost", 0)

			update_happiness(0)
			update_tourists(0)
			update_money(0)
		
		file.close()
