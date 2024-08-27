extends Area2D

@export var move_speed: float = 150.0
var target_position: Vector2
var squiggle_amplitude: float = 50.0
var squiggle_frequency: float = 5.0
var start_position: Vector2

func _ready():
	start_position = position

	# Call the function to randomly select one of the sprites
	select_random_sprite()

func select_random_sprite():
	# Get all sprite nodes in this node
	var sprites = [$Sprite2D, $Sprite2D2,$Sprite2D3 ]

	# Choose a random index
	var random_index = randi() % sprites.size()

	# Set the chosen sprite to visible, others to invisible
	for i in range(sprites.size()):
		sprites[i].visible = (i == random_index)

func _process(delta):
	# Calculate direction to the target
	var direction = (target_position - position).normalized()

	# Create a squiggly effect
	var offset_x = sin(position.y / squiggle_frequency) * squiggle_amplitude
	var new_position = position + direction * move_speed * delta
	new_position.x += offset_x

	position = new_position

	# Check if trash reached its destination
	if position.distance_to(target_position) < 10:
		queue_free()

func destroy():
	# Logic to handle the destruction of the trash
	queue_free()
