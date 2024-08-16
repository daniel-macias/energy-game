extends TextureButton
class_name SkillNode

@onready var panel = $Panel
@onready var line_2d = $Line2D
@onready var label = $MarginContainer/Label
@onready var selector = $SelectRectangle

# Skill attributes
@export var title: String
@export var description: String
@export var price: int

# Array of effects, each effect is a dictionary with "type" and "value"
@export var effects = []

var activated: bool = false  # Track if the skill has been activated

var level : int = 0:
	set(value):
		level = value
		label.text = str(level) + "/3"

# Called when the node enters the scene tree for the first time.
func _ready():
	# Wait until the layout is ready to calculate positions
	pass
	#call_deferred("_update_lines")

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

func deselect():
	# When this skill is deselected, hide the selection rectangle
	selector.visible = false
	
func select():
	# When this skill is selected, show the selection rectangle
	selector.visible = true

func activate_skill():
	if level < 3 and GameManager.money >= price:
		line_2d.default_color = Color(0,0,0.25)
		panel.show_behind_parent = true
		GameManager.update_money(-price)
		activated = true
		
		level = min(level+1, 3)
		var skills = get_children()
		for skill in skills:
			if skill is SkillNode and level == 1:
				skill.disabled = false
		
		# Apply each effect in the array to the GameManager
		for effect in effects:
			GameManager.apply_skill_effect(effect["type"], effect["value"])
			
# Save skill state
func save_state() -> Dictionary:
	return {
		"title": title,
		"activated": activated,
		"level": level
	}
	
# Load skill state
func load_state(data: Dictionary):
	activated = data.get("activated", false)
	level = data.get("level", 0)
	if activated:
		disabled = true

