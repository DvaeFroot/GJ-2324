extends CharacterBody2D

@export var star_particles: PackedScene
const ERROR: Vector2 = Vector2(0.5,0.5)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")
var player: CharacterBody2D

var turn_ended: bool = true

signal end_turn

func _ready() -> void:
	player = get_tree().current_scene.get_node("Player")

func _physics_process(delta: float) -> void:
	if velocity == Vector2.ZERO and turn_ended == false:
		end_turn.emit()
		turn_ended = true
	velocity = velocity.move_toward(Vector2.ZERO, 300 * delta)
	move_and_slide()
	var collision: KinematicCollision2D = move_and_collide(velocity * delta)
	if collision:
			var reflect = collision.get_remainder().bounce(collision.get_normal())
			velocity = velocity.bounce(collision.get_normal()) * 0.6
			move_and_collide(reflect)

func move() -> void:
	turn_ended = false
	var direction = noise(global_position.direction_to(player.global_position))
	velocity = direction * 300
	
func bumped() -> void:
	var direction = -global_position.direction_to(player.global_position)
	var timer = Timer.new()
	var star_particles_instance = star_particles.instantiate()
	get_tree().current_scene.add_child(star_particles_instance)
	star_particles_instance.global_position = global_position
	add_child(timer)
	timer.wait_time = 0.3
	timer.start()
	velocity = direction * 300
	await timer.timeout
	end_turn.emit()
	queue_free()

func noise(base: Vector2) -> Vector2:
	return Vector2(randf_range(base.x - ERROR.x, base.x + ERROR.x), randf_range(base.y - ERROR.y, base.y + ERROR.y)) 
