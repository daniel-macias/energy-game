extends Area2D

@export var speed: float = 300.0
var direction = Vector2.ZERO  # Bullet's direction

func _process(delta):
	# Move the bullet in the set direction
	position += direction * speed * delta

	# If the bullet goes off-screen, destroy it
	if position.x < 0 or position.x > get_viewport_rect().size.x or position.y < 0 or position.y > get_viewport_rect().size.y:
		queue_free()

func set_direction(new_direction: Vector2):
	direction = new_direction

func _on_bullet_collide(area):
	# Handle bullet collision with trash
	if area.name == "Trash":
		area.destroy()  # Call the destroy function on the trash node
		queue_free()  # Destroy the bullet as well
