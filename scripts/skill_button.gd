extends TextureButton
class_name SkillNode

@onready var panel = $Panel
@onready var line_2d = $Line2D
# Called when the node enters the scene tree for the first time.
func _ready():
	if get_parent() is SkillNode:
		line_2d.add_point(get_global_transform().origin + size / 2)  # Start from the current skill node
		line_2d.add_point(get_parent().get_global_transform().origin + get_parent().size / 2)  # Connect to the parent



func _on_pressed():
	print("ljdsa")
	panel.show_behind_parent = true
