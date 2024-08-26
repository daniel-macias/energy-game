extends TextureButton
class_name SkillNode

@onready var panel = $Panel
@onready var line_2d = $Line2D
@onready var label = $MarginContainer/Label
@onready var selector = $SelectRectangle
@onready var lock = $Lock

# Skill attributes
@export var title: String
@export var description: String
@export var price: int
@export var price_increment: float

@export var unlocked = false

#Skill Meta
@export var roomId: int
@export var skillId: int

# Array of effects, each effect is a dictionary with "type" and "value"
@export var effects = [    {
		"type": "money_multiplier",
		"value": 1.2  # This means a 20% increase in money earned
	},
		{
		"type": "tourist_increase",
		"value": 0.1  # This adds 50 more tourists when activated
	}]

var activated: bool = false  # Track if the skill has been activated

var level : int = 0:
	set(value):
		level = value
		label.text = str(level) + "/3"

# Called when the node enters the scene tree for the first time.
func _ready():
	# Wait until the layout is ready to calculate positions
	if unlocked:
		lock.visible = false
	pass

func _update_lines():
	print("Updating line")
	if get_parent() is SkillNode:
		# Convert global positions to local positions relative to line_2d
		var start_position = self.global_position
		var end_position = get_parent().global_position

		# Calculate relative positions by subtracting line_2d's global position
		var relative_start = start_position - line_2d.global_position
		var relative_end = end_position - line_2d.global_position

		# Clear existing points and add new points
		line_2d.clear_points()
		line_2d.add_point(relative_start + size / 2)
		line_2d.add_point(relative_end + get_parent().size / 2)


func _on_pressed():
	_update_lines()
	GameManager.update_skill_panel(title, description, price, effects if effects else [], self)
	GameManager.update_skill_info(title,description)
	GameManager.open_dec_button.disabled = false

func deselect():
	# When this skill is deselected, hide the selection rectangle
	selector.visible = false
	
func select():
	# When this skill is selected, show the selection rectangle
	selector.visible = true

func activate_skill():
	if level < 3 and GameManager.money >= price and unlocked:
		GameManager.update_money(-price)
		activate_without_purchase()

# Activate
func activate_without_purchase():
	price += price_increment
	GameManager.update_skill_panel(title, description, price, effects if effects else [], self)
	
	line_2d.default_color = Color(0,0,0.25)
	panel.show_behind_parent = true
	activated = true
	
	level = min(level+1, 3)
	var skills = get_children()
	for skill in skills:
		if skill is SkillNode and level == 1:
			skill.unlocked = true
			skill.lock.visible = false
		
	# Apply each effect in the array to the GameManager
	for effect in effects:
		GameManager.apply_skill_effect(effect["type"], effect["value"], roomId, level)
		
	
# Save skill state
func save_state() -> Dictionary:
	return {
		"title": title,
		"activated": activated,
		"level": level,
		"roomId": roomId,
		"skillId": skillId
	}
	
# Load skill state
func load_state(data: Dictionary):
	activated = data.get("activated", false)
	level = data.get("level", 0)
	if activated:
		disabled = true
		for effect in effects:
			GameManager.apply_skill_effect(effect["type"],effect["value"], roomId, level)

