extends TextureButton
class_name SkillNode

@onready var panel = $Panel
@onready var line_2d = $Line2D
@onready var label = $MarginContainer/Label

var level : int = 0:
	set(value):
		level = value
		label.text = str(level) + "/3"

# Called when the node enters the scene tree for the first time.
func _ready():
	# Wait until the layout is ready to calculate positions
	call_deferred("_update_lines")

func _update_lines():
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
	line_2d.default_color = Color(0,0,0.25)
	panel.show_behind_parent = true
	
	level = min(level+1, 3)
	var skills = get_children()
	for skill in skills:
		if skill is SkillNode and level == 1:
			skill.disabled = false
