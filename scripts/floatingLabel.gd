extends Label

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("fade_number")
	$AnimationPlayer.animation_finished.connect(self.on_animation_finished)

func on_animation_finished():
	queue_free()  # Remove the label from the scene after the animation
