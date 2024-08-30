extends Area2D

@export var min_move_speed: float = 100.0
@export var max_move_speed: float = 250.0
@export var move_speed: float = 150.0
var target_position: Vector2
var squiggle_amplitude: float = 20.0
var squiggle_frequency: float = 20.0
var start_position: Vector2

func _ready():
	start_position = position
	#Assign a random speed within the range of min_move_speed and max_move_speed
	move_speed = randf_range(min_move_speed, max_move_speed)
	# Call the function to randomly select one of the sprites
	select_random_sprite()

func select_random_sprite():
	# Get all sprite nodes in this node
	var sprites = [$Sprite2D, $Sprite2D2,$Sprite2D3,$Sprite2D4]

	# Choose a random index
	var random_index = randi() % sprites.size()

	# Set the chosen sprite to visible, others to invisible
	for i in range(sprites.size()):
		sprites[i].visible = (i == random_index)

func _process(delta):
	# Calculate direction to the target
	var direction = (target_position - position).normalized()

	# Create a squiggly effect
	var offset_y = sin(position.x / squiggle_frequency) * squiggle_amplitude
	var new_position = position + direction * move_speed * delta
	new_position.y += offset_y

	position = new_position

	# Check if trash reached its destination
	if position.distance_to(target_position) < 10:
		queue_free()

func destroy():
	# Logic to handle the destruction of the trash
	GameManager.trash_shot += 1
	queue_free()
