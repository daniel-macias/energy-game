extends Area2D

@export var speed: float = 1000.0
var direction = Vector2.ZERO  # Bullet's direction

@onready var particles = $CPUParticles2D

func _ready():
	connect("area_entered", Callable(self, "_on_bullet_collide"))
	
	if direction != Vector2.ZERO:
		particles.direction = -direction.normalized()  # Emit particles in the opposite direction
		particles.emission_angle = direction.angle() + PI  # Rotate the emission to match the bullet's direction
		particles.emitting = true
		particles.gravity = -direction.normalized() * 1000

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
	area.destroy()  # Call the destroy function on the trash node
	queue_free()  # Destroy the bullet as well
