extends Area2D

@export var speed = 300.0
@export var direction = Vector2(1, 0)  # Default direction to the right

func _ready():
	connect("area_entered", Callable(self, "_on_bullet_collide"))

func _process(delta):
	position += direction * speed * delta

	# If the bullet goes off-screen, destroy it
	if position.x < 0 or position.x > get_viewport_rect().size.x:
		queue_free()

func _on_bullet_collide(area: Area2D):
	# Check if the area is a trash object
	if area.has_method("destroy"):
		area.destroy()
		queue_free()
